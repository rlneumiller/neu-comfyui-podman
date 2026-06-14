#!/usr/bin/env bash
set -e

mkdir -p /workspace/ComfyUI/user /workspace/ComfyUI/user/default
chown -R "$(id -u)":"$(id -g)" /workspace/ComfyUI/user || true
chmod -R u+rwX /workspace/ComfyUI/user || true

export PIP_CACHE_DIR="$HOME/.cache/pip"

echo "↳ Launching ComfyUI"
exec "$@"
