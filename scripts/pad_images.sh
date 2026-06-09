#!/bin/bash
# pad_images.sh
# Resizes images to fit within 512x512 and pads with white to fill exactly 512x512.
# Preserves full product visibility — does not crop.
#
# Usage: ./scripts/pad_images.sh /path/to/image/folder
#
# Requirements: imagemagick (sudo apt install imagemagick)

set -e

TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Check imagemagick is installed
if ! command -v convert &> /dev/null; then
  echo "Error: imagemagick not found. Install with: sudo apt install imagemagick"
  exit 1
fi

echo "Processing images in: $TARGET_DIR"
echo "Target size: 512x512 with white padding"
echo ""

count=0
skipped=0

cd "$TARGET_DIR"

for f in *.jpg *.jpeg *.png *.JPG *.JPEG *.PNG; do
  # Skip if no files match
  [ -f "$f" ] || continue

  # Skip already-processed files
  [[ "$f" == *_512.jpg ]] && continue

  base="${f%.*}"

  # Get current dimensions
  dims=$(identify -format "%wx%h" "$f" 2>/dev/null)
  
  if [ "$dims" = "512x512" ]; then
    echo "  SKIP (already 512x512): $f"
    ((skipped++)) || true
    continue
  fi

  echo "  Processing: $f ($dims)"

  # Resize to fit within 512x512, pad with white to exactly 512x512
  convert "$f" \
    -resize 512x512 \
    -background white \
    -gravity center \
    -extent 512x512 \
    "${base}_512.jpg"

  # Remove original, rename padded version
  rm "$f"
  mv "${base}_512.jpg" "${base}.jpg"

  ((count++)) || true
done

echo ""
echo "Done. Processed: $count | Skipped (already 512x512): $skipped"
echo ""

# Verify all images are now 512x512
echo "Verification:"
identify *.jpg 2>/dev/null | awk '{print $3}' | sort | uniq -c
