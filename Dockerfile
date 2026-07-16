# 1. 確実に存在するNVIDIA公式の汎用イメージを使用
FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# 2. 必要なパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    python3 \
    python3-pip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 3. Pythonの依存関係とRunPod SDKを個別にインストール
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install --no-cache-dir runpod huggingface_hub

# 4. ComfyUIのインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip3 install --no-cache-dir -r requirements.txt

# 5. その他ノードやハンドラーの準備
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 6. 実行
CMD ["python3", "-u", "/rp_handler.py"]