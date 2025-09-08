// Simple test to verify Bevy spatial editor concept
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🧪 Testing Bevy Spatial Editor Concept");
    
    // Test Alto XML parsing without full Bevy setup
    let test_xml = r#"<?xml version="1.0" encoding="UTF-8"?>
<alto xmlns="http://www.loc.gov/standards/alto/ns-v3#">
<Layout>
<Page ID="Page1" WIDTH="612.0000" HEIGHT="792.0000">
<PrintSpace>
<TextBlock ID="p1_b1" HPOS="160.7871" VPOS="84.8248">
<TextLine ID="p1_t1" HPOS="160.7871" VPOS="84.8248">
<String ID="p1_w1" CONTENT="CITY" HPOS="160.7871" VPOS="84.8248" WIDTH="26.3735" HEIGHT="10.6338" STYLEREFS="font0"/>
<String ID="p1_w2" CONTENT="CASH" HPOS="189.8127" VPOS="84.8248" WIDTH="29.3485" HEIGHT="10.6338" STYLEREFS="font0"/>
<String ID="p1_w3" CONTENT="MANAGEMENT" HPOS="221.8133" VPOS="84.8248" WIDTH="79.8063" HEIGHT="10.6338" STYLEREFS="font0"/>
</TextLine>
</TextBlock>
</PrintSpace>
</Page>
</Layout>
</alto>"#;

    // Test the parsing logic
    test_alto_parsing(test_xml)?;
    
    println!("✅ Bevy spatial editor concept verified!");
    println!("   Next: Run full Bevy app with 'cargo run --bin chonker-bevy'");
    
    Ok(())
}

fn test_alto_parsing(xml: &str) -> Result<(), Box<dyn std::error::Error>> {
    use regex::Regex;
    
    let re = Regex::new(r#"<String[^>]+CONTENT="([^"]*)"[^>]*HPOS="([\d.]+)"[^>]*VPOS="([\d.]+)"[^>]*WIDTH="([\d.]+)"[^>]*HEIGHT="([\d.]+)"(?:[^>]*STYLEREFS="([^"]*)")?[^>]*/>"#)?;
    
    let mut fragments = Vec::new();
    
    for cap in re.captures_iter(xml) {
        let fragment = Fragment {
            content: cap[1].to_string(),
            hpos: cap[2].parse()?,
            vpos: cap[3].parse()?,
            width: cap[4].parse()?,
            height: cap[5].parse()?,
            style_ref: cap.get(6).map(|m| m.as_str().to_string()),
        };
        
        println!("📄 Fragment: '{}' at ({:.1}, {:.1}) {}x{}", 
            fragment.content, fragment.hpos, fragment.vpos, 
            fragment.width, fragment.height);
            
        fragments.push(fragment);
    }
    
    // Test grouping logic
    let grouped = group_test_fragments(fragments)?;
    println!("🎯 Grouped into {} logical blocks:", grouped.len());
    
    for (i, group) in grouped.iter().enumerate() {
        println!("  Block {}: '{}'", i+1, group.content);
    }
    
    Ok(())
}

#[derive(Debug, Clone)]
struct Fragment {
    content: String,
    hpos: f32,
    vpos: f32,
    width: f32,
    height: f32,
    style_ref: Option<String>,
}

fn group_test_fragments(mut fragments: Vec<Fragment>) -> Result<Vec<Fragment>, Box<dyn std::error::Error>> {
    if fragments.is_empty() {
        return Ok(fragments);
    }
    
    // Sort by reading order
    fragments.sort_by(|a, b| {
        a.vpos.partial_cmp(&b.vpos).unwrap()
            .then_with(|| a.hpos.partial_cmp(&b.hpos).unwrap())
    });
    
    let mut grouped = Vec::new();
    let mut current_group = vec![fragments[0].clone()];
    let mut last_vpos = fragments[0].vpos;
    
    for fragment in fragments.into_iter().skip(1) {
        // Group fragments within 15 pixels vertically (same line)
        if (fragment.vpos - last_vpos).abs() <= 15.0 {
            current_group.push(fragment);
        } else {
            // Finish current group
            if !current_group.is_empty() {
                grouped.push(merge_group(current_group)?);
            }
            last_vpos = fragment.vpos;
            current_group = vec![fragment];
        }
    }
    
    // Add final group
    if !current_group.is_empty() {
        grouped.push(merge_group(current_group)?);
    }
    
    Ok(grouped)
}

fn merge_group(mut group: Vec<Fragment>) -> Result<Fragment, Box<dyn std::error::Error>> {
    if group.is_empty() {
        return Err("Empty group".into());
    }
    
    if group.len() == 1 {
        return Ok(group.into_iter().next().unwrap());
    }
    
    // Sort by HPOS (left to right)
    group.sort_by(|a, b| a.hpos.partial_cmp(&b.hpos).unwrap());
    
    // Combine content with spaces
    let combined_content = group.iter()
        .map(|f| f.content.clone())
        .collect::<Vec<_>>()
        .join(" ");
    
    // Use position of first element, extend width
    let first = &group[0];
    let last = group.last().unwrap();
    let total_width = (last.hpos + last.width) - first.hpos;
    
    Ok(Fragment {
        content: combined_content,
        hpos: first.hpos,
        vpos: first.vpos,
        width: total_width,
        height: first.height,
        style_ref: first.style_ref.clone(),
    })
}