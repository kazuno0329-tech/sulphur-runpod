FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# システムに必要な最低限のツールをインストール
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 🌟【ここが修正ポイント】
# pipとsetuptoolsを最新に更新することで、古いpipによるエラーや競合を根本から防ぎます
RUN pip3 install --no-cache-dir --upgrade pip setuptools

COPY requirements.txt .

# 修正：余計なオプションを外してシンプルにインストールします
RUN pip3 install --no-cache-dir -r requirements.txt

COPY handler.py .

ENV HF_HUB_OFFLINE=0
ENV TRANSFORMERS_OFFLINE=0

CMD ["python3", "-u", "handler.py"]