# 2.2.1 から 2.4.0 へアップグレード
FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip3 install --no-cache-dir --upgrade pip setuptools

# ここまではキャッシュをフル活用（重い基本レイヤーはスキップ）
COPY requirements.txt .

# ⚠️ キャッシュを利用しつつ、確実に最新のパッケージを当てるための記述
# --upgrade (または -U) フラグを付けることで、指定バージョン未満の古いキャッシュがあっても強制的に上書きします
# 【重要】pip3コマンド自体のオプションとして --no-deps を指定する
#RUN pip3 install --no-cache-dir --upgrade --no-deps -r requirements.txt

COPY requirements.txt .
RUN pip3 install --no-cache-dir --upgrade --upgrade-strategy eager -r requirements.txt

# もしこれでもダメな場合のみ、以下のコメントアウトを外して強制トリガーにしてください
# ARG CACHE_BUST=3

COPY handler.py .

ENV HF_HUB_OFFLINE=0
ENV TRANSFORMERS_OFFLINE=0

CMD ["python3", "-u", "handler.py"]