"""
Z Image Turbo - RunPod Handler

This is a minimal handler for GitHub integration deployment.
Since we use the base worker-comfyui image, the actual handler logic
is already included in the base image.

This file simply re-exports the base handler for RunPod GitHub integration.
"""

# The base worker-comfyui image already has the handler at /handler.py
# For GitHub integration, we need this file to exist, but the actual
# handler logic comes from the base image.

# If you need custom preprocessing, you can add it here:
# import runpod
# from some_module import handler as base_handler
# runpod.serverless.start({"handler": base_handler})

# For now, this file serves as a placeholder to satisfy GitHub integration
# requirements. The Dockerfile will use the base image's handler.
