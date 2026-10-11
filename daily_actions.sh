#!/bin/bash
cd "$HOME/Developer/notes" || exit 1

# pick up meetings that ended after the 6pm sync
/opt/homebrew/bin/uv run --script granola_sync.py

# on monday, look back to friday
[ "$(date +%u)" = 1 ] && back=3 || back=1
day=$(date -v-${back}d +%F)
[ -d "meetings/$day" ] || exit 0

out="actions/$day.md"
mkdir -p actions

for f in meetings/"$day"/*.md; do printf '<note path="%s">\n' "$f"; cat "$f"; printf '\n</note>\n'; done |
  "$HOME/.local/bin/claude" -p "Above are Ben Heath's meeting notes from $day. Extract every action item, commitment, or follow-up discussed, including ones outside 'Next Steps' sections. Merge duplicates across meetings. Output only this markdown, no preamble:

# Action items: $day

## Ben
- [ ] <item> (<meeting title>, [notes](<granola url>))

## Others
- [ ] **<owner>**: <item> (<meeting title>, [notes](<granola url>))

Items Ben owns go under Ben. Items with no clear owner go under Others with owner 'Unassigned'. Omit an empty section. If there are no action items at all, output the heading followed by 'No action items.'" \
    --model sonnet \
    --setting-sources project \
    --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
    --tools "" > "$out" || exit 1

count=$(grep -c '^- \[ \]' "$out")
button=$(osascript -e "display dialog \"$count action items from $day\" with title \"Meeting actions\" buttons {\"Later\", \"Open\"} default button \"Open\"" 2>/dev/null)
[ "$button" = "button returned:Open" ] && open "$out"
