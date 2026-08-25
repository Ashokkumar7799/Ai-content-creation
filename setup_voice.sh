#!/bin/bash
# ---------------------------------------------------------
# F5-TTS (TELUGU) AUTOMATIC INSTALLER
# ---------------------------------------------------------

WORKSPACE="$HOME/LTX_Workspace"
F5_DIR="$WORKSPACE/F5-TTS-Telugu"
VENV_DIR="$F5_DIR/venv_voice"
PIP="$VENV_DIR/bin/pip"
PYTHON="$VENV_DIR/bin/python"

echo "======================================================="
echo "  🚀 INITIALIZING F5-TTS TELUGU INSTALLATION "
echo "======================================================="

mkdir -p "$F5_DIR"

# 1. Create Isolated Environment
if [ ! -d "$VENV_DIR" ]; then
    echo "⚙️ Creating isolated venv_voice..."
    python3 -m venv "$VENV_DIR"
    $PIP install --upgrade pip
    
    echo "⚙️ Installing F5-TTS, Gradio, and dependencies..."
    # Install F5-TTS from GitHub as requested
    $PIP install -q git+https://github.com/SWivid/F5-TTS.git
    $PIP install -q huggingface-hub --upgrade
    $PIP install -q gradio
else
    echo "✅ venv_voice already exists!"
fi

# 2. Setup Models Directory
mkdir -p "$F5_DIR/models/telugu_model/F5TTS_v1_Base"

# 3. Download Telugu Models
echo "======================================================="
echo "  ⚡ DOWNLOADING TELUGU F5-TTS MODELS "
echo "======================================================="

export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_XET_HIGH_PERFORMANCE=1

# Install hf-transfer for fast downloads if missing
if ! $PIP show hf-transfer > /dev/null 2>&1; then
    $PIP install -q hf-transfer
fi

if [ ! -f "$F5_DIR/models/telugu_model/F5TTS_v1_Base/model_250000.pt" ]; then
    echo "🚀 Downloading F5-TTS Telugu Model Checkpoint..."
    $VENV_DIR/bin/hf download CallWhiz/F5-TTS-TELUGU F5TTS_v1_Base/model_250000.pt --local-dir "$F5_DIR/models/telugu_model"
fi

if [ ! -f "$F5_DIR/models/telugu_model/F5TTS_v1_Base/vocab.txt" ]; then
    echo "🚀 Downloading Telugu Vocab File..."
    $VENV_DIR/bin/hf download CallWhiz/F5-TTS-TELUGU F5TTS_v1_Base/vocab.txt --local-dir "$F5_DIR/models/telugu_model"
fi

echo "======================================================="
echo "  🎉 F5-TTS INSTALLATION COMPLETE! "
echo "======================================================="
