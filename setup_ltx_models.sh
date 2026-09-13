#!/bin/bash
# ---------------------------------------------------------
# LTX-2.3 MODELS AUTOMATIC DOWNLOADER (BASH SCRIPT)
# ---------------------------------------------------------

WORKSPACE="$HOME/LTX_Workspace"
COMFY_DIR="$WORKSPACE/ComfyUI"

if [ ! -d "$COMFY_DIR" ]; then
    echo "⚠️ Warning: ComfyUI folder not found!"
    exit 1
fi

echo "🚀 Starting LTX-2.3 Model Downloads via hf-cli..."
export HF_HUB_ENABLE_HF_TRANSFER=1

# Helper function to download a file if it doesn't exist
download_hf_model() {
    local repo=$1
    local repo_path=$2
    local dest_dir=$3
    local filename=$4

    mkdir -p "$dest_dir"
    local final_path="$dest_dir/$filename"

    if [ ! -f "$final_path" ]; then
        echo "⚡ Downloading $filename to $dest_dir/..."
        # Try HF download first
        ~/.local/bin/hf download "$repo" "$repo_path" --local-dir "$dest_dir" || {
            echo "⚠️ hf download failed for $filename. Retrying with wget..."
            # Simple URL encode for spaces
            local url_path="${repo_path// /%20}"
            local direct_url="https://huggingface.co/$repo/resolve/main/$url_path?download=true"
            wget -c --show-progress -O "$final_path" "$direct_url"
        }
        
        # Move file if HF nested it
        if [ -f "$dest_dir/$repo_path" ] && [ "$dest_dir/$repo_path" != "$final_path" ]; then
            mv "$dest_dir/$repo_path" "$final_path"
        fi
        
        # Cleanup potential empty folder from nested HF path (e.g., text_encoders/)
        local top_folder=$(echo "$repo_path" | cut -d'/' -f1)
        if [ -n "$top_folder" ] && [ "$top_folder" != "$repo_path" ] && [ -d "$dest_dir/$top_folder" ]; then
            rm -rf "$dest_dir/$top_folder"
        fi
    else
        echo "✅ Skipping $filename (Already exists)"
    fi
}

# 1. Diffusion Model (LTX-2.3 Base)
download_hf_model "Kijai/LTX2.3_comfy" "diffusion_models/ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors" "$COMFY_DIR/models/diffusion_models" "ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors"
# download_hf_model "TenStrip/LTX2.3-10Eros" "10Eros_v1.5_bf16.safetensors" "$COMFY_DIR/models/diffusion_models" "10Eros_v1.5_bf16.safetensors"

# 2. Upscaler
download_hf_model "Lightricks/LTX-2.3" "ltx-2.3-spatial-upscaler-x2-1.1.safetensors" "$COMFY_DIR/models/latent_upscale_models" "ltx-2.3-spatial-upscaler-x2-1.1.safetensors"

# 3. LoRAs
# download_hf_model "TenStrip/LTX2.3_DMD_Lora" "LTX2.3_DMD_reshaped_r256.safetensors" "$COMFY_DIR/models/loras" "LTX2.3_DMD_reshaped_r256.safetensors"
download_hf_model "TenStrip/LTX2.3_Distilled_Lora_1.1_Experiments" "ltx-2.3-22b-distilled-lora-1.1_fro90_ceil72_condsafe.safetensors" "$COMFY_DIR/models/loras" "ltx-2.3-22b-distilled-lora-1.1_fro90_ceil72_condsafe.safetensors"
download_hf_model "WarmBloodAban/Singularity-LTX-2.3_OmniCine_V1" "Singularity LTX-2.3  OmniCine Preview v0.1.safetensors" "$COMFY_DIR/models/loras" "Singularity LTX-2.3  OmniCine Preview v0.1.safetensors"
download_hf_model "joyfox/LTX2.3-ICEdit-Insight" "ltx2.3-ic-subtitles-remove-general.safetensors" "$COMFY_DIR/models/loras" "ltx2.3-ic-subtitles-remove-general.safetensors"

# 4. Text Encoders
download_hf_model "GitMylo/LTX-2-comfy_gemma_fp8_e4m3fn" "gemma_3_12B_it_fp8_e4m3fn.safetensors" "$COMFY_DIR/models/text_encoders" "gemma_3_12B_it_fp8_e4m3fn.safetensors"
download_hf_model "Kijai/LTX2.3_comfy" "text_encoders/ltx-2.3_text_projection_bf16.safetensors" "$COMFY_DIR/models/text_encoders" "ltx-2.3_text_projection_bf16.safetensors"
download_hf_model "Comfy-Org/ltx-2" "split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors" "$COMFY_DIR/models/text_encoders" "gemma_3_12B_it_fp4_mixed.safetensors"

# 5. VAEs
download_hf_model "Kijai/LTX2.3_comfy" "vae/LTX23_audio_vae_bf16.safetensors" "$COMFY_DIR/models/vae" "LTX23_audio_vae_bf16.safetensors"
download_hf_model "Kijai/LTX2.3_comfy" "vae/LTX23_video_vae_bf16.safetensors" "$COMFY_DIR/models/vae" "LTX23_video_vae_bf16.safetensors"
download_hf_model "Kijai/LTX2.3_comfy" "vae/taeltx2_3.safetensors" "$COMFY_DIR/models/vae" "taeltx2_3.safetensors"

echo "======================================================="
echo "  🎉 ALL LTX-2.3 MODELS DOWNLOADED SUCCESSFULLY! "
echo "======================================================="
