FROM docker.io/modular/max-nvidia-full:nightly

ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# For SDXL / Flux optimized attention
ENV COMFYUI_USE_XFORMERS=1
ENV TORCH_BACKEND_ENABLE_CUDA_FLASH_ATTENTION=1
ENV PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256
ENV NVIDIA_TF32_OVERRIDE=1
ENV TORCH_ALLOW_TF32_CUBLAS=1
ENV TORCH_ALLOW_TF32_CUDNN=1

# Create user
RUN groupadd -g ${GID} appuser && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash appuser

USER root
RUN mkdir -p /workspace && chown -R appuser:appuser /workspace
USER appuser
WORKDIR /workspace

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*
USER appuser

# Python venv
RUN python3 -m venv /home/appuser/venv
ENV PATH=/home/appuser/venv/bin:$PATH



USER root
RUN git clone https://github.com/Comfy-Org/ComfyUI.git

USER appuser
WORKDIR /workspace/ComfyUI
# Checkout ComfyUI v0.24.0
USER root
RUN git checkout v0.24.0
USER appuser

RUN pip install --upgrade pip

#pytorch provides cuda 13.0 and 13.2 wheels, but not 13.1, so we have to use the 13.2 ones which should be compatible with 13.1 drivers
RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cu132

# Install xformers
RUN pip install xformers==0.0.27.post2

# Install ComfyUI deps
RUN pip install -r requirements.txt

# I think manager is included in the main repo now, so this is probably not needed
# Install ComfyUI Manager
#WORKDIR /workspace/ComfyUI/custom_nodes
#RUN git clone https://github.com//ComfyUI-Manager.git

#WORKDIR /workspace/ComfyUI
#RUN pip install -r manager_requirements.txt

# Bind‑mountable dirs
USER root
RUN mkdir -p models/checkpoints output user custom_nodes
USER appuser

COPY entrypoint.sh /entrypoint.sh
COPY auto_models.sh /auto_models.sh

USER root
RUN chmod +x /entrypoint.sh /auto_models.sh
USER appuser

EXPOSE 8188

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "main.py", "--listen", "0.0.0.0"]
