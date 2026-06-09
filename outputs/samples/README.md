# Sample Outputs

Place your generated sample images here.

## Naming Convention

```
{lora_name}_{epoch_or_step}_{prompt_summary}.png
```

Examples:
```
apple_lora_epoch1_laptop_hero.png
apple_lora_epoch3_macbook_midnight.png
apple_lora_epoch3_iphone_profile.png
```

## What to Include

- One image per checkpoint tested (epoch 1, 2, 3)
- Same prompt across all checkpoints for fair comparison
- Your best final result with refined prompt
- Any interesting failure cases worth documenting

## Image from This Project

The best result from this run was generated with:
- Checkpoint: epoch 3 (`new model.safetensors`)
- LoRA strength: 0.9 (model and clip)
- Prompt: `appleshot, 2026 MacBook, pure white background, three quarter view open, extremely thin bezels, notch display, soft studio lighting, modern aluminum unibody, product photography, minimalist`
- Negative: `text, people, gray background, dark background, busy background, watermark, blurry, low quality, logo, cartoon, painting, render`
- CFG: 7.5, Steps: 25, Sampler: euler_a, Scheduler: karras
