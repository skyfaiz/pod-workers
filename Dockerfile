# Z Image Turbo v3 - RunPod Serverless Worker
# Based on the official worker-comfyui base image
FROM runpod/worker-comfyui:5.1.0-base

# ============================================
# INSTALL CUSTOM NODES
# ============================================

# Core custom nodes from ComfyUI Registry
RUN comfy-node-install \
    comfyui-apex-artist \
    rgthree-comfy \
    comfyui-qwenvl \
    seedvr2_videoupscaler

# Install additional custom nodes from GitHub
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/RamonGuthrie/ComfyUI-RBG-SmartSeedVariance.git && \
    cd ComfyUI-RBG-SmartSeedVariance && \
    pip install -r requirements.txt 2>/dev/null || true

# ============================================
# DOWNLOAD MODELS
# ============================================

# Z Image Turbo UNET Model (place in unet folder)
# NOTE: Replace with actual download URL - this model needs to be sourced
RUN comfy model download \
    --url https://huggingface.co/Kijai/z-image-turbo-comfyui/resolve/main/z_image_turbo_bf16.safetensors \
    --relative-path models/unet \
    --filename z_image_turbo_bf16.safetensors

# CLIP Model - Qwen 3 4B for Lumina2
RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/z_image_turbo/resolve/d9885880b38188695c94f656eee9f76b3ea805f3/split_files/text_encoders/qwen_3_4b.safetensors \
    --relative-path models/clip \
    --filename qwen_3_4b.safetensors

# VAE Model (FLUX ae.safetensors) - Copy from local
COPY models/vae/ae.safetensors /comfyui/models/vae/ae.safetensors

# SeedVR2 DiT Model (for upscaling)
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

# Create loras directory
RUN mkdir -p /comfyui/models/loras

# NiceGirls_UltraReal LoRA from CivitAI
RUN curl -L -o /comfyui/models/loras/NiceGirls_UltraReal_v1.0_Z-Image_Turbo.safetensors \
    "https://civitai.com/api/download/models/2465980?type=Model&format=SafeTensor&token=d8b952eca7f0b07f6df0a6f4095db084"

# Copy local LoRAs (baked into image)
COPY loras/ /comfyui/models/loras/

# ============================================
# OPTIONAL: QwenVL Models (for prompt enhancement)
# These are only needed if you enable the prompt enhancement nodes
# ============================================

# Uncomment if using QwenVL prompt enhancement
# RUN pip install transformers accelerate qwen-vl-utils

# ============================================
# COPY WORKFLOW EXAMPLES (OPTIONAL)
# ============================================

# Copy example workflows for reference
COPY workflows/ /comfyui/workflows/

# Copy any static input images (if needed)
# COPY input/ /comfyui/input/

# Set environment variables
ENV COMFY_HOME=/comfyui

# The base image already includes the handler and startup script
# No custom handler needed - it accepts input.workflow directly
