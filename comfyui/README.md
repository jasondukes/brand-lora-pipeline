# ComfyUI LoRA Test Workflow

The `lora_test_workflow.json` file in this directory is exported directly from ComfyUI.

## To export your workflow from ComfyUI:
1. Open ComfyUI at your server's IP:8188
2. Build or load your LoRA workflow
3. Click the **Save** button (or Menu → Save)
4. This downloads a `.json` file
5. Rename it to `lora_test_workflow.json` and place it here

## To import this workflow into ComfyUI:
1. Open ComfyUI
2. Click **Load** (or Menu → Load)
3. Select the `lora_test_workflow.json` file
4. Update the model paths and LoRA name to match your setup

## Workflow Node Structure

```
Load Checkpoint ──MODEL──► Load LoRA ──MODEL──► KSampler ──LATENT──► VAE Decode ──► Save Image
                ──CLIP───► Load LoRA ──CLIP───► CLIP Text Encode (+) ──► KSampler
                                              ► CLIP Text Encode (-) ──► KSampler
                ──VAE────────────────────────────────────────────────────────────► VAE Decode
                                                          Empty Latent Image ──► KSampler
```

## Recommended Settings

| Node | Field | Value |
|---|---|---|
| Load Checkpoint | ckpt_name | v1-5-pruned-emaonly.safetensors |
| Load LoRA | lora_name | your_lora_name.safetensors |
| Load LoRA | strength_model | 0.9 |
| Load LoRA | strength_clip | 0.9 |
| KSampler | steps | 25 |
| KSampler | cfg | 7.5 |
| KSampler | sampler_name | euler_a |
| KSampler | scheduler | karras |
| Empty Latent Image | width | 512 |
| Empty Latent Image | height | 512 |
