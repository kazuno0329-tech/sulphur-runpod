# RunPodの公式PyTorch環境（これが最もビルドと実行に安定します）
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.0

# 必要なパッケージをまとめてインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# RunPod SDK と必要なライブラリを確実にインストール
RUN pip install --no-cache-dir runpod huggingface_hub

# ComfyUIのインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip install --no-cache-dir -r requirements.txt

# カスタムノードとファイルをコピー
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 実行
CMD ["python3", "-u", "/rp_handler.py"]