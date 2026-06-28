#!/bin/bash
COMFYUI_BASE="$HOME/comfyui"

mkdir -p "$COMFYUI_BASE"/{input,output,custom_nodes}
mkdir -p "$COMFYUI_BASE"/models/{checkpoints,clip,clip_vision,controlnet,diffusers,embeddings,gligen,hypernetworks,loras,style_models,unet,upscale_models,vae,vae_approx}
mkdir -p "$COMFYUI_BASE"/user/default/workflows

echo "Directory structure created at $COMFYUI_BASE"