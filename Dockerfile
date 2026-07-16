FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip3 install --no-cache-dir --upgrade pip setuptools

COPY requirements.txt .
# ⚠️ ベースのPyTorch環境を壊さないよう、通常インストールを行います
RUN pip3 install --no-cache-dir -r requirements.txt

COPY handler.py .

ENV HF_HUB_OFFLINE=0
ENV TRANSFORMERS_OFFLINE=0

CMD ["python3", "-u", "handler.py"]