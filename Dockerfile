# 1. 最新の PyTorch イメージ
FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive

# 2. 最初にシステムパッケージをインストールする (ここで git を確実にインストール)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 3. 作業ディレクトリを作成 (以前の残骸が残らないよう、あえて違う名前や新しいディレクトリにする)
WORKDIR /comfyui

# 4. ComfyUI本体のクローン
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# 5. 必要なライブラリのインストール
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod

# 6. カスタムノードの追加
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite

# 7. 設定ファイルを配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 8. 起動コマンド
CMD ["python3", "-u", "main.py", "--listen"]