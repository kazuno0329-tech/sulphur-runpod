# 1. ベースイメージ
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# 環境変数設定
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /comfyui

# 2. システムパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    python3 \
    python3-pip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 3. Pythonのベースライブラリを先にインストール（分割して失敗を防ぐ）
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir runpod huggingface_hub

# 4. PyTorch と、相性の良い古いバージョンの Triton を指定してインストール
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip3 install --no-cache-dir triton==2.1.0
# 5. ComfyUIのインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip3 install --no-cache-dir -r requirements.txt

# 6. カスタムノードのインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite

# 7. ファイルのコピー
# 確実にルートにあるファイルのみをコピー
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 8. 実行コマンド
CMD ["python3", "-u", "/rp_handler.py"]