# Bevy Spatial Text Editor - Technical Design

## Core Components

```rust
use bevy::prelude::*;
use ropey::Rope;
use cosmic_text::{Buffer, FontSystem, SwashCache};

// Fragment data storage
#[derive(Component)]
pub struct TextFragment {
    pub rope: Rope,              // Efficient text editing
    pub font_system: FontSystem, // Cosmic-text font handling
    pub buffer: Buffer,          // Rendered text buffer
    pub is_dirty: bool,          // Needs re-render
}

// Spatial positioning (exact Alto coordinates)
#[derive(Component)]
pub struct SpatialData {
    pub alto_hpos: f32,     // Original Alto HPOS
    pub alto_vpos: f32,     // Original Alto VPOS  
    pub alto_width: f32,    // Original Alto WIDTH
    pub alto_height: f32,   // Original Alto HEIGHT
    pub scale_factor: f32,  // Display scaling
}

// Typography from Alto styles
#[derive(Component)]
pub struct AltoTypography {
    pub font_id: String,        // Alto STYLEREFS
    pub font_family: String,    // Alto FONTFAMILY
    pub font_size: f32,         // Alto FONTSIZE
    pub is_bold: bool,          // From FONTSTYLE="bold"
    pub color: Color,           // Alto FONTCOLOR
}

// Editing state
#[derive(Component)]
pub struct EditState {
    pub is_focused: bool,
    pub cursor_position: usize,
    pub selection: Option<(usize, usize)>,
    pub last_click_time: f64,
}

// Document metadata
#[derive(Component)]
pub struct DocumentMeta {
    pub block_id: String,       // Alto TextBlock ID
    pub element_type: FragmentType,
    pub reading_order: u32,
    pub page_number: u32,
}

#[derive(Debug, Clone, PartialEq)]
pub enum FragmentType {
    Title,
    Heading,
    Paragraph, 
    TableCell,
    Footnote,
}
```

## System Pipeline

```rust
// Startup system - load and parse Alto
fn setup_alto_document(
    mut commands: Commands,
    alto_xml: Res<AltoXmlData>,
    mut font_system: ResMut<FontSystem>,
) {
    let fragments = parse_alto_to_fragments(&alto_xml.content);
    
    for fragment_data in fragments {
        // Create Ropey buffer
        let rope = Rope::from_str(&fragment_data.content);
        
        // Create cosmic-text buffer
        let mut buffer = Buffer::new(&mut font_system, fragment_data.font_metrics);
        buffer.set_text(&rope.to_string());
        
        // Spawn entity with all components
        commands.spawn((
            TextFragment {
                rope,
                font_system: font_system.clone(),
                buffer,
                is_dirty: false,
            },
            SpatialData {
                alto_hpos: fragment_data.hpos,
                alto_vpos: fragment_data.vpos,
                alto_width: fragment_data.width,
                alto_height: fragment_data.height,
                scale_factor: 0.8,
            },
            Transform::from_translation(Vec3::new(
                fragment_data.hpos * 0.8,
                fragment_data.vpos * 0.8,
                0.0
            )),
            AltoTypography::from_style_ref(&fragment_data.style_ref),
            EditState::default(),
            DocumentMeta {
                block_id: fragment_data.block_id,
                element_type: classify_fragment_type(&fragment_data.content),
                reading_order: fragment_data.reading_order,
                page_number: fragment_data.page,
            },
        ));
    }
}

// Input handling system
fn handle_text_editing(
    keyboard: Res<ButtonInput<KeyCode>>,
    mut char_events: EventReader<ReceivedCharacter>,
    mut query: Query<(&mut TextFragment, &mut EditState)>,
) {
    for (mut fragment, mut edit_state) in query.iter_mut() {
        if !edit_state.is_focused {
            continue;
        }
        
        // Handle character input
        for event in char_events.read() {
            if !event.char.is_control() {
                fragment.rope.insert_char(edit_state.cursor_position, event.char);
                edit_state.cursor_position += 1;
                fragment.is_dirty = true;
            }
        }
        
        // Handle editing keys
        if keyboard.just_pressed(KeyCode::Backspace) && edit_state.cursor_position > 0 {
            edit_state.cursor_position -= 1;
            fragment.rope.remove(edit_state.cursor_position..edit_state.cursor_position + 1);
            fragment.is_dirty = true;
        }
    }
}

// Text rendering update system
fn update_text_rendering(
    mut query: Query<(&mut TextFragment, &AltoTypography)>,
    mut font_system: ResMut<FontSystem>,
) {
    for (mut fragment, typography) in query.iter_mut() {
        if fragment.is_dirty {
            // Update cosmic-text buffer from Ropey
            let text_content = fragment.rope.to_string();
            fragment.buffer.set_text(&text_content);
            
            // Apply typography
            fragment.buffer.set_font_size(&mut font_system, typography.font_size);
            
            fragment.is_dirty = false;
        }
    }
}

// Spatial interaction system
fn handle_spatial_clicks(
    mouse: Res<ButtonInput<MouseButton>>,
    window: Query<&Window>,
    camera: Query<(&Camera, &GlobalTransform)>,
    mut fragments: Query<(Entity, &Transform, &SpatialData, &mut EditState)>,
    mut commands: Commands,
) {
    if mouse.just_pressed(MouseButton::Left) {
        let window = window.single();
        let (camera, camera_transform) = camera.single();
        
        if let Some(world_position) = window.cursor_position()
            .and_then(|cursor| camera.viewport_to_world(camera_transform, cursor))
            .map(|ray| ray.origin.truncate())
        {
            // Find clicked fragment
            for (entity, transform, spatial, mut edit_state) in fragments.iter_mut() {
                let bounds = Rect::new(
                    transform.translation.x,
                    transform.translation.y,
                    transform.translation.x + spatial.alto_width * spatial.scale_factor,
                    transform.translation.y + spatial.alto_height * spatial.scale_factor,
                );
                
                if bounds.contains(world_position) {
                    // Focus this fragment
                    edit_state.is_focused = true;
                    commands.entity(entity).insert(TextFocus);
                } else {
                    // Unfocus others
                    edit_state.is_focused = false;
                    commands.entity(entity).remove::<TextFocus>();
                }
            }
        }
    }
}
```

## Integration with bevy_cosmic_edit

```rust
use bevy_cosmic_edit::*;

fn setup_cosmic_edit_plugin(app: &mut App) {
    app.add_plugins(CosmicEditPlugin::default())
       .add_systems(Startup, spawn_cosmic_editors)
       .add_systems(Update, sync_cosmic_to_spatial);
}

fn spawn_cosmic_editors(
    mut commands: Commands,
    fragments: Query<(Entity, &TextFragment, &SpatialData)>,
) {
    for (entity, fragment, spatial) in fragments.iter() {
        commands.entity(entity).insert(CosmicEditor::new(
            fragment.rope.to_string(),
            FontSize(spatial.scale_factor * 12.0),
        ));
    }
}
```

## Performance Characteristics

- **Memory efficient**: Ropey handles large text efficiently
- **GPU accelerated**: cosmic-text uses GPU for text rendering  
- **Scalable**: ECS handles thousands of text fragments
- **Responsive**: Direct input handling without UI framework overhead
- **Spatial precision**: Exact coordinate preservation

This architecture solves your core problem: **exact spatial positioning + full editability** in a performant, scalable system! 🎯