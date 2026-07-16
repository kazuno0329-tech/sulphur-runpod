FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive

# 必要なツール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# ライブラリのインストール（確実にするため分割せず、ここに集約しました）
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod

WORKDIR /app

# ファイルの配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 起動コマンド
CMD ["python3", "/rp_handler.py"]