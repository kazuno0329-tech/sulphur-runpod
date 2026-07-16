FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# 必要なツール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget python3 python3-pip ffmpeg && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir runpod huggingface_hub torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip3 install --no-cache-dir -r requirements.txt

# カスタムノード
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite

# ★重要：ここでモデルを事前に配置する設定を追加
# ※ご自身のモデルのパスを /comfyui/models/checkpoints/ に合わせる必要があります
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

CMD ["python3", "-u", "/rp_handler.py"]