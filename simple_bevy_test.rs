use bevy::prelude::*;

fn main() {
    println!("🧪 Testing minimal Bevy text rendering");
    
    App::new()
        .add_plugins(DefaultPlugins)
        .add_systems(Startup, setup)
        .run();
}

fn setup(mut commands: Commands) {
    // Camera
    commands.spawn(Camera2dBundle::default());
    
    // Simple text at origin
    commands.spawn(Text2dBundle {
        text: Text::from_section(
            "HELLO WORLD", 
            TextStyle {
                font: Handle::default(),
                font_size: 60.0,
                color: Color::WHITE,
            }
        ),
        ..default()
    });
    
    println!("✅ Spawned simple text entity");
}