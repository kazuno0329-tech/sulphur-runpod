# CUDA 11.8を指定（ほとんどの環境で動く最も堅実な選択）
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# 必要なツール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    python3 \
    python3-pip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# PyTorch (CUDA 11.8対応版)
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# ComfyUIのインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip3 install --no-cache-dir -r requirements.txt

# カスタムノード
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite

# ファイルコピー
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 実行
CMD ["python3", "-u", "/rp_handler.py"]