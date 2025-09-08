// Enhanced version with mutool PDF rendering
use ratatui::{prelude::*, widgets::*};
use crossterm::event::{self, Event, KeyCode, KeyModifiers};
use std::path::PathBuf;
use std::process::Command;
use std::fs;
use std::time::Duration;
use anyhow::Result;
use std::io::Write;

// Import existing types from main module
include!("chonker5-tui.rs");

// ============= ENHANCED PDF RENDERING =============
impl ChonkerTUI {
    fn render_pdf_with_mutool(&mut self) -> Result<()> {
        if let Some(pdf_path) = &self.pdf_path {
            // Check if mutool is available
            if Command::new("mutool").arg("--version").output().is_ok() {
                // Render to text for terminal display
                let output = Command::new("mutool")
                    .args([
                        "draw",
                        "-F", "txt",
                        "-o", "-",
                        pdf_path.to_str().unwrap(),
                        &format!("{}", self.current_page + 1)
                    ])
                    .output()?;
                
                if output.status.success() {
                    let text = String::from_utf8_lossy(&output.stdout);
                    self.pdf_render_cache = Some(text.to_string());
                } else {
                    // Fallback to basic rendering
                    self.render_current_page()?;
                }
            } else {
                // No mutool available, use basic rendering
                self.render_current_page()?;
            }
        }
        Ok(())
    }
    
    fn extract_matrix_with_mutool(&mut self) -> Result<()> {
        if let Some(pdf_path) = &self.pdf_path {
            // First try mutool for better text extraction
            if Command::new("mutool").arg("--version").output().is_ok() {
                let output = Command::new("mutool")
                    .args([
                        "draw",
                        "-F", "stext",
                        "-o", "-",
                        pdf_path.to_str().unwrap(),
                        &format!("{}", self.current_page + 1)
                    ])
                    .output()?;
                
                if output.status.success() {
                    let stext = String::from_utf8_lossy(&output.stdout);
                    // Parse structured text output
                    self.parse_stext_to_matrix(&stext)?;
                    return Ok(());
                }
            }
            
            // Fallback to PDFium extraction
            self.extract_matrix()?;
        }
        Ok(())
    }
    
    fn parse_stext_to_matrix(&mut self, stext: &str) -> Result<()> {
        // Create a large matrix
        let mut matrix = CharacterMatrix::new(200, 100);
        
        // Simple parser for mutool stext output
        // In real implementation, you'd parse the XML structure
        let lines: Vec<&str> = stext.lines().collect();
        let mut y = 0;
        
        for line in lines {
            if line.contains("<char") {
                // Extract character and position from stext XML
                // Simplified parsing here
                if let (Some(x_pos), Some(char_match)) = (
                    line.find("x=\"").map(|i| &line[i+3..i+7]),
                    line.find(">").and_then(|i| line.chars().nth(i+1))
                ) {
                    if let Ok(x) = x_pos.trim_end_matches('"').parse::<f32>() {
                        let x_idx = (x / 7.0) as usize;
                        if x_idx < matrix.width && y < matrix.height {
                            matrix.matrix[y][x_idx] = char_match;
                        }
                    }
                }
            } else if line.contains("</line>") {
                y += 1;
            }
        }
        
        self.editable_matrix = Some(matrix.matrix.clone());
        self.character_matrix = Some(matrix);
        self.status_message = "Extracted matrix using mutool".to_string();
        Ok(())
    }
}

// For image-capable terminals (requires ratatui-image feature)
#[cfg(feature = "images")]
mod image_support {
    use super::*;
    use ratatui_image::{Image, protocol::StatefulImage, Resize};
    use image::DynamicImage;
    
    pub fn render_pdf_as_image(pdf_path: &PathBuf, page: usize) -> Result<StatefulImage> {
        let temp_png = format!("/tmp/chonker_tui_p{}.png", page);
        
        // Render PDF to PNG using mutool
        let status = Command::new("mutool")
            .args([
                "draw",
                "-o", &temp_png,
                "-F", "png",
                "-r", "150", // DPI
                pdf_path.to_str().unwrap(),
                &format!("{}", page + 1)
            ])
            .status()?;
        
        if status.success() {
            let img = image::open(&temp_png)?;
            let _ = fs::remove_file(&temp_png);
            
            Ok(Image::from_dynamic(img)
                .resize(Resize::Fit))
        } else {
            Err(anyhow::anyhow!("Failed to render PDF"))
        }
    }
}