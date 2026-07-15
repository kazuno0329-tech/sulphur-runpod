# 有効な既存のイメージタグに修正
FROM runpod/pytorch:2.4.0-py3.10-cuda12.4.1-devel-ubuntu22.04

# 必要なシステムパッケージのインストール（必要に応じて）
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip3 install --no-cache-dir --upgrade -r requirements.txt

COPY . .

CMD [ "python3", "-u", "handler.py" ]