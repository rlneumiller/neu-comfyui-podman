#!/usr/bin/env bash
set -euo pipefail

CKPT_DIR="/workspace/ComfyUI/models/checkpoints"
CKPT_NAME="DreamShaper_8_pruned.safetensors"
CKPT_PATH="${CKPT_DIR}/${CKPT_NAME}"
HF_REPO="Lykon/DreamShaper"
CKPT_URL="https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors"

# Works for our purposes when this script was authored, 
# but may not work for all cases, since grep and ripgrep
# are not 100% compatible.
if command -v rg >/dev/null 2>&1; then
  shopt -s expand_aliases
  alias grep='rg'
fi

CACHE_PATTERN="\"repo_id\": \"${HF_REPO}\""

mkdir -p "${CKPT_DIR}"

if [ -f "${CKPT_PATH}" ]; then
  echo "↳ Checkpoint already present: ${CKPT_PATH}"
  exit 0
fi

if command -v hf >/dev/null 2>&1; then
  echo "↳ Using Hugging Face CLI to fetch ${CKPT_NAME}..."

  HF_CACHE_HIT=false
  if hf cache ls --format json 2>/dev/null | "${CACHE_GREP_CMD[@]}" "${CACHE_PATTERN}"; then
    HF_CACHE_HIT=true
  fi

  if [ "${HF_CACHE_HIT}" = true ]; then
    echo "↳ Found ${HF_REPO} in local Hugging Face cache. Restoring from cache..."
  else
    echo "↳ ${HF_REPO} not present in local cache. Downloading from Hugging Face Hub..."
  fi

  if hf download "${HF_REPO}" "${CKPT_NAME}" --local-dir "${CKPT_DIR}"; then
    if [ "${HF_CACHE_HIT}" = true ]; then
      echo "↳ Checkpoint restored from local cache: ${CKPT_PATH}"
    else
      echo "↳ Checkpoint downloaded from Hugging Face Hub: ${CKPT_PATH}"
    fi
    exit 0
  fi

  echo "↳ hf download failed, falling back to curl..."
fi

echo "↳ Downloading ${CKPT_NAME} directly..."
tmp="${CKPT_PATH}.tmp"
curl -L "${CKPT_URL}" -o "${tmp}"
mv "${tmp}" "${CKPT_PATH}"
echo "↳ Download complete."
