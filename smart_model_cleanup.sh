#!/bin/bash

echo "=========================================="
echo " 🧹 SMART MODEL CLEANUP TOOL"
echo "=========================================="
echo "1. Delete ONLY FLUX.2 (fp8) models (Frees up ~40GB)"
echo "2. Delete ONLY LTX-2.3 models (Frees up ~46GB)"
echo "3. Delete ONLY SeedVR2/FLUX-dev Base models (Frees up ~24GB)"
echo "4. Delete ONLY Wan 2.2 models (Frees up ~40GB)"
echo "5. Delete ALL models (Nuke everything)"
echo "=========================================="
read -p "Select an option (1-5): " option

COMFY_DIR="$HOME/LTX_Workspace/ComfyUI"

case $option in
    1)
        echo "🗑️ Deleting FLUX.2 models..."
        rm -f "$COMFY_DIR/models/vae/full_encoder_small_decoder.safetensors"
        rm -f "$COMFY_DIR/models/text_encoders/mistral_3_small_flux2_bf16.safetensors"
        rm -f "$COMFY_DIR/models/loras/Flux_2-Turbo-LoRA_comfyui.safetensors"
        rm -f "$COMFY_DIR/models/diffusion_models/flux2_dev_fp8mixed.safetensors"
        echo "✅ FLUX.2 models deleted!"
        ;;
    2)
        echo "🗑️ Deleting LTX-2.3 models..."
        rm -f "$COMFY_DIR/models/diffusion_models/ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors"
        rm -f "$COMFY_DIR/models/latent_upscale_models/ltx-2.3-spatial-upscaler-x2-1.1.safetensors"
        rm -f "$COMFY_DIR/models/loras/ltx-2.3-22b-distilled-lora-1.1_fro90_ceil72_condsafe.safetensors"
        rm -f "$COMFY_DIR/models/loras/Singularity LTX-2.3  OmniCine Preview v0.1.safetensors"
        rm -f "$COMFY_DIR/models/loras/ltx2.3-ic-subtitles-remove-general.safetensors"
        rm -f "$COMFY_DIR/models/text_encoders/gemma_3_12B_it_fp8_e4m3fn.safetensors"
        rm -f "$COMFY_DIR/models/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors"
        rm -f "$COMFY_DIR/models/text_encoders/ltx-2.3_text_projection_bf16.safetensors"
        rm -f "$COMFY_DIR/models/vae/LTX23_audio_vae_bf16.safetensors"
        rm -f "$COMFY_DIR/models/vae/LTX23_video_vae_bf16.safetensors"
        rm -f "$COMFY_DIR/models/vae/taeltx2_3.safetensors"
        echo "✅ LTX-2.3 models deleted!"
        ;;
    3)
        echo "🗑️ Deleting SeedVR2 & FLUX-dev Base models..."
        rm -rf "$COMFY_DIR/models/SEEDVR2"
        rm -f "$COMFY_DIR/models/unet/flux1-dev.safetensors"
        rm -f "$COMFY_DIR/models/diffusion_models/flux1-dev.safetensors"
        rm -f "$COMFY_DIR/models/checkpoints/flux1-dev.safetensors"
        echo "✅ SeedVR2 and FLUX Base models deleted (~20-45GB freed)!"
        ;;
    4)
        echo "🗑️ Deleting Wan 2.2 models..."
        rm -rf "$COMFY_DIR/models/diffusion_models/WanVideo"
        rm -rf "$COMFY_DIR/models/vae/wanvideo"
        rm -rf "$COMFY_DIR/models/loras/WanVideo"
        rm -f "$COMFY_DIR/models/text_encoders/umt5-xxl-enc-bf16.safetensors"
        echo "✅ Wan 2.2 models deleted (~40GB freed)!"
        ;;
    5)
        echo "🗑️ Deleting ALL models..."
        find "$COMFY_DIR/models" -type f -name "*.safetensors" -delete
        echo "✅ All models deleted! SSD is completely free."
        ;;
    *)
        echo "❌ Invalid option selected."
        ;;
esac
