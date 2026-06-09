# Captioning Strategy

Good captions are the most underrated factor in LoRA quality. They teach the model what's unique about your subject vs. what's generic, and they anchor the trigger word to specific visual attributes.

---

## The Trigger Word

Choose a short, unique token that won't conflict with common SD vocabulary. This is what you'll use at inference time to invoke the style.

- Good: `appleshot`, `brandxhero`, `studiotek`
- Avoid: common words like `product`, `photo`, `studio` — these already have strong meanings in SD

The trigger word must **always lead the caption.**

---

## Caption Formula

```
[trigger], [subject], [background], [lighting], [material detail], [composition], product photography, minimalist
```

### Examples from this project

```
# MacBook hero shot
appleshot, laptop on white background, three quarter hero view open, soft studio lighting, aluminum unibody chassis, notch display, slim tapered profile, product photography, minimalist

# MacBook side profile
appleshot, laptop on white background, side profile view closed, soft studio lighting, extremely thin aluminum unibody, tapered wedge profile, product photography, minimalist

# MacBook color variant
appleshot, ultra thin laptop on white background, three quarter hero view open, soft studio lighting, indigo aluminum unibody, borderless display, product photography, minimalist

# iPhone hero
appleshot, smartphone on white background, front and back hero view, soft studio lighting, aluminum frame and glass back, minimalist composition, product photography

# iPad with accessory
appleshot, tablet with keyboard folio, white background, soft studio lighting, aluminum and black fabric materials, portable workstation form factor, product photography, minimalist
```

---

## Caption Rules

**Always lead with the trigger word** — it anchors everything that follows to your style.

**Name objects generically** — use `laptop`, `smartphone`, `tablet` instead of brand-specific names. You're training the visual style, not brand recognition.

**Be specific about materials** — this is what distinguishes premium product photography. `aluminum unibody`, `glass back`, `titanium frame`, `matte finish` all carry visual meaning to the model.

**Describe the angle** — `three quarter view`, `side profile`, `overhead top view`, `front view open`. The model needs to learn multiple compositions to be flexible at inference.

**Keep structure consistent** — captions that follow the same formula across all images train more coherently than varied prose.

**Don't over-caption** — 10–15 tokens is ideal. Long captions dilute the signal of the trigger word.

---

## Generating Base Captions

The script generates identical placeholder captions for every image. You then review and customize each one:

```bash
./scripts/generate_captions.sh ~/kohya_data/datasets/your_brand/20_yourtrigger yourtrigger
```

This writes a `.txt` file for every `.jpg` with the default formula. Open each one and update the subject, angle, and material descriptions to match the actual image.

---

## The Color Variant Pattern

When you have multiple images of the same product in different colors, the caption structure should be identical except for the color descriptor:

```
appleshot, ultra thin laptop on white background, three quarter hero view open, soft studio lighting, blush pink aluminum unibody, borderless display, product photography, minimalist

appleshot, ultra thin laptop on white background, three quarter hero view open, soft studio lighting, citrus yellow aluminum unibody, borderless display, product photography, minimalist

appleshot, ultra thin laptop on white background, three quarter hero view open, soft studio lighting, indigo aluminum unibody, borderless display, product photography, minimalist
```

This teaches the model that the color is a variable — it learns to generalize the form while accepting color prompting.

---

## Auto-Captioning with WD14

kohya_ss includes a WD14 auto-captioner under **Utilities → WD14 Captioner**. It generates tag-based captions automatically. If you use it:

1. Run it first to get base tags
2. Prepend your trigger word to every generated caption
3. Remove generic tags that don't describe your style
4. Add material and lighting descriptors manually

Auto-captioning is faster for large datasets but produces less precise captions than hand-written ones for style training.

---

## Verifying Caption Quality

Before training, spot-check a sample:
```bash
cat image_name.txt
# Should show: trigger, subject, background, lighting, material, composition tags
```

Check that every image has a matching caption file:
```bash
ls *.jpg | wc -l && ls *.txt | wc -l
# Both numbers must be identical
```
