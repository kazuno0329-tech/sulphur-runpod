FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# システムに必要な最低限のツールをインストール
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip3 install --no-cache-dir --upgrade pip setuptools

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# 🌟【修正ポイント】ここで明示的に GitHub から最新の diffusers をキャッシュなしでインストールします
RUN pip3 install --no-cache-dir git+https://github.com/huggingface/diffusers.git

COPY handler.py .

ENV HF_HUB_OFFLINE=0
ENV TRANSFORMERS_OFFLINE=0

CMD ["python3", "-u", "handler.py"]