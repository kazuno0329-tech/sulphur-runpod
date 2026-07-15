# ベースイメージ（すでに PyTorch や CUDA が最適化されているもの）
FROM runpod/pytorch:2.5.1-py3.10-cuda12.4.1-devel-ubuntu22.04

# 必要なシステムパッケージのインストール（必要に応じて）
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /app

# 依存ライブラリのインストール
COPY requirements.txt .
RUN pip3 install --no-cache-dir --upgrade -r requirements.txt

# アプリケーションコードのコピー
COPY . .

# ハンドラーの実行コマンド
CMD [ "python3", "-u", "handler.py" ]