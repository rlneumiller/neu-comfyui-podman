#!/bin/bash
TAG_FILE="/home/arrel/gits/neu-comfyui-podman/.image_tag"

if [ ! -s "$TAG_FILE" ]; then
    echo "The .image_tag file is missing or empty. Perhaps you need to run neu-build-image.sh first?"
    exit 1
fi

COMFYUI_IMAGE_TAG=$(cat "$TAG_FILE")
echo "Starting image: $COMFYUI_IMAGE_TAG"

podman run -it --rm --name comfyui \
 --device nvidia.com/gpu=all \
 --security-opt label=disable \
 --userns=keep-id -p 8188:8188 \
 -e PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256 \
 -e HF_HOME=/home/appuser/.cache/huggingface \
 -v ~/.cache/huggingface:/home/appuser/.cache/huggingface:Z \
 -v ~/comfyui/models:/workspace/ComfyUI/models:Z \
 -v ~/comfyui/output:/workspace/ComfyUI/output:Z \
 -v ~/comfyui/custom_nodes:/workspace/ComfyUI/custom_nodes:Z \
 -v ~/comfyui/settings:/workspace/ComfyUI/user:Z \
 -v ~/comfyui/temp:/workspace/ComfyUI/temp:Z \
 localhost/$COMFYUI_IMAGE_TAG

# Intentional dev fail-safe to force re-evaluation before the next run.
# This prevents my internal autopilot from restarting the container with
# an outdated image tag and wasting my time debugging spurious issues.
if [ -s "$TAG_FILE" ]; then
    echo "Removing .image_tag file to prevent autopilot restarts."
    rm "$TAG_FILE"
fi
