#!/bin/bash
# ---------------------------------------------------------
# EROS10 TO LTX SWAPPER SCRIPT
# This deletes the Eros10 model and replaces it with the Base LTX model
# ---------------------------------------------------------

WORKSPACE="$HOME/LTX_Workspace"
COMFY_DIR="$WORKSPACE/ComfyUI"

if [ ! -d "$COMFY_DIR" ]; then
    echo "⚠️ Warning: ComfyUI folder not found!"
    exit 1
fi

echo "======================================================="
echo "  🚀 REVERTING BACK TO BASE LTX MODEL..."
echo "======================================================="

echo "🗑️ Deleting Eros10 model & DMD LoRA to save space..."
rm -f "$COMFY_DIR/models/diffusion_models/10Eros_v1.5_bf16.safetensors"
rm -f "$COMFY_DIR/models/loras/LTX2.3_DMD_reshaped_r256.safetensors"

# Helper function
download_hf_model() {
    local repo=$1
    local repo_path=$2
    local dest_dir=$3
    local filename=$4

    mkdir -p "$dest_dir"
    local final_path="$dest_dir/$filename"

    if [ ! -f "$final_path" ]; then
        echo "⚡ Downloading $filename..."
        ~/.local/bin/hf download "$repo" "$repo_path" --local-dir "$dest_dir" || {
            echo "⚠️ hf download failed for $filename. Retrying with wget..."
            local url_path="${repo_path// /%20}"
            local direct_url="https://huggingface.co/$repo/resolve/main/$url_path?download=true"
            wget -c --show-progress -O "$final_path" "$direct_url"
        }
        
        # Move file if HF nested it
        if [ -f "$dest_dir/$repo_path" ] && [ "$dest_dir/$repo_path" != "$final_path" ]; then
            mv "$dest_dir/$repo_path" "$final_path"
        fi
        
        local top_folder=$(echo "$repo_path" | cut -d'/' -f1)
        if [ -n "$top_folder" ] && [ "$top_folder" != "$repo_path" ] && [ -d "$dest_dir/$top_folder" ]; then
            rm -rf "$dest_dir/$top_folder"
        fi
    else
        echo "✅ Skipping $filename (Already exists)"
    fi
}

echo "⚡ Downloading Base LTX-2.3 Model..."
download_hf_model "Kijai/LTX2.3_comfy" "diffusion_models/ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors" "$COMFY_DIR/models/diffusion_models" "ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors"

echo "======================================================="
echo "  🎉 SWAP COMPLETE! "
echo "  You have successfully reverted to the Base LTX model!"
echo "======================================================="
