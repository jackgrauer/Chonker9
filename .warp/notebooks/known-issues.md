# Known Issues

## Cascading Output Bug
- **Trigger**: Multi-line git commit -m with unclosed quotes
- **Symptom**: Terminal shows cascading/garbled output
- **Fix**: Use git commit -e instead
- **Safe**: Single-line messages only
