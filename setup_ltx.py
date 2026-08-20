import os
import shutil
import subprocess

# ---------------------------------------------------------
# LTX DIRECTOR SETUP SCRIPT (VM / LINUX EDITION)
# Run this once in your terminal to install everything.
# ---------------------------------------------------------

def run_cmd(cmd):
    print(f"Running: {cmd}")
    subprocess.run(cmd, shell=True, check=True)

# 1. Install System Dependencies & aria2
print("\n⚙️ Installing System Dependencies...")
run_cmd("sudo apt-get update -qq && sudo apt-get install -y -qq aria2 python3-pip python3-venv")

# 2. Clone ComfyUI and Install PyTorch
# CHANGED: Use the home directory instead of Google Colab's /content
WORKSPACE = os.path.expanduser("~/LTX_Workspace")
if not os.path.exists(f"{WORKSPACE}/ComfyUI"):
    os.makedirs(WORKSPACE, exist_ok=True)
    os.chdir(WORKSPACE)
    print("\n⚙️ Cloning ComfyUI...")
    run_cmd("git clone https://github.com/comfyanonymous/ComfyUI.git")

os.chdir(f"{WORKSPACE}/ComfyUI")
print("\n⚙️ Setting up Python Virtual Environment and installing PyTorch...")
if not os.path.exists("venv"):
    run_cmd("python3 -m venv venv")

PIP = os.path.abspath("venv/bin/pip")

run_cmd(f"{PIP} install --upgrade pip")
run_cmd(f"{PIP} install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121")
run_cmd(f"{PIP} install -r requirements.txt")

# 3. Install Required AI Math Packages
run_cmd(f"{PIP} install xformers diffusers accelerate transformers huggingface_hub gguf ftfy")

# 4. Install all Custom Nodes
print("\n⚙️ Installing Custom Nodes...")
nodes = [
    "https://github.com/ltdrdata/ComfyUI-Manager.git",
    "https://github.com/WhatDreamscost/WhatDreamsCost-ComfyUI.git",
    "https://github.com/kijai/ComfyUI-KJNodes.git",
    "https://github.com/kijai/ComfyUI-LTXVideo.git", # Good to have for base LTX operations
]

for repo in nodes:
    node_name = repo.split("/")[-1].replace(".git", "")
    dest = f"custom_nodes/{node_name}"
    if not os.path.exists(dest):
        run_cmd(f"git clone {repo} {dest}")
    if os.path.exists(f"{dest}/requirements.txt"):
        run_cmd(f"{PIP} install -r {dest}/requirements.txt || true")

# 5. Download All Required Models
print("\n⚙️ Installing hf-transfer for max download speed...")
run_cmd(f"{PIP} install -q hf-transfer")
os.environ["HF_HUB_ENABLE_HF_TRANSFER"] = "1"

hf_models = [
    # Diffusion model
    (
        "Kijai/LTX2.3_comfy",
        "diffusion_models/ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors",
        "models/diffusion_models",
        "ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors"
    ),
    # Upscaler
    (
        "Lightricks/LTX-2.3",
        "ltx-2.3-spatial-upscaler-x2-1.1.safetensors",
        "models/latent_upscale_models",
        "ltx-2.3-spatial-upscaler-x2-1.1.safetensors"
    ),
    # Loras
    (
        "TenStrip/LTX2.3_Distilled_Lora_1.1_Experiments",
        "ltx-2.3-22b-distilled-lora-1.1_fro90_ceil72_condsafe.safetensors",
        "models/loras",
        "ltx-2.3-22b-distilled-lora-1.1_fro90_ceil72_condsafe.safetensors"
    ),
    (
        "WarmBloodAban/Singularity-LTX-2.3_OmniCine_V1",
        "Singularity LTX-2.3  OmniCine Preview v0.1.safetensors",
        "models/loras",
        "Singularity LTX-2.3  OmniCine Preview v0.1.safetensors"
    ),
    (
        "joyfox/LTX2.3-ICEdit-Insight",
        "ltx2.3-ic-subtitles-remove-general.safetensors",
        "models/loras",
        "ltx2.3-ic-subtitles-remove-general.safetensors"
    ),
    # Text encoders
    (
        "GitMylo/LTX-2-comfy_gemma_fp8_e4m3fn",
        "gemma_3_12B_it_fp8_e4m3fn.safetensors",
        "models/text_encoders",
        "gemma_3_12B_it_fp8_e4m3fn.safetensors"
    ),
    (
        "Kijai/LTX2.3_comfy",
        "text_encoders/ltx-2.3_text_projection_bf16.safetensors",
        "models/text_encoders",
        "ltx-2.3_text_projection_bf16.safetensors"
    ),
    (
        "Comfy-Org/ltx-2",
        "split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors",
        "models/text_encoders",
        "gemma_3_12B_it_fp4_mixed.safetensors"
    ),
    # VAE
    (
        "Kijai/LTX2.3_comfy",
        "vae/LTX23_audio_vae_bf16.safetensors",
        "models/vae",
        "LTX23_audio_vae_bf16.safetensors"
    ),
    (
        "Kijai/LTX2.3_comfy",
        "vae/LTX23_video_vae_bf16.safetensors",
        "models/vae",
        "LTX23_video_vae_bf16.safetensors"
    ),
    (
        "Kijai/LTX2.3_comfy",
        "vae/taeltx2_3.safetensors",
        "models/vae",
        "taeltx2_3.safetensors"
    )
]

for repo, path, dest, filename in hf_models:
    os.makedirs(dest, exist_ok=True)
    final_path = os.path.join(dest, filename)

    if not os.path.exists(final_path):
        print(f"\n⚡ [hf-transfer] Downloading {filename}...")
        try:
            # We use double quotes around paths to handle spaces safely
            run_cmd(f'huggingface-cli download {repo} "{path}" --local-dir {dest}')
        except subprocess.CalledProcessError:
            print(f"⚠️ Direct download failed for {filename}. Retrying with wget...")
            url_path = path.replace(" ", "%20")
            direct_url = f"https://huggingface.co/{repo}/resolve/main/{url_path}?download=true"
            run_cmd(f'wget -c --show-progress -O "{final_path}" "{direct_url}"')

        # Move files to root of the dest folder (if nested)
        downloaded_path = os.path.join(dest, path)
        if downloaded_path != final_path and os.path.exists(downloaded_path):
            os.rename(downloaded_path, final_path)

        # Clean up empty nested folders (like 'vae/' or 'split_files/')
        if "/" in path:
            top_folder = path.split("/")[0]
            folder_to_delete = os.path.join(dest, top_folder)
            if os.path.exists(folder_to_delete) and os.path.isdir(folder_to_delete):
                shutil.rmtree(folder_to_delete)
    else:
        print(f"\n✅ Skipping {filename}, already exists.")

print("\n=======================================================")
print("  🎉 ALL LTX MODELS & NODES INSTALLED SUCCESSFULLY! ")
print("=======================================================")

