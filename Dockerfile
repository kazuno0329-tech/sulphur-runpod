FROM runpod/worker-comfyui:5.8.4-base

# システムパッケージを更新し、gitとwgetをインストール
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 必要なカスタムノード（動画書き出し用のVHSノード）をインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite

# Sulphur-2の単一モデルファイルを、ビルド時にあらかじめダウンロードして配置します
RUN wget -O /comfyui/models/checkpoints/Sulphur-2-distilled-fp8.safetensors \
    https://huggingface.co/Civitai/Sulphur-2-distilled-fp8/resolve/main/Sulphur-2-distilled-fp8.safetensors

# ワークフローとハンドラー（Python）をコンテナ内にコピー
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

CMD ["python3", "-u", "/rp_handler.py"]