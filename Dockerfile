FROM runpod/worker-comfyui:5.8.4-base

# システムパッケージを更新し、gitとwgetをインストール
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# huggingface-cliを有効にするためライブラリをインストール
RUN pip install --no-cache-dir huggingface_hub

# 必要なカスタムノード（動画書き出し用のVHSノード）をインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite

# ワークフローとハンドラー（Python）をコンテナ内にコピー
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 起動コマンドを直接pythonではなく、モデル確認スクリプト（または起動直前のハンドラー）に変更
CMD ["python3", "-u", "/rp_handler.py"]