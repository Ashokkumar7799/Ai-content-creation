#!/bin/bash
# ---------------------------------------------------------
# KREA 2 AUTOMATIC INSTALLER (BLACKWELL GPU OPTIMIZED)
# ---------------------------------------------------------

WORKSPACE="$HOME/LTX_Workspace"
COMFY_DIR="$WORKSPACE/ComfyUI"
VENV_DIR="$COMFY_DIR/venv_krea2"
PIP="$VENV_DIR/bin/pip"
PYTHON="$VENV_DIR/bin/python"

echo "======================================================="
echo "  🚀 INITIALIZING KREA 2 TURBO (BF16) INSTALLATION     "
echo "======================================================="

# 1. Create Isolated Environment
if [ ! -d "$VENV_DIR" ]; then
    echo "⚙️ Creating isolated venv_krea2..."
    python3 -m venv "$VENV_DIR"
    $PIP install --upgrade pip
    
    echo "⚙️ Installing PyTorch 2.14 Nightly (cu130) for Blackwell GPU..."
    $PIP install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu130
    
    echo "🗑️ Wiping poisoned NVIDIA libraries..."
    $PIP uninstall -y nvidia-cublas-cu12 nvidia-cuda-cupti-cu12 nvidia-cuda-nvrtc-cu12 nvidia-cuda-runtime-cu12 nvidia-cudnn-cu12 nvidia-cufft-cu12 nvidia-curand-cu12 nvidia-cusolver-cu12 nvidia-cusparse-cu12 nvidia-nccl-cu12 nvidia-nvtx-cu12 nvidia-nccl-cu13
    
    # Install ComfyUI requirements in this venv
    $PIP install -r "$COMFY_DIR/requirements.txt"
    
    # Python 3.12 syntax fixes for comfy_kitchen
    NA_PY="$VENV_DIR/lib/python3.12/site-packages/comfy_kitchen/backends/eager/na.py"
    if [ -f "$NA_PY" ]; then
        sed -i '1i import typing' "$NA_PY"
        sed -i 's/list\[int\]/typing.List\[int\]/g' "$NA_PY"
        sed -i 's/list\[bool\]/typing.List\[bool\]/g' "$NA_PY"
    fi
    $PIP install kornia==0.7.3
else
    echo "✅ venv_krea2 already exists!"
fi

# 2. Install Fast Downloader
echo "⚙️ Setting up hf-transfer for high-speed downloads..."
$PIP install -q hf-transfer huggingface_hub GitPython opencv-python-headless
export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_XET_HIGH_PERFORMANCE=1
HF_CLI="hf"

# 3. Create Model Directories
mkdir -p "$COMFY_DIR/models/diffusion_models/krea2"
mkdir -p "$COMFY_DIR/models/text_encoders"
mkdir -p "$COMFY_DIR/models/vae"
mkdir -p "$COMFY_DIR/models/loras/krea2"
mkdir -p "$COMFY_DIR/custom_nodes"

# 4. Clone Custom Nodes
echo "🚀 Cloning ComfyUI-Krea2T-Enhancer node..."
if [ ! -d "$COMFY_DIR/custom_nodes/ComfyUI-Krea2T-Enhancer" ]; then
    git clone https://github.com/capitan01R/ComfyUI-Krea2T-Enhancer "$COMFY_DIR/custom_nodes/ComfyUI-Krea2T-Enhancer"
fi

# 5. Download Models
echo "======================================================="
echo "  ⚡ DOWNLOADING MASSIVE UNCOMPRESSED KREA 2 MODELS    "
echo "======================================================="

# Diffusion Model (BF16 - 24GB)
if [ ! -f "$COMFY_DIR/models/diffusion_models/krea2/krea2_turbo_bf16.safetensors" ]; then
    echo "🚀 Downloading Krea 2 Turbo BF16 Diffusion Model (~24GB)..."
    $HF_CLI download Comfy-Org/Krea-2 diffusion_models/krea2_turbo_bf16.safetensors --local-dir "$COMFY_DIR/models/diffusion_models/krea2"
    mv "$COMFY_DIR/models/diffusion_models/krea2/diffusion_models/krea2_turbo_bf16.safetensors" "$COMFY_DIR/models/diffusion_models/krea2/" 2>/dev/null || true
fi

# Text Encoder (Qwen3-VL - 4.5GB)
if [ ! -f "$COMFY_DIR/models/text_encoders/qwen3-vl-4b-heretic_int8.safetensors" ]; then
    echo "🚀 Downloading Qwen3-VL Text Encoder (~4.5GB)..."
    $HF_CLI download DreamFast/Qwen3-VL-4b-Heretic-ComfyUI qwen3-vl-4b-heretic_int8.safetensors --local-dir "$COMFY_DIR/models/text_encoders"
fi

# VAE
if [ ! -f "$COMFY_DIR/models/vae/qwen_image_vae.safetensors" ]; then
    echo "🚀 Downloading Qwen Image VAE..."
    $HF_CLI download Comfy-Org/Krea-2 vae/qwen_image_vae.safetensors --local-dir "$COMFY_DIR/models/vae"
    mv "$COMFY_DIR/models/vae/vae/qwen_image_vae.safetensors" "$COMFY_DIR/models/vae/" 2>/dev/null || true
fi

# LoRA (Outfit Transfer)
if [ ! -f "$COMFY_DIR/models/loras/krea2/krea_outfittransfer.safetensors" ]; then
    echo "🚀 Downloading Outfit Transfer LoRA..."
    $HF_CLI download AliveAi/Krea-2-Edit-Outfit-Transfer krea_outfittransfer.safetensors --local-dir "$COMFY_DIR/models/loras/krea2"
fi

# LoRA (Identity Edit)
if [ ! -f "$COMFY_DIR/models/loras/krea2/krea2_identity_edit_v1_2.safetensors" ]; then
    echo "🚀 Downloading Identity Edit LoRA..."
    $HF_CLI download conradlocke/krea2-identity-edit krea2_identity_edit_v1_2.safetensors --local-dir "$COMFY_DIR/models/loras/krea2"
fi

# Cleanup any nested empty directories created by hf-transfer paths
rm -rf "$COMFY_DIR/models/diffusion_models/krea2/diffusion_models" 2>/dev/null || true
rm -rf "$COMFY_DIR/models/vae/vae" 2>/dev/null || true

echo "======================================================="
echo "  🎉 KREA 2 TURBO BF16 INSTALLATION COMPLETE!          "
echo "======================================================="
