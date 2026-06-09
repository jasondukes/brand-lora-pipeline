# Inference & Evaluation

## Checkpoint Strategy

kohya_ss saves checkpoints at the interval you specify. With `save_every_n_steps = 250` and 2340 total steps you get checkpoints at:

```
your_lora-000250.safetensors
your_lora-000500.safetensors
your_lora-000750.safetensors
...
your_lora.safetensors   ← final (end of last epoch)
```

**The final checkpoint is not always the best one.** Earlier checkpoints are often more flexible and less overfit. Always test multiple.

---

## Loading into ComfyUI

### Copy checkpoints to ComfyUI's LoRA folder

```bash
# Find your ComfyUI loras path
docker exec comfyui find / -name "loras" -type d 2>/dev/null

# Copy a checkpoint (rename for clarity)
docker cp "/path/to/your_lora-000750.safetensors" \
  comfyui:/app/models/loras/your_lora_step750.safetensors
```

### Basic Workflow Node Structure

```
Load Checkpoint ──MODEL──► Load LoRA ──MODEL──► KSampler
                ──CLIP───► Load LoRA ──CLIP───► CLIP Text Encode (positive) ──► KSampler
                                              ► CLIP Text Encode (negative) ──► KSampler
                ──VAE────────────────────────────────────────────────────────► VAE Decode ──► Save Image
                                                          Empty Latent Image ──► KSampler
```

Load the workflow from `comfyui/lora_test_workflow.json` to skip manual node setup.

### KSampler Settings for Evaluation
| Parameter | Value |
|---|---|
| Steps | 25 |
| CFG | 7–7.5 |
| Sampler | euler_a |
| Scheduler | karras |
| Size | 512x512 |

---

## Checkpoint Evaluation Prompts

Use the same prompt across all checkpoints for fair comparison.

**Positive:**
```
appleshot, laptop on white background, three quarter view open, soft studio lighting, aluminum unibody chassis, slim profile, product photography, minimalist
```

**Negative:**
```
text, people, busy background, watermark, blurry, low quality, logo, cartoon, painting, distorted
```

---

## Checkpoint Evaluation Checklist

| Criterion | Good | Overfit |
|---|---|---|
| Background | Clean white/light gradient | Busy, dark, or wrong color |
| Product geometry | Recognizable, coherent | Melting, warped, wrong shape |
| Material feel | Metallic, premium | Waxy, plastic, painted |
| Shadow | Soft, defined underside | Missing or harsh |
| Flexibility | Responds to prompt changes | Ignores prompt variations |
| Composition | Generous negative space | Cropped or cluttered |

If outputs look like near-copies of training images, you're overfit — go back 250–500 steps.

---

## LoRA Strength Tuning

The strength (0.0–1.5) controls how hard the LoRA overrides the base model.

| Strength | Behavior |
|---|---|
| 0.5–0.6 | Style barely present, base model dominates |
| 0.7–0.8 | Balanced — style visible, base model coherence maintained |
| 0.85–0.95 | Strong style application — recommended for well-known brands |
| 1.0+ | Maximum style, geometry may degrade |

**For brands with strong base model priors (Apple, Nike, etc.):** Use 0.85–0.9. The base model has seen thousands of historical product images and will partially override your LoRA at lower strengths.

---

## The Base Model Prior Problem

SD1.5 was trained on internet-scale data including years of product photography. For well-known brands this creates a tension:

- Your LoRA learns the modern aesthetic from your 39 training images
- The base model "remembers" older product designs from its training data
- At low LoRA strength, the base model's memory partially wins

**Solutions:**

1. **Increase LoRA strength** to 0.85–0.9 to let your training dominate
2. **Use temporal anchors in prompts** — "2026 MacBook" pushes the model past its historical priors because it has no 2026 training data, so it defers to your LoRA
3. **Retrain at higher rank** — rank 32 has 4x the parameters of rank 8 and overrides base priors more effectively

---

## Social Media Asset Prompts

Once you have a working checkpoint, these prompts produce social-ready outputs:

**Instagram square (generate at 512x512, upscale after):**
```
appleshot, single product centered on white gradient background, soft studio lighting, precise shadow, aluminum and glass, minimalist product photography, high detail
Negative: text, people, clutter, logo, noise
```

**Dark mode / premium variant:**
```
appleshot, product on deep black background, edge rim lighting, metallic materials catching directional light, premium cinematic product photography, high contrast
Negative: white background, flat lighting, people, text
```

**Color variant exploration:**
```
appleshot, laptop on white background, three quarter view open, [COLOR] aluminum unibody, soft studio lighting, slim profile, product photography, minimalist
```
Replace `[COLOR]` with: `midnight blue`, `silver`, `space black`, `rose gold`, `forest green`

---

## Upscaling Outputs

512x512 is training resolution, not final output resolution. For social assets, upscale after generation:

- **ComfyUI:** Add an Upscale node (4x-UltraSharp or similar) after VAE Decode
- **External:** Topaz Gigapixel, Adobe Firefly upscaler, or Real-ESRGAN
- Target output: 2048x2048 for Instagram, 1500x500 for Twitter/X banner
