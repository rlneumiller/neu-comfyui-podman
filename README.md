# README.md

## Overview
This repository, besides being a personal learning experience, provides a mostly containerized ComfyUI setup targeting:

- ComfyUI **v0.24**
- ComfyUI‑Manager **v3.x**
- PyTorch **2.12.1 + CUDA 13**
- Triton, comfy‑aimdo, and comfy‑kitchen backends
- Rootless Podman GPU environments

The goal is to provide myself with a relatively safe, isolated, reproducible, minimal, and stable environment.

This container keeps your models, outputs, settings, and custom nodes on the host filesystem via bind mounts, while ComfyUI itself runs as a non-root user inside an isolated container — built to run under rootless Podman, so the container engine itself never requires root privileges either. If you're not sure why that's a meaningfully stronger security posture, see [Podman's rootless documentation](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md).

I may work on making this container more self-contained in the future, but **get something working** is the immediate goal at present
---

## Features
- CUDA 13 base image with PyTorch 2.12.1
- `uv` for Python package installation
- ComfyUI‑Manager installed
- GitPython included for Manager’s backend
- Podman‑compatible entrypoint and cache handling
- Host‑mounted directories for models, output, settings, and custom nodes

---

## Requirements
- Podman with NVIDIA GPU support  
- NVIDIA drivers compatible with CUDA 13  
- A directory structure on the host:

```
~/comfyui/
    models/
    output/
    custom_nodes/
    settings/
    temp/
```

---

## Building the Image

From the repository root:

```
# Don't forget the dot at the end
podman build -t comfyui-v0.24:latest .
```

---

## Running the Container

Example command:

```
podman run -it --rm \
  --name comfyui \
  --device nvidia.com/gpu=all \
  --security-opt label=disable \
  --userns=keep-id \
  -p 8188:8188 \
  -e PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256 \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  -v ~/comfyui/models:/workspace/ComfyUI/models:Z \
  -v ~/comfyui/output:/workspace/ComfyUI/output:Z \
  -v ~/comfyui/custom_nodes:/workspace/ComfyUI/custom_nodes:Z \
  -v ~/comfyui/settings:/workspace/ComfyUI/user:Z \
  -v ~/comfyui/temp:/workspace/ComfyUI/temp:Z \
  localhost/comfyui-v0.24:latest
```

After startup, ComfyUI will be available at:

```
http://localhost:8188
```

---

## Notes


### uv Cache
Rootless Podman may create `$HOME/.cache` with restrictive permissions.  
The entrypoint redirects `uv` to use `/tmp/uv-cache`, to avoid permission issues.

### Custom Nodes
All custom nodes, including ComfyUI‑Manager, are expected to be mounted from the host.  
The container does not bundle any custom nodes internally.

---

## Updating ComfyUI
TBD
```
# Don't forget the dot at the end (essentially means "use the Containerfile in this folder")
podman build -t comfyui-v0.24:latest .
```

---

## License
This repository does not modify ComfyUI or ComfyUI‑Manager.  
Refer to their respective upstream licenses for details.

---
