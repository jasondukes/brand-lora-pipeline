# Dataset Preparation

## How Many Images Do You Need?

| Dataset Size | Quality | Training Time (2080S) |
|---|---|---|
| 10–15 images | Baseline style recognition | ~20–30 min |
| 20–30 images | Good style transfer | ~45–75 min |
| 39 images (this project) | Strong style, limited overfitting | ~10 min at 3 epochs |
| 50+ images | Production quality | ~2–3 hrs |

Quality matters far more than quantity. 39 carefully selected images will outperform 100 mediocre ones every time.

---

## Image Selection Criteria

### Include
- Single product, clean background (white, light gray, or subtle gradient)
- Multiple angles of the same product family (hero, side, top, three-quarter)
- Color variants of the same form factor — teaches color without confusing geometry
- Images where the physical chassis/form is the dominant element
- Consistent studio lighting treatment across images

### Exclude
- Multi-product lineup shots — confuses the model about what to generate
- Accessory-only shots with no device present
- Close-up crops of ports, keyboards, or single components
- Trade show or event photography (mixed lighting, busy backgrounds)
- Images with heavy text overlays or watermarks
- Duplicate or near-duplicate compositions

### The Screen Content Question

Images showing screen content (apps, UI, wallpapers) are usable as long as the physical device chassis is the dominant element. The model learns lighting, form factor, and materials — not what's on screen. Reject only when the screen fills 90%+ of the frame with no chassis visible.

---

## Folder Structure

kohya_ss requires a specific structure:

```
~/kohya_data/datasets/
└── your_brand/                          # Image folder (point GUI here)
    └── 20_yourtrigger/                  # repeat_count + trigger_word
        ├── image_01.jpg
        ├── image_01.txt                 # caption file, same name
        ├── image_02.jpg
        ├── image_02.txt
        └── ...
```

The `20_` means each image is seen 20 times per epoch. For 39 images this gives 780 training steps per epoch — enough for meaningful learning without overfitting.

---

## Resizing to 512x512

SD1.5 trains natively at 512x512. Use fit-and-pad (not crop) to preserve full product visibility:

```bash
./scripts/pad_images.sh ~/kohya_data/datasets/your_brand/20_yourtrigger
```

This script uses ImageMagick to resize images to fit within 512x512 and fills remaining space with white. White padding is invisible on Apple-style white backgrounds.

**Why not crop?** Center-cropping a portrait-orientation product shot cuts off the top and bottom of the device. Padding preserves the complete product in frame.

**Verify results:**
```bash
identify *.jpg | awk '{print $3}' | sort | uniq
# Should show only: 512x512
```

---

## Transferring Images

From Mac to Linux tower:
```bash
scp "/path/to/your/images/"*.jpg username@192.168.1.XXX:~/kohya_data/datasets/your_brand/20_yourtrigger/
```

Note: paths with spaces need quoting.

---

## File Naming

Clean, descriptive filenames make captioning easier and help with debugging. If your files have spaces, rename them:

```bash
cd ~/kohya_data/datasets/your_brand/20_yourtrigger
# Rename spaces to hyphens
for f in *\ *.jpg; do mv "$f" "${f// /-}"; done
```

---

## Final Checklist Before Training

```bash
# Image and caption counts must match exactly
ls *.jpg | wc -l
ls *.txt | wc -l

# All images must be 512x512
identify *.jpg | awk '{print $3}' | sort | uniq

# Spot check a caption
cat your_image_name.txt
```
