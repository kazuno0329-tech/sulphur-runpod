FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# pipのアップグレードは行いますが、requirementsのインストール時はイメージ内の既存パッケージを保護します
RUN pip3 install --no-cache-dir --upgrade pip setuptools

COPY requirements.txt .
# ⚠️ --upgrade フラグを外し、既存のtorchやtorchvisionの上書き・破損を防ぎます
RUN pip3 install --no-cache-dir -r requirements.txt

COPY handler.py .

ENV HF_HUB_OFFLINE=0
ENV TRANSFORMERS_OFFLINE=0

CMD ["python3", "-u", "handler.py"]