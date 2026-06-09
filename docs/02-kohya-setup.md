# kohya_ss Setup

## Why Local Install Instead of Docker

The kohya_ss Docker image (`bmaltais/kohya_ss`) was removed from Docker Hub and the GitHub Container Registry image is unreliable. The project README recommends local installation for Linux, and the `uv` method handles all dependency management cleanly.

---

## Installation

### Prerequisites
```bash
sudo apt install -y git curl tmux imagemagick
```

### Install uv
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env  # or restart shell
uv --version  # verify
```

### Clone at exact release tag
```bash
cd ~
git clone https://github.com/bmaltais/kohya_ss.git
cd kohya_ss
git checkout v25.2.1
git describe --tags  # should return: v25.2.1
chmod +x gui-uv.sh
```

### First launch (installs all dependencies automatically)
```bash
./gui-uv.sh --listen 0.0.0.0 --server_port 7860
```

First run takes 3–5 minutes while uv builds the venv and pulls 165 packages. Wait for:
```
* Running on local URL:  http://0.0.0.0:7860
```

---

## config.toml Setup

kohya_ss loads default values from `config.toml` at startup. This prevents having to re-enter paths every session.

```bash
cd ~/kohya_ss
cp "config example.toml" config.toml
nano config.toml
```

### Critical values to set

```toml
[model]
models_dir = "/home/YOUR_USER/kohya_data/models/base/v1-5-pruned-emaonly.safetensors"
save_model_as = "safetensors"
save_precision = "fp16"        # NOT bf16 for SD1.5

[folders]
output_dir = "/home/YOUR_USER/kohya_data/output/your_lora_name"
reg_data_dir = ""              # Leave blank — no regularisation images
logging_dir = "/home/YOUR_USER/kohya_data/output/logs"

[basic]
clip_skip = 2                  # Important for SD1.5 aesthetic quality
gradient_checkpointing = true  # Required for 8GB VRAM
cache_latents = true
cache_latents_to_disk = true
lr_scheduler = "cosine_with_restarts"
lr_warmup = 5
save_every_n_steps = 250       # Checkpoint every 250 steps
epoch = 3

[advanced]
dataset_config = ""            # Leave blank
state_dir = ""                 # Leave blank — do not resume from state
vae_dir = ""                   # Leave blank
xformers = "xformers"
```

### Common config pitfalls

| Field | Wrong value | Correct value | Symptom |
|---|---|---|---|
| `dataset_config` | `"./test.toml"` | `""` | Silent training fail |
| `reg_data_dir` | `"./data/reg"` | `""` | Validation error on start |
| `state_dir` | `"./outputs"` | `""` | FileNotFoundError on start |
| `vae_dir` | `"./models/vae"` | `""` | Validation error on start |
| `models_dir` | directory path | full path to .safetensors file | Model not found error |
| `save_precision` | `"bf16"` | `"fp16"` | Wrong precision for SD1.5 |

---

## Running Persistently with tmux

Running kohya_ss directly in an SSH session means it dies when the session closes. Use tmux:

```bash
tmux new -s kohya
cd ~/kohya_ss
./gui-uv.sh --listen 0.0.0.0 --server_port 7860
# Ctrl+B then D to detach — process keeps running
```

To reattach later:
```bash
tmux attach -t kohya
```

If you get `no sessions` error, the process died. Just relaunch.

If you get `port already in use` error:
```bash
fuser -k 7860/tcp
# Then relaunch
```

---

## Accessing the UI

Once running, the GUI is accessible from any machine on your local network:
```
http://YOUR_LINUX_IP:7860
```

Navigate to the **LoRA** tab — not Dreambooth. All training configuration happens there.

---

## Creating the Directory Structure

```bash
mkdir -p ~/kohya_data/datasets/your_brand/20_yourtrigger
mkdir -p ~/kohya_data/output/your_lora_name
mkdir -p ~/kohya_data/output/logs
mkdir -p ~/kohya_data/models/base
```

The `20_` prefix in the dataset subfolder tells kohya_ss to repeat each image 20 times per epoch. The word after the underscore becomes the trigger token.
