# PyTorchとCUDA環境がセットアップ済みの公式イメージ
FROM pytorch/pytorch:2.2.1-cuda12.1-cudnn8-runtime

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip3 install --no-cache-dir --upgrade pip setuptools

# requirements.txtから一括でライブラリをインストール
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY handler.py .

ENV HF_HUB_OFFLINE=0
ENV TRANSFORMERS_OFFLINE=0

CMD ["python3", "-u", "handler.py"]