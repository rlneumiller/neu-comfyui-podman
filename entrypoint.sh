#!/usr/bin/env bash

set -e

mkdir -p /workspace/ComfyUI/user /workspace/ComfyUI/user/default
chmod -R u+rwX /workspace/ComfyUI/user || true

export PIP_CACHE_DIR="$HOME/.cache/pip"

# Ensure uv cache is accessible by appuser during runtime
export UV_CACHE_DIR=/tmp/uv-cache
mkdir -p /tmp/uv-cache
chmod 777 /tmp/uv-cache

echo "↳ Launching ComfyUI"

# Since this entrypoint is executed just before the CMD instruction, 
# tell the container to pass control over to args as defined in the 
# CMD instruction sequence that follows this entrypoint in the Containerfile. 
exec "$@"

