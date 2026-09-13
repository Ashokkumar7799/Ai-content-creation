#!/bin/bash
# ---------------------------------------------------------
# WAN 2.2 AUTOMATIC DOWNLOADER (BASH SCRIPT)
# ---------------------------------------------------------

WORKSPACE="$HOME/LTX_Workspace"
COMFY_DIR="$WORKSPACE/ComfyUI"

if [ ! -d "$COMFY_DIR" ]; then
    echo "⚠️ Warning: ComfyUI folder not found!"
    exit 1
fi

echo "🚀 Starting Wan 2.2 Quarantine Setup & Download..."

# ==========================================
# QUARANTINE ENVIRONMENT SETUP (venv_wan)
# ==========================================
if [ ! -d "$COMFY_DIR/venv_wan" ]; then
    echo "🐍 Creating isolated venv_wan to protect your other workflows..."
    cd "$COMFY_DIR"
    python3 -m venv venv_wan
    venv_wan/bin/pip install --upgrade pip
    echo "⚙️ Installing PyTorch CUDA 13.0 (Blackwell Architecture Support)..."
    venv_wan/bin/pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu130
    echo "⚙️ Installing ComfyUI base requirements..."
    venv_wan/bin/pip install -r requirements.txt
    
    echo "⚙️ Installing ComfyUI-Manager dependencies..."
    if [ -f "custom_nodes/ComfyUI-Manager/requirements.txt" ]; then
        venv_wan/bin/pip install -r custom_nodes/ComfyUI-Manager/requirements.txt
    else
        venv_wan/bin/pip install GitPython toml
    fi
    
    echo "🔌 Installing Kijai's WanVideoWrapper custom node..."
    if [ ! -d "custom_nodes/ComfyUI-WanVideoWrapper" ]; then
        git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git custom_nodes/ComfyUI-WanVideoWrapper
        venv_wan/bin/pip install -r custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt
    fi
    
    echo "✅ venv_wan created successfully!"
else
    echo "✅ Isolated venv_wan already exists."
fi

# ==========================================
# MODEL DOWNLOADS
# ==========================================
echo "🚀 Starting Model Downloads via hf-cli..."
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
            local url_path="${repo_path// /%20}"
            local direct_url="https://huggingface.co/$repo/resolve/main/$url_path?download=true"
            wget -c --show-progress -O "$final_path" "$direct_url"
        }
        
        # Move file if HF nested it
        if [ -f "$dest_dir/$repo_path" ] && [ "$dest_dir/$repo_path" != "$final_path" ]; then
            mv "$dest_dir/$repo_path" "$final_path"
        fi
        
        # Cleanup potential empty folder from nested HF path
        local top_folder=$(echo "$repo_path" | cut -d'/' -f1)
        if [ -n "$top_folder" ] && [ "$top_folder" != "$repo_path" ] && [ -d "$dest_dir/$top_folder" ]; then
            rm -rf "$dest_dir/$top_folder"
        fi
    else
        echo "✅ Skipping $filename (Already exists)"
    fi
}

# 1. Diffusion Models (HIGH & LOW Noise)
download_hf_model "Kijai/WanVideo_comfy_fp8_scaled" "I2V/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors" "$COMFY_DIR/models/diffusion_models/WanVideo/2_2" "Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors"
download_hf_model "Kijai/WanVideo_comfy_fp8_scaled" "I2V/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors" "$COMFY_DIR/models/diffusion_models/WanVideo/2_2" "Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors"

# 2. VAE
download_hf_model "Kijai/WanVideo_comfy" "Wan2_1_VAE_bf16.safetensors" "$COMFY_DIR/models/vae/wanvideo" "Wan2_1_VAE_bf16.safetensors"

# 3. LoRA (LightX2V 4-Step)
download_hf_model "PatrickZane/lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors" "lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors" "$COMFY_DIR/models/loras/WanVideo/Lightx2v" "lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors"

# 4. Text Encoder
download_hf_model "Kijai/WanVideo_comfy" "umt5-xxl-enc-bf16.safetensors" "$COMFY_DIR/models/text_encoders" "umt5-xxl-enc-bf16.safetensors"

echo "======================================================="
echo "  🎉 ALL WAN 2.2 MODELS DOWNLOADED SUCCESSFULLY! "
echo "======================================================="
