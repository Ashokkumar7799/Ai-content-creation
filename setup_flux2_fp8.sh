#!/bin/bash

echo "⚙️ Creating FLUX.2 Folders..."
export HF_XET_HIGH_PERFORMANCE=1
COMFY_DIR="$HOME/LTX_Workspace/ComfyUI"

mkdir -p "$COMFY_DIR/models/vae"
mkdir -p "$COMFY_DIR/models/text_encoders"
mkdir -p "$COMFY_DIR/models/loras"
mkdir -p "$COMFY_DIR/models/diffusion_models"

# Create a temporary download folder so we don't mess up ComfyUI
mkdir -p /tmp/flux2_downloads

echo "🚀 Downloading FLUX.2 VAE..."
~/.local/bin/hf download black-forest-labs/FLUX.2-small-decoder full_encoder_small_decoder.safetensors --local-dir /tmp/flux2_downloads
mv /tmp/flux2_downloads/full_encoder_small_decoder.safetensors "$COMFY_DIR/models/vae/"

echo "🚀 Downloading Mistral 3 Text Encoder..."
~/.local/bin/hf download Comfy-Org/flux2-dev split_files/text_encoders/mistral_3_small_flux2_bf16.safetensors --local-dir /tmp/flux2_downloads
mv /tmp/flux2_downloads/split_files/text_encoders/mistral_3_small_flux2_bf16.safetensors "$COMFY_DIR/models/text_encoders/"

echo "🚀 Downloading FLUX.2 Turbo LoRA..."
~/.local/bin/hf download ByteZSzn/Flux.2-Turbo-ComfyUI Flux_2-Turbo-LoRA_comfyui.safetensors --local-dir /tmp/flux2_downloads
mv /tmp/flux2_downloads/Flux_2-Turbo-LoRA_comfyui.safetensors "$COMFY_DIR/models/loras/"

echo "🚀 Downloading FLUX.2 FP8 Diffusion Model (Skipping massive 64GB base)..."
~/.local/bin/hf download Comfy-Org/flux2-dev split_files/diffusion_models/flux2_dev_fp8mixed.safetensors --local-dir /tmp/flux2_downloads
mv /tmp/flux2_downloads/split_files/diffusion_models/flux2_dev_fp8mixed.safetensors "$COMFY_DIR/models/diffusion_models/"

# Clean up temporary folder
rm -rf /tmp/flux2_downloads
echo "✅ FLUX.2 Workflow Files Downloaded!"
