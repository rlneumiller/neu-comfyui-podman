# Works but should probably check first
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

podman run -it --rm --name comfyui \
 --device nvidia.com/gpu=all \
 --security-opt label=disable \
 --userns=keep-id -p 8188:8188 \
 -e PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256 \
 -v ~/.cache/huggingface:/root/.cache/huggingface \
 -v ~/comfyui/models:/workspace/ComfyUI/models:Z \
 -v ~/comfyui/output:/workspace/ComfyUI/output:Z \
 -v ~/comfyui/custom_nodes:/workspace/ComfyUI/custom_nodes:Z \
 -v ~/comfyui/settings:/workspace/ComfyUI/user:Z \
 -v ~/comfyui/temp:/workspace/ComfyUI/temp:Z \
 localhost/comfyui-v0.25.0:commit-e16c3d25-gguf
