#!/bin/bash

# Define paths
WORKSPACE="$HOME/LTX_Workspace"
COMFY_DIR="$WORKSPACE/ComfyUI"
DEEP_LIVE_DIR="$WORKSPACE/Deep-Live-Cam"

echo "=========================================="
echo " 🚀 AI SUPERCOMPUTER MASTER LAUNCHER"
echo "=========================================="
echo "1. FLUX.2 (Images - FP8 Optimized)"
echo "2. LTX-2.3 (Video Generation)"
echo "3. SeedVR2 Upscaler"
echo "4. Deep-Live-Cam (Flask Face Swapper)"
echo "5. Wan 2.2 (Video Generation - 14B)"
echo "=========================================="
read -p "Select a workflow (1-5): " option

# Master Kill Switch: When Ctrl+C is pressed, aggressively kill all child processes
trap "echo -e '\n🛑 Master Kill Switch Activated! Stopping all services...'; pkill -f main.py 2>/dev/null; pkill -f face_swap_app.py 2>/dev/null; pkill -f pinggy 2>/dev/null; pkill -f hf 2>/dev/null; pkill -P $$ 2>/dev/null; exit 1" SIGINT SIGTERM

# Cleanup old processes safely
echo "🧹 Cleaning up old connections..."
fuser -k 8188/tcp 2>/dev/null || true
fuser -k 5000/tcp 2>/dev/null || true
pkill -f main.py 2>/dev/null || true
pkill -f face_swap_app.py 2>/dev/null || true
pkill -f pinggy 2>/dev/null || true
sleep 2

# Pinggy auto-reconnect function
start_pinggy() {
    local port=$1
    echo ""
    echo "=========================================="
    echo " 🌐 STARTING PINGGY TUNNEL ON PORT $port"
    echo "=========================================="
    while true; do
        pkill -f pinggy 2>/dev/null || true
        ssh -o StrictHostKeyChecking=no -p 443 -R0:localhost:$port a.pinggy.io > pinggy_url.txt 2>/dev/null &
        sleep 4
        echo -e "\n🟢 YOUR SECURE PUBLIC URL IS:"
        cat pinggy_url.txt
        echo "=========================================="
        sleep 3500
    done
}

case $option in
    1)
        echo "🚀 Initializing FLUX.2 Workflow..."
        if [ ! -f "$COMFY_DIR/models/diffusion_models/flux2_dev_fp8mixed.safetensors" ]; then
            echo "⚠️ FLUX.2 FP8 models not found! Downloading automatically..."
            cd "$WORKSPACE" && bash setup_flux2_fp8.sh
        fi
        echo "✅ Models verified. Starting ComfyUI on standard venv..."
        cd "$COMFY_DIR"
        venv/bin/python main.py --listen 0.0.0.0 --port 8188 &
        start_pinggy 8188
        ;;
    2)
        echo "🚀 Initializing LTX-2.3 Workflow..."
        if [ ! -f "$COMFY_DIR/models/diffusion_models/ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors" ]; then
            echo "⚠️ LTX-2.3 models not found! Downloading automatically..."
            cd "$WORKSPACE" && bash setup_ltx_models.sh
        fi
        echo "✅ Models verified. Starting ComfyUI on standard venv..."
        cd "$COMFY_DIR"
        venv/bin/python main.py --listen 0.0.0.0 --port 8188 &
        start_pinggy 8188
        ;;
    3)
        echo "🚀 Initializing SeedVR2 Upscaler Workflow..."
        if [ ! -f "$COMFY_DIR/models/SEEDVR2/seedvr2_ema_7b_fp16.safetensors" ]; then
            echo "⚠️ SeedVR2 FP16 Model not found!"
            echo "Downloading it now (16GB file)..."
            mkdir -p "$COMFY_DIR/models/SEEDVR2"
            ~/.local/bin/hf download numz/SeedVR2_comfyUI seedvr2_ema_7b_fp16.safetensors --local-dir "$COMFY_DIR/models/SEEDVR2"
        fi
        echo "✅ Starting ComfyUI on Upscaler Environment..."
        cd "$COMFY_DIR"
        venv_upscaler/bin/python main.py --listen 0.0.0.0 --port 8188 &
        start_pinggy 8188
        ;;
    4)
        echo "🚀 Initializing Deep-Live-Cam Web App..."
        if [ ! -d "$DEEP_LIVE_DIR/venv_face" ]; then
            echo "⚠️ Deep-Live-Cam not set up! Running installer..."
            cd "$WORKSPACE" && bash setup_deep_live_cam.sh
        fi
        
        echo "✅ Starting Flask App on Quarantined Environment..."
        cd "$DEEP_LIVE_DIR"
        
        # Ensure flask is installed quietly
        venv_face/bin/pip install -q flask werkzeug
        
        # Start the Flask app
        venv_face/bin/python face_swap_app.py &
        start_pinggy 5000
        ;;
    5)
        echo "🚀 Initializing Wan 2.2 Workflow..."
        if [ ! -f "$COMFY_DIR/models/diffusion_models/WanVideo/2_2/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors" ] || [ ! -d "$COMFY_DIR/venv_wan" ]; then
            echo "⚠️ Wan 2.2 environment or models missing! Setting up automatically..."
            cd "$WORKSPACE" && bash setup_wan22.sh
        fi
        echo "✅ Models verified. Starting ComfyUI on Quarantined Wan Environment..."
        cd "$COMFY_DIR"
        venv_wan/bin/python main.py --listen 0.0.0.0 --port 8188 &
        start_pinggy 8188
        ;;
    *)
        echo "❌ Invalid option selected."
        ;;
esac
