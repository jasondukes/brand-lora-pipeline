#!/bin/bash
# generate_captions.sh
# Generates base caption .txt files for every .jpg in a folder.
# Each caption uses the trigger word and a generic template.
# You MUST review and customize each caption after generation.
#
# Usage: ./scripts/generate_captions.sh /path/to/image/folder yourtrigger
#
# Example: ./scripts/generate_captions.sh ~/kohya_data/datasets/mybrand/20_brandshot brandshot

set -e

TARGET_DIR="${1:-.}"
TRIGGER="${2:-trigger}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: directory '$TARGET_DIR' does not exist."
  exit 1
fi

if [ "$TRIGGER" = "trigger" ]; then
  echo "Warning: using default trigger word 'trigger'. Pass your actual trigger as second argument."
  echo "Usage: $0 /path/to/folder yourtrigger"
  echo ""
fi

echo "Generating captions in: $TARGET_DIR"
echo "Trigger word: $TRIGGER"
echo ""

cd "$TARGET_DIR"

count=0
skipped=0

for f in *.jpg *.jpeg *.png; do
  [ -f "$f" ] || continue

  base="${f%.*}"
  txt_file="${base}.txt"

  # Skip if caption already exists and has content
  if [ -f "$txt_file" ] && [ -s "$txt_file" ]; then
    echo "  SKIP (caption exists): $txt_file"
    ((skipped++)) || true
    continue
  fi

  # Write default caption
  echo "${TRIGGER}, product on white background, soft studio lighting, aluminum and glass materials, minimalist composition, product photography" > "$txt_file"

  echo "  Created: $txt_file"
  ((count++)) || true
done

echo ""
echo "Done. Created: $count | Skipped (already exist): $skipped"
echo ""
echo "IMPORTANT: Review and customize each caption to match the actual image."
echo "See docs/04-captioning-strategy.md for the caption formula and examples."
echo ""
echo "Quick check — open the first few captions:"
ls *.txt 2>/dev/null | head -5 | while read f; do
  echo "  $f: $(cat "$f")"
done
