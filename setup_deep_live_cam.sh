#!/bin/bash

echo "======================================================="
echo " DEEP-LIVE-CAM (FACE SWAPPER) SETUP SCRIPT"
echo "======================================================="

cd ~/LTX_Workspace

echo "--- 1. CLONING DEEP-LIVE-CAM ---"
if [ ! -d "Deep-Live-Cam" ]; then
    git clone https://github.com/hacksider/Deep-Live-Cam.git
fi

cd Deep-Live-Cam

echo "--- 2. CREATING ISOLATED VIRTUAL ENVIRONMENT ---"
echo "(This safely quarantines Deep-Live-Cam so it cannot break ComfyUI!)"
if [ ! -d "venv_face" ]; then
    python3.12 -m venv venv_face
fi

# Activate the venv for the rest of the script
source venv_face/bin/activate

echo "--- 3. INSTALLING DEPENDENCIES ---"
sudo apt-get update -qq && sudo apt-get install -y -qq libgl1 libglib2.0-0 libegl1 libxcb-cursor0 ffmpeg
pip install --upgrade pip
pip install nvidia-cublas-cu12 nvidia-cudnn-cu12
pip install -r requirements.txt
# Deep-Live-Cam needs onnxruntime-gpu for Nvidia acceleration (CUDA 12 build)
pip install onnxruntime-gpu --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/

echo "--- 4. DOWNLOADING MODELS ---"
mkdir -p models

if [ ! -f "models/inswapper_128.onnx" ]; then
    echo "Downloading inswapper_128..."
    wget -q --show-progress -O models/inswapper_128.onnx "https://huggingface.co/ezioruan/inswapper_128.onnx/resolve/main/inswapper_128.onnx"
fi

if [ ! -f "models/gfpgan-1024.onnx" ]; then
    echo "Downloading gfpgan-1024.onnx..."
    wget -q --show-progress -O models/gfpgan-1024.onnx "https://huggingface.co/hacksider/deep-live-cam/resolve/main/gfpgan-1024.onnx"
fi

echo "======================================================="
echo "✅ INSTALLATION COMPLETE! HOW TO RUN IT:"
echo "======================================================="
echo "Whenever you want to swap a face, run these commands:"
echo ""
echo "cd ~/LTX_Workspace/Deep-Live-Cam"
echo "source venv_face/bin/activate"
echo "python run.py -s \"/path/to/selfie.jpg\" -t \"../ComfyUI/output/generated_video.mp4\" -o \"final_swapped_video.mp4\" --execution-provider cuda --frame-processor face_swapper face_enhancer"
echo "======================================================="
