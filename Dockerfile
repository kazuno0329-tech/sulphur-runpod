FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 8. 起動# 診断用CMD
CMD ["ls", "-R", "/opt/comfyui"]
