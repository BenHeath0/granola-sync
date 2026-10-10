#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Ask Notes
# @raycast.mode fullOutput
# @raycast.packageName Notes
# @raycast.icon 🔎
# @raycast.argument1 { "type": "text", "placeholder": "Question" }

cd "$HOME/Developer/notes" || exit 1

# strict mcp config skips connecting every other mcp server, which is most of the startup time
"$HOME/.local/bin/claude" -p "Answer this question from my notes. Search with the qmd tools, read the best matches, and cite the file paths you used. If the notes don't cover it, say so. Question: $1" \
  --strict-mcp-config \
  --mcp-config "{\"mcpServers\":{\"qmd\":{\"command\":\"$HOME/.local/bin/qmd\",\"args\":[\"mcp\"]}}}" \
  --allowedTools "mcp__qmd__*"
