# Hardware Requirements

## Tested Configuration

| Component | Spec |
|---|---|
| GPU | NVIDIA RTX 2080 Super (8GB VRAM) |
| CPU | Intel i7 |
| RAM | 32GB |
| Storage | 742GB available |
| OS | Ubuntu 24 |
| CUDA | 13.0 |
| Driver | 580.126.09 |

---

## VRAM Requirements by Task

| Task | VRAM Used | Notes |
|---|---|---|
| Idle (Xorg only) | ~9MiB | Clean baseline |
| Latent caching | ~2–3GB | Temporary during prep |
| SD1.5 LoRA training (rank 8) | ~6–7GB | With optimizations below |
| SD1.5 LoRA training (rank 32) | ~7–7.5GB | Tight but achievable |
| ComfyUI inference | ~4–5GB | With LoRA loaded |

**Important:** Stop all other GPU-using processes before training. Ollama, ComfyUI, and open-webui all consume VRAM even when idle.

```bash
# Check what's using VRAM before training
nvidia-smi

# Stop common GPU consumers
docker stop ollama open-webui comfyui
```

---

## Required VRAM Optimizations for 8GB

These settings are mandatory — without them training will OOM:

- `mixed_precision = fp16` — halves memory for activations
- `xformers = xformers` — memory-efficient attention, significant savings
- `gradient_checkpointing = true` — trades compute for memory
- `cache_latents = true` — pre-encodes images, frees VRAM during training
- `cache_latents_to_disk = true` — keeps cached latents off GPU
- `train_batch_size = 1` — cannot go higher at 8GB

---

## Prerequisites

### NVIDIA Driver
```bash
nvidia-smi
# Confirm GPU is visible and driver version is shown
```

### nvidia-container-toolkit (if using Docker)
```bash
nvidia-ctk --version
# If missing:
sudo apt install nvidia-container-toolkit
sudo systemctl restart docker
```

### Verify GPU is accessible
```bash
# Quick test — should show your GPU in nvidia-smi output
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

---

## Can I Train on Less Than 8GB?

Technically yes, but it requires additional compromises:

- **6GB:** Reduce rank to 4, enable `lowvram` flag, may need smaller dataset batches
- **4GB:** Not recommended for SD1.5 LoRA — consider textual inversion instead

## Can I Use SDXL Instead of SD1.5?

SDXL requires significantly more VRAM for training. On 8GB:
- Inference: possible with `--lowvram` flags
- Training: not recommended — use SD1.5 and upscale outputs instead
