# Z Image Turbo v3 - RunPod Serverless Worker
# Based on the official worker-comfyui base image
FROM runpod/worker-comfyui:5.1.0-base

# ============================================
# SECURITY & ENVIRONMENT CONFIG
# ============================================
# Set security level to weak before initializing components
ENV COMFYUI_SECURITY_LEVEL=weak
ENV COMFY_HOME=/comfyui

# ============================================
# INSTALL CUSTOM NODES (MANUAL GIT CLONE)
# ============================================
RUN mkdir -p /comfyui/custom_nodes
# We clone these directly to ensure the correct folder structure
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ZHO-ZHO-ZHO/ComfyUI-Apex-Artist.git && \
    git clone https://github.com/rgthree/rgthree-comfy.git && \
    git clone https://github.com/ZHO-ZHO-ZHO/ComfyUI-Qwen-VL-Chat.git /comfyui/custom_nodes/comfyui-qwenvl && \
    git clone https://github.com/AIGODLIKE/ComfyUI-BlenderAI-node.git /comfyui/custom_nodes/seedvr2_videoupscaler && \
    git clone https://github.com/RamonGuthrie/ComfyUI-RBG-SmartSeedVariance.git

# Install requirements for the nodes
RUN pip install --no-cache-dir \
    -r /comfyui/custom_nodes/comfyui-qwenvl/requirements.txt \
    -r /comfyui/custom_nodes/seedvr2_videoupscaler/requirements.txt \
    -r /comfyui/custom_nodes/ComfyUI-RBG-SmartSeedVariance/requirements.txt || true

# ============================================
# DOWNLOAD MODELS
# ============================================

# Z Image Turbo UNET Model
RUN comfy model download \
    --url https://huggingface.co/Kijai/z-image-turbo-comfyui/resolve/main/z_image_turbo_bf16.safetensors \
    --relative-path models/diffusion_models \
    --filename z_image_turbo_bf16.safetensors

# CLIP Model
RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/z_image_turbo/resolve/d9885880b38188695c94f656eee9f76b3ea805f3/split_files/text_encoders/qwen_3_4b.safetensors \
    --relative-path models/clip \
    --filename qwen_3_4b.safetensors

# VAE Model (Ensure this path exists in your GitHub repo)
COPY models/vae/ae.safetensors /comfyui/models/vae/ae.safetensors

# SeedVR2 DiT Model
RUN comfy model download \
    --url https://huggingface.co/AInVFX/SeedVR2_comfyUI/resolve/main/seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors \
    --relative-path models/diffusion_models \
    --filename seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors

# SeedVR2 VAE Model
RUN comfy model download \
    --url https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors \
    --relative-path models/vae \
    --filename ema_vae_fp16.safetensors

# ============================================
# DOWNLOAD LoRA MODELS
# ============================================

RUN mkdir -p /comfyui/models/loras
RUN curl -L -H "Authorization: Bearer d8b952eca7f0b07f6df0a6f4095db084" \
    "https://civitai.com/api/download/models/2465980?type=Model&format=SafeTensor" \
    -o /comfyui/models/loras/NiceGirls_UltraReal.safetensors

# Copy local LoRAs
COPY loras/ /comfyui/models/loras/

# ============================================
# FINAL SETUP
# ============================================

COPY workflows/ /comfyui/workflows/