# STEP 1/19
FROM nvidia/cuda:13.0.0-cudnn-devel-ubuntu22.04

# STEP 2/19
ARG UID=1000
# STEP 3/19
ARG GID=1000

# STEP 4/19
# Dropped TORCH_BACKEND_ENABLE_CUDA_FLASH_ATTENTION, TORCH_ALLOW_TF32_CUBLAS,
# TORCH_ALLOW_TF32_CUDNN, and COMFYUI_USE_XFORMERS — none of these are
# recognized PyTorch/ComfyUI env vars, so they were no-ops.
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256 \
    NVIDIA_TF32_OVERRIDE=1 \
    PATH="/home/appuser/venv/bin:/home/appuser/.local/bin:${PATH}"

# STEP 5/19
USER root

# STEP 6/19
RUN groupadd -g ${GID} appuser && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash appuser

# STEP 7/19
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3-venv \
    python3-pip \
    python3.10-dev \
    curl \
    nodejs \
    npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# STEP 8/19
WORKDIR /workspace

# STEP 9/19
RUN git clone https://github.com/Comfy-Org/ComfyUI.git && \
    cd ComfyUI && \
    git checkout v0.24.0 && \
    mkdir -p temp models/checkpoints output user custom_nodes

# STEP 10/19
COPY entrypoint.sh /entrypoint.sh
# STEP 11/19
COPY auto_models.sh /auto_models.sh

# STEP 12/19
RUN chmod +x /entrypoint.sh /auto_models.sh && \
    chown -R appuser:appuser /workspace /home/appuser

# STEP 13/19
USER appuser

# STEP 14/19
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# STEP 15/19
WORKDIR /workspace/ComfyUI

# STEP 16/19
RUN --mount=type=cache,target=/home/appuser/.cache/uv,uid=1000,gid=1000,mode=0777 \
    python3 -m venv /home/appuser/venv && \
    . /home/appuser/venv/bin/activate && \
    uv pip install --upgrade pip && \
    uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cu130 && \
    uv pip install -r requirements.txt && \
    uv pip install gitpython && \
    uv pip install comfyui_manager==4.2.2

# STEP 17/19
EXPOSE 8188

# STEP 18/19
ENTRYPOINT ["/entrypoint.sh"]

# STEP 19/19
CMD ["python", "main.py", "--listen", "0.0.0.0"]