#!/usr/bin/env bash
set -e

CKPT_DIR="/workspace/ComfyUI/models/checkpoints"
CKPT_NAME="DreamShaper_8_pruned.safetensors"
CKPT_PATH="${CKPT_DIR}/${CKPT_NAME}"
CKPT_URL="https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors"

mkdir -p "${CKPT_DIR}"

if [ ! -f "${CKPT_PATH}" ]; then
  echo "↳ Downloading ${CKPT_NAME}..."
  tmp="${CKPT_PATH}.tmp"
  curl -L "${CKPT_URL}" -o "${tmp}"
  mv "${tmp}" "${CKPT_PATH}"
  echo "↳ Download complete."
else
  echo "↳ Checkpoint already present: ${CKPT_PATH}"
fi
