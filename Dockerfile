FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# OSパッケージのインストール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# ComfyUIのディレクトリ作成と本体の配置
WORKDIR /comfyui
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Pythonライブラリのインストール
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod && \
    pip3 install -r requirements.txt

# ワークフローとハンドラーの配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 起動スクリプトの作成（安全な形式に修正）
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'python3 main.py --listen 0.0.0.0 --port 8188 > /dev/null 2>&1 &' >> /entrypoint.sh && \
    echo 'echo "ComfyUI started in background."' >> /entrypoint.sh && \
    echo 'python3 /rp_handler.py' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# エントリーポイントの設定
ENTRYPOINT ["/entrypoint.sh"]