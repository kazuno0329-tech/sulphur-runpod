# 1. 確実に存在するNVIDIA公式イメージ（CUDA 11.8）
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# 2. 必要なシステムツールのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    python3 \
    python3-pip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 3. ここが重要：コンテナ内に runpod ライブラリを明示的にインストールする
RUN pip3 install --no-cache-dir runpod huggingface_hub

# 4. PyTorchをインストール
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 5. ComfyUIとその依存関係をインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip3 install --no-cache-dir -r requirements.txt

# 6. カスタムノードとファイルをコピー
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 7. 実行
CMD ["python3", "-u", "/rp_handler.py"]