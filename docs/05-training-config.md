# Training Configuration

## The Core Tradeoff: Rank vs. VRAM

LoRA rank (dimension) controls how much capacity the adapter has to learn. Higher rank = more expressive, more VRAM.

| Rank | Alpha | VRAM (2080S) | Use Case |
|---|---|---|---|
| 8 | 1 | ~5–6GB | Fast experimentation, proof of concept |
| 16 | 8 | ~6–6.5GB | Good balance for most use cases |
| 32 | 16 | ~7–7.5GB | Recommended for production quality |
| 64 | 32 | OOM on 8GB | Requires 12GB+ VRAM |

**For overriding strong base model priors (well-known brands), rank 32 is the minimum recommended.** Rank 8 produces recognizable style transfer but the base model's training data partially overrides it at lower LoRA strengths.

---

## Full Parameter Reference

### UI Settings (kohya_ss LoRA tab)

#### Model Section
| Field | Value | Notes |
|---|---|---|
| Pretrained model | `/path/to/v1-5-pruned-emaonly.safetensors` | Full path including filename |
| Trained model output name | `your_lora_name` | No spaces |
| Image folder | `/path/to/datasets/your_brand` | Parent folder, not the `20_trigger` subfolder |
| Save trained model as | `safetensors` | |
| Save precision | `fp16` | Not bf16 for SD1.5 |

#### Folders Section
| Field | Value |
|---|---|
| Output folder | `/path/to/output/your_lora_name` |
| Regularisation directory | *(leave blank)* |
| Logging directory | `/path/to/output/logs` |

#### Parameters — Basic
| Field | Value | Notes |
|---|---|---|
| LoRA type | Standard | |
| Train batch size | 1 | Cannot go higher at 8GB |
| Epoch | 3 | With 39 images at 20 repeats = 2340 steps |
| Max train steps | 0 | Let epoch count control |
| Save every N epochs | 0 | Use steps instead |
| Cache latents | ✅ | |
| Cache latents to disk | ✅ | |
| LR Scheduler | cosine_with_restarts | Smooth decay with recovery |
| Optimizer | AdamW8bit | Memory-efficient |
| Learning rate | 0.0001 | |
| Unet LR | 0.0001 | |
| Text encoder LR | 0.00005 | Lower — preserve text understanding |
| LR warmup (%) | 5 | ~100 steps at 2340 total |

#### Parameters — Advanced
| Field | Value | Notes |
|---|---|---|
| Mixed precision | fp16 | Required for 8GB |
| Gradient checkpointing | ✅ | Required for 8GB |
| xformers | xformers | Significant VRAM savings |
| Clip skip | 2 | Better aesthetic for SD1.5 |
| Save every N steps | 250 | Enables checkpoint evaluation |
| Network Rank (dim) | 32 | Recommended (was 8 in initial run) |
| Network Alpha | 16 | Half of rank is standard |

---

## Calculating Total Steps

```
total_steps = (num_images × repeats_per_image × epochs) / batch_size
```

For this project:
```
2340 = (39 images × 20 repeats × 3 epochs) / 1
```

The `20_` prefix in the dataset folder name sets the repeat count.

---

## Learning Rate Notes

The learning rate has more impact on output quality than step count. Signs of wrong LR:

| Symptom | Likely Cause | Fix |
|---|---|---|
| Loss doesn't decrease | LR too low | Increase to 2e-4 |
| Loss spikes wildly | LR too high | Decrease to 5e-5 |
| Outputs look like training images | Overfit | Reduce LR, check earlier checkpoints |
| Style not appearing | Underfit | Increase LR or run more steps |

---

## Monitoring Training

Open a second SSH session and watch GPU usage:
```bash
watch -n 2 nvidia-smi
```

During training you should see:
- VRAM: 6–7.5GB in use
- GPU utilization: 80–100%
- Temperature: 70–85°C (normal)

Expected loss trajectory:
- Steps 1–100: `0.15–0.25` (noisy)
- Steps 500+: trending toward `0.08–0.12`
- Steps 1500+: target `0.05–0.09`
- Final (this project): `0.049` ✅

---

## What Went Wrong in the Initial Run

The initial training run used rank 8 / alpha 1 instead of rank 32 / alpha 16. This happened because UI changes weren't persisted to config.toml. The config.toml values loaded on startup overrode the UI changes.

**Fix:** Always verify config.toml contains your intended values AND confirm the UI fields show the correct values before clicking Start Training. The UI state at click time is what trains — not the config file.

---

## If Training Crashes (OOM)

```bash
# Stop all GPU consumers first
docker stop ollama open-webui comfyui

# Verify VRAM is clear
nvidia-smi
# Should show only Xorg at ~9MiB

# Then retry training
```

If it still OOMs, reduce in this order:
1. Enable gradient checkpointing (if not already)
2. Enable cache latents to disk (if not already)
3. Reduce rank from 32 to 16
