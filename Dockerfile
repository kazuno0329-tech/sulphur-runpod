# CUDA 12.1 + PyTorch 2.2.0 の環境を丸ごと使用（これが一番安定します）
FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /comfyui

# システムパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# RunPod系とComfyUIの準備
RUN pip3 install --no-cache-dir runpod huggingface_hub
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip3 install --no-cache-dir -r requirements.txt

# カスタムノードのインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite

# 設定ファイルの配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

CMD ["python3", "-u", "/rp_handler.py"]