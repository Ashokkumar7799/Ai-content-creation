#!/bin/bash
# ---------------------------------------------------------
# EROS10 STANDALONE SETUP SCRIPT
# ---------------------------------------------------------

WORKSPACE="$HOME/LTX_Workspace"
COMFY_DIR="$WORKSPACE/ComfyUI"
VENV_DIR="$COMFY_DIR/venv_eros10"
HF_CLI="~/.local/bin/hf"

echo "======================================================="
echo "  🚀 INITIALIZING EROS10 STANDALONE INSTALLATION "
echo "======================================================="

# 1. Create Isolated Environment
if [ ! -d "$VENV_DIR" ]; then
    echo "⚙️ Creating isolated venv_eros10..."
    cd "$COMFY_DIR"
    python3 -m venv venv_eros10
    venv_eros10/bin/pip install --upgrade pip
    
    echo "⚙️ Installing ComfyUI base dependencies into venv_eros10..."
    venv_eros10/bin/pip install -r requirements.txt
    
    echo "⚙️ Installing Extension dependencies..."
    if [ -f "custom_nodes/ComfyUI-Manager/requirements.txt" ]; then
        venv_eros10/bin/pip install -r custom_nodes/ComfyUI-Manager/requirements.txt
    else
        venv_eros10/bin/pip install GitPython toml
    fi
    
    if [ -f "custom_nodes/ComfyUI-LTXVideo/requirements.txt" ]; then
        venv_eros10/bin/pip install -r custom_nodes/ComfyUI-LTXVideo/requirements.txt
    fi
    # Fix Kornia 0.8.x breaking LTXVideo's pyramid blending
    venv_eros10/bin/pip install kornia==0.7.3
else
    echo "✅ venv_eros10 already exists!"
fi

# Helper function for downloading models
download_hf_model() {
    local repo_id=$1
    local filename=$2
    local output_dir=$3
    local final_name=$4

    if [ ! -f "$output_dir/$final_name" ]; then
        echo "⚡ Downloading $final_name..."
        eval "$HF_CLI download $repo_id $filename --local-dir /tmp/eros_downloads"
        mv "/tmp/eros_downloads/$filename" "$output_dir/$final_name"
    else
        echo "✅ $final_name already exists!"
    fi
}

mkdir -p /tmp/eros_downloads
mkdir -p "$COMFY_DIR/models/diffusion_models"
mkdir -p "$COMFY_DIR/models/loras"
mkdir -p "$COMFY_DIR/models/loras/faceID"
mkdir -p "$COMFY_DIR/models/clip"
mkdir -p "$COMFY_DIR/models/vae"
mkdir -p "$COMFY_DIR/models/latent_upscale_models"

echo "======================================================="
echo "  🚀 DOWNLOADING EROS10 MODELS & LORAS"
echo "======================================================="

# Diffusion Model
download_hf_model "TenStrip/LTX2.3-10Eros" "10Eros_v1.5_bf16.safetensors" "$COMFY_DIR/models/diffusion_models" "10Eros_v1.5_bf16.safetensors"

# DMD LoRA
download_hf_model "TenStrip/LTX2.3_DMD_Lora" "LTX2.3_DMD_reshaped_r256.safetensors" "$COMFY_DIR/models/loras" "LTX2.3_DMD_reshaped_r256.safetensors"

# Face-ID LoRAs (Placed in faceID subfolder as expected by the JSON)
download_hf_model "Alissonerdx/LTX-Best-Face-ID" "Best_FaceID_v1.0_LoRA.safetensors" "$COMFY_DIR/models/loras/faceID" "Best_FaceID_v1.0_LoRA.safetensors"
download_hf_model "Alissonerdx/LTX-Best-Face-ID" "Best_FaceID_v1.0_ArcFace_Projector.safetensors" "$COMFY_DIR/models/loras/faceID" "Best_FaceID_v1.0_ArcFace_Projector.safetensors"
download_hf_model "Alissonerdx/LTX-Best-Face-ID" "Best_FaceID_CharacterSheet_v1.0_LoRA.safetensors" "$COMFY_DIR/models/loras/faceID" "Best_FaceID_CharacterSheet_v1.0_LoRA.safetensors"

# Text Encoders (Gemma INT8 and Projection placed in 'clip' for Load CLIP node)
download_hf_model "Stick9190/gemma-3-12b-it-int8-convrot" "gemma_3_12B_it_int8_convrot.safetensors" "$COMFY_DIR/models/clip" "gemma_3_12B_it_int8_convrot.safetensors"
download_hf_model "Kijai/LTX2.3_comfy" "text_encoders/ltx-2.3_text_projection_bf16.safetensors" "$COMFY_DIR/models/clip" "ltx-2.3_text_projection_bf16.safetensors"

# VAEs
download_hf_model "Kijai/LTX2.3_comfy" "vae/LTX23_audio_vae_bf16.safetensors" "$COMFY_DIR/models/vae" "LTX23_audio_vae_bf16.safetensors"
download_hf_model "Kijai/LTX2.3_comfy" "vae/LTX23_video_vae_bf16.safetensors" "$COMFY_DIR/models/vae" "LTX23_video_vae_bf16.safetensors"

# Upscaler
download_hf_model "Lightricks/LTX-2.3" "ltx-2.3-spatial-upscaler-x2-1.1.safetensors" "$COMFY_DIR/models/latent_upscale_models" "ltx-2.3-spatial-upscaler-x2-1.1.safetensors"


echo "======================================================="
echo "  🚀 CLONING 10S EROS10 CUSTOM NODES"
echo "======================================================="
if [ ! -d "$COMFY_DIR/custom_nodes/10S-Comfy-nodes" ]; then
    echo "⚙️ Cloning 10S-Comfy-nodes..."
    git clone https://github.com/TenStrip/10S-Comfy-nodes "$COMFY_DIR/custom_nodes/10S-Comfy-nodes"
    if [ -f "$COMFY_DIR/custom_nodes/10S-Comfy-nodes/requirements.txt" ]; then
        cd "$COMFY_DIR" && venv_eros10/bin/pip install -r custom_nodes/10S-Comfy-nodes/requirements.txt
    fi
else
    echo "✅ 10S-Comfy-nodes already installed!"
fi

echo "======================================================="
echo "  🎉 STANDALONE EROS10 SETUP COMPLETE! "
echo "======================================================="
rm -rf /tmp/eros_downloads

