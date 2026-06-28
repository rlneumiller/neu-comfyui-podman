#!/usr/bin/env bash

set -e

# Ensure user directory structure exists (for workflows)
mkdir -p /workspace/ComfyUI/user/default/workflows

# Ensure input/output/custom_nodes directories exist
mkdir -p /workspace/ComfyUI/input /workspace/ComfyUI/output /workspace/ComfyUI/custom_nodes

# Set permissions for mounted volumes
chmod -R u+rwX /workspace/ComfyUI/user /workspace/ComfyUI/input /workspace/ComfyUI/output /workspace/ComfyUI/custom_nodes 2>/dev/null || true

export PIP_CACHE_DIR="$HOME/.cache/pip"
export UV_CACHE_DIR=/tmp/uv-cache
mkdir -p /tmp/uv-cache
chmod 777 /tmp/uv-cache

echo "↳ Launching ComfyUI"

exec "$@"