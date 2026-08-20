#!/bin/bash
# ISOLATED UPSCALER INSTALLER (Creates venv_upscaler)

cd ~/LTX_Workspace/ComfyUI

echo "🌱 Creating brand new isolated environment (venv_upscaler)..."
python3.12 -m venv venv_upscaler
source venv_upscaler/bin/activate

echo "🔧 Forcing PIP installation into the new environment..."
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12
python3.12 -m pip install --upgrade pip

echo "🚀 Installing cutting-edge Blackwell PyTorch 2.14 Nightly..."
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu130

echo "📦 Installing ComfyUI base requirements..."
pip install -r requirements.txt

echo "🎥 Installing Video and Math Packages..."
pip install imageio[ffmpeg] imageio-ffmpeg huggingface_hub

echo "⚙️ Installing VideoHelperSuite..."
cd custom_nodes
if [ ! -d "ComfyUI-VideoHelperSuite" ]; then
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
    pip install -r ComfyUI-VideoHelperSuite/requirements.txt || true
fi

echo "⚙️ Installing SeedVR2 Upscaler..."
if [ ! -d "ComfyUI-SeedVR2_VideoUpscaler" ]; then
    git clone https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler.git
    pip install -r ComfyUI-SeedVR2_VideoUpscaler/requirements.txt || true
fi
cd ..

echo "📥 Downloading 4x-UltraSharp model..."
mkdir -p models/upscale_models
wget -q -nc --show-progress -O models/upscale_models/4x-UltraSharp.pth https://huggingface.co/lokcx/4x-Ultrasharp/resolve/main/4x-UltraSharp.pth

echo ""
echo "======================================================="
echo "✅ ISOLATED UPSCALER INSTALLATION COMPLETE!"
echo "======================================================="
echo "Now run 'bash swap_env.sh', choose Option 3 to activate the Upscaler,"
echo "and then run 'bash run_comfy.sh' to start!"
