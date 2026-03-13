# Z Image Turbo v8 - Ultra-Stable Build
# Based on the official worker-comfyui base image
FROM runpod/worker-comfyui:5.1.0-base

# ============================================
# 1. ENVIRONMENT & SECURITY CONFIG
# ============================================
ENV COMFYUI_SECURITY_LEVEL=weak
ENV COMFY_HOME=/comfyui

# =========================================
# 2. INSTALL CUSTOM NODES (SEPARATED STEPS)
# ============================================
# We create the folder first to ensure it's there for all following steps
RUN mkdir -p /comfyui/custom_nodes

RUN rm -rf /comfyui/custom_nodes/ComfyUI-Apex-Artist
RUN git clone https://github.com/ZHO-ZHO-ZHO/ComfyUI-Apex-Artist.git /comfyui/custom_nodes/ComfyUI-Apex-Artist

RUN rm -rf /comfyui/custom_nodes/rgthree-comfy
RUN git clone https://github.com/rgthree/rgthree-comfy.git /comfyui/custom_nodes/rgthree-comfy

RUN rm -rf /comfyui/custom_nodes/comfyui-qwenvl
RUN git clone https://github.com/ZHO-ZHO-ZHO/ComfyUI-Qwen-VL-Chat.git /comfyui/custom_nodes/comfyui-qwenvl

RUN rm -rf /comfyui/custom_nodes/seedvr2_videoupscaler
RUN git clone https://github.com/AIGODLIKE/ComfyUI-BlenderAI-node.git /comfyui/custom_nodes/seedvr2_videoupscaler

RUN rm -rf /comfyui/custom_nodes/ComfyUI-RBG-SmartSeedVariance
RUN git clone https://github.com/RamonGuthrie/ComfyUI-RBG-SmartSeedVariance.git /comfyui/custom_nodes/ComfyUI-RBG-SmartSeedVariance

# ============================================
# 3. INSTALL REQUIREMENTS
# ============================================
RUN pip install --no-cache-dir -r /comfyui/custom_nodes/comfyui-qwenvl/requirements.txt || true
RUN pip install --no-cache-dir -r /comfyui/custom_nodes/seedvr2_videoupscaler/requirements.txt || true
RUN pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-RBG-SmartSeedVariance/requirements.txt || true
# ============================================
# 3. DOWNLOAD MODELS
# ============================================

# Z Image Turbo UNET Model
RUN comfy model download \
    --url https://huggingface.co/Kijai/z-image-turbo-comfyui/resolve/main/z_image_turbo_bf16.safetensors \
    --relative-path models/diffusion_models \
    --filename z_image_turbo_bf16.safetensors

# CLIP Model - Qwen 3 4B for Lumina2
RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/z_image_turbo/resolve/d9885880b38188695c94f656eee9f76b3ea805f3/split_files/text_encoders/qwen_3_4b.safetensors \
    --relative-path models/clip \
    --filename qwen_3_4b.safetensors

# VAE Model (ae.safetensors)
COPY models/vae/ae.safetensors /comfyui/models/vae/ae.safetensors

# SeedVR2 Models
RUN comfy model download \
    --url https://huggingface.co/AInVFX/SeedVR2_comfyUI/resolve/main/seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors \
    --relative-path models/diffusion_models \
    --filename seedvr2_ema_7b_fp8_e4m3fn_mixed_block35_fp16.safetensors

RUN comfy model download \
    --url https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors \
    --relative-path models/vae \
    --filename ema_vae_fp16.safetensors

# ============================================
# 4. DOWNLOAD LoRA MODELS & ASSETS
# ============================================
RUN mkdir -p /comfyui/models/loras
RUN curl -L -H "Authorization: Bearer d8b952eca7f0b07f6df0a6f4095db084" \
    "https://civitai.com/api/download/models/2465980?type=Model&format=SafeTensor" \
    -o /comfyui/models/loras/NiceGirls_UltraReal.safetensors

COPY loras/ /comfyui/models/loras/
COPY workflows/ /comfyui/workflows/