# I think I can skip this stuff if convert my /home and /gits to btrfs and then we can copy models into the containers without duplication of storage.


# This script creates symbolic links from our local Hugging Face
# cache at /home/arrel/.cache/huggingface to the ComfyUI 
# models directory for specific model files.
# This script t does not currently work for split saftetensors files,
# so those need to be downloaded manually.

ln /home/arrel/.cache/huggingface/hub/models--Tongyi-MAI--Z-Image-Turbo/snapshots/f332072aa78be7aecdf3ee76d5c247082da564a6/transformer/diffusion_pytorch_model.safetensors \
   /home/arrel/comfyui/models/diffusion_models/z-image-turbo-transformer.safetensors

ln /home/arrel/.cache/huggingface/hub/models--jayn7--Z-Image-Turbo-GGUF/snapshots/6e2dff8e3abd78051c1211fb5833a03818a2f3cc/z_image_turbo-Q8_0.gguf \
    /home/arrel/comfyui/models/diffusion_models/z-image-turbo-gguf.gguf

ln /home/arrel/.cache/huggingface/hub/models--Comfy-Org--ltx-2/snapshots/bd5f9c87fcb0360ae7112f9784562670894d9492/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors \
    /home/arrel/comfyui/models/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors

ln /home/arrel/.cache/huggingface/hub/models--Lightricks--LTX-2.3-fp8/snapshots/1d756cd27fa11c0896c4dfee093cd1bf36c7f7a1/ltx-2.3-22b-distilled-fp8.safetensors \
    /home/arrel/comfyui/models/diffusion_models/ltx-2.3-22b-distilled-fp8.safetensors

####################################################################################################################
#NOTES:

# For Ada (my rtx 4070 super):
# FP16
# BF16
# INT8
# INT4
# FP8 (E4M3/E5M2) (driver emulated)
# no MXFP8
# no NVFP4
# no FP4

# https://huggingface.co/Lightricks/LTX-2.3-fp8/blob/main/ltx-2.3-22b-distilled-fp8.safetensors
# https://huggingface.co/valiantcat/LTX-2.3-Transition-LORA/blob/main/ltx2.3-transition.safetensors
# https://huggingface.co/Comfy-Org/ltx-2/blob/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors


# Output from hf download commands:
# hf download hf://Comfy-Org/ltx-2/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors
# ✓ Downloaded
#   path: /home/arrel/.cache/huggingface/hub/models--Comfy-Org--ltx-2/snapshots/bd5f9c87fcb0360ae7112f9784562670894d9492/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors

# hf download hf://Lightricks/LTX-2.3-fp8/ltx-2.3-22b-distilled-fp8.safetensors
# ✓ Downloaded
#   path: /home/arrel/.cache/huggingface/hub/models--Lightricks--LTX-2.3-fp8/snapshots/1d756cd27fa11c0896c4dfee093cd1bf36c7f7a1/ltx-2.3-22b-distilled-fp8.safetensors

# SPLIT FILES: This script does not currently work for split saftetensors files, so those need to be downloaded directly from Hugging Face. The following command can be used to download the split file for gemma_3_12B_it_fp4_mixed.safetensors:

# hf download hf://Comfy-Org/ltx-2/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors
# ✓ Downloaded
#   path: /home/arrel/.cache/huggingface/hub/models--Comfy-Org--ltx-2/snapshots/bd5f9c87fcb0360ae7112f9784562670894d9492/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors

# hf download hf://Comfy-Org/Krea-2/diffusion_models/krea2_turbo_fp8_scaled.safetensors