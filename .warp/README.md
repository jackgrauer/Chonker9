# Warp Drive Repository Integration

This `.warp` directory contains workflows, notebooks, and scripts that integrate with the Warp Drive system, providing AI-powered terminal assistance and automation.

## 🚀 Quick Start

1. **Sync to Warp Drive**: Run the sync script to import these configurations:
   ```bash
   ./.warp/scripts/sync.sh
   ```

2. **Enable AI Context**: After syncing, your Warp AI agent will have access to project-specific workflows and known issues.

## 📁 Directory Structure

- `workflows/` - YAML workflow definitions for automated tasks
- `notebooks/` - Markdown documentation and knowledge bases  
- `scripts/` - Bash scripts for automation and utilities

## 🔧 Available Workflows

### Safe Git Commit (`safe-commit.yaml`)
Prevents the Warp terminal cascading output bug by validating commit messages and using safe patterns.

**Usage:**
- Automatically detects unsafe multi-line messages
- Falls back to editor mode for complex commits
- Validates message length and format

## 📖 Knowledge Base

### Known Issues (`notebooks/known-issues.md`)
Documents terminal compatibility issues and provides safe alternatives.

## 🔄 Syncing Changes

The sync script (`scripts/sync.sh`) will:
- Copy workflows to `~/warp-drive/workflows/` with repo prefix
- Update AI agent knowledge base
- Maintain separate namespaces for different repositories

## 🪝 Git Integration

A post-merge hook is installed to notify when `.warp` files change:
- Automatically detects changes after `git pull` or merge
- Reminds you to run the sync script
- Keeps your Warp Drive up-to-date

## 🤖 AI Agent Context

When synced, your Warp AI agent will:
- Reference project-specific known issues
- Suggest safe command alternatives
- Use validated workflows for common tasks
- Provide context-aware assistance

## 💡 Best Practices

1. **Always sync after changes**: Run `./warp/scripts/sync.sh` when you modify workflows
2. **Test workflows locally**: Validate scripts before committing
3. **Document issues**: Add new problems to `notebooks/known-issues.md`
4. **Use descriptive names**: Workflow files should be self-explanatory

## 🔒 Safety Features

- Git hooks warn about `.warp` changes
- Sync script validates file integrity  
- AI agent checks known issues before suggesting commands
- Workflows include safety validations

---

*This repository is configured to work with Warp Drive v1.0+*
