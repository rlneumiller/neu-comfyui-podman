# STEP 1/25
FROM nvidia/cuda:13.0.0-cudnn-devel-ubuntu22.04

# STEP 2/25
ARG UID=1000

# STEP 3/25
ARG GID=1000

# STEP 4/25
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256 \
    NVIDIA_TF32_OVERRIDE=1 \
    COMFYUI_RELEASE_BRANCH="release/v0.25"

# Required to workaround a buildah issue involving variable expansion in ENV instructions.
# STEP 5/25
ENV PATH="/home/appuser/venv/bin:/home/appuser/.local/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"    

# STEP 6/25
USER root

# STEP 7/25
RUN groupadd -g ${GID} appuser && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash appuser

# STEP 8/25
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3-venv \
    python3-pip \
    python3.10-dev \
    curl \
    nodejs \
    npm \
    ripgrep \
    fd-find \
    && ln -s /usr/bin/fdfind /usr/bin/fd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# STEP 9/25
WORKDIR /workspace

# STEP 10/25
RUN git clone https://github.com/Comfy-Org/ComfyUI.git && \
    cd ComfyUI && \
    git checkout -b ${COMFYUI_RELEASE_BRANCH} origin/${COMFYUI_RELEASE_BRANCH} && \
    mkdir -p temp models/checkpoints output user custom_nodes && \
    cd custom_nodes && \
    git clone https://github.com/city96/ComfyUI-GGUF


# STEP 11/25
COPY entrypoint.sh /entrypoint.sh

# STEP 12/25
COPY auto_models.sh /auto_models.sh

# STEP 13/25
RUN chmod +x /entrypoint.sh /auto_models.sh && \
    chown -R appuser:appuser /workspace /home/appuser

# STEP 14/25
RUN mkdir -p /home/appuser/.cache/uv && \
    chown -R appuser:appuser /home/appuser/.cache

# STEP 15/25
USER appuser

# STEP 16/25
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# STEP 17/25
WORKDIR /workspace/ComfyUI

# Install BASE ComfyUI dependencies first
# STEP 18/25
RUN --mount=type=cache,target=/home/appuser/.cache/uv,uid=1000,gid=1000,mode=0777 \
    python3 -m venv /home/appuser/venv && \
    uv pip install --python /home/appuser/venv/bin/python --upgrade pip && \
    uv pip install --python /home/appuser/venv/bin/python torch torchvision --index-url https://download.pytorch.org/whl/cu124 && \
    uv pip install --python /home/appuser/venv/bin/python -r requirements.txt

# Clone custom nodes
# STEP 19/25
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/city96/ComfyUI-GGUF

# STEP 20/25
RUN --mount=type=cache,target=/home/appuser/.cache/uv,uid=1000,gid=1000,mode=0777 \
    python3 -m venv /home/appuser/venv && \
    . /home/appuser/venv/bin/activate && \
    uv pip install --upgrade pip && \
    uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cu130 && \
    uv pip install --upgrade gguf && \
    uv pip install -r requirements.txt
    
# Install custom node dependencies
# STEP 21/25
RUN --mount=type=cache,target=/home/appuser/.cache/uv,uid=1000,gid=1000,mode=0777 \
    uv pip install --python /home/appuser/venv/bin/python --upgrade gguf && \
    uv pip install --python /home/appuser/venv/bin/python -r custom_nodes/ComfyUI-GGUF/requirements.txt

# Reset ComfyUI database to avoid Alembic migration errors
# STEP 22/25
RUN rm -f /workspace/ComfyUI/comfyui.db

# STEP 23/25
EXPOSE 8188

# STEP 24/25
ENTRYPOINT ["/entrypoint.sh"]

# STEP 25/25
CMD ["python", "main.py", "--listen", "0.0.0.0"]
