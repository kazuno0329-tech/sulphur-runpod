FROM runpod/worker-comfyui:5.8.4-base

# システムパッケージを更新し、gitとwgetをインストール
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 必要なカスタムノード（動画書き出し用のVHSノード）をインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite

# 【修正箇所】制限を回避するためにミラーサイト（hf-mirror.com）のURLを使用してダウンロードします
RUN wget -O /comfyui/models/checkpoints/Sulphur-2-distilled-fp8.safetensors \
    https://hf-mirror.com/SulphurAI/Sulphur-2-base/resolve/main/Sulphur-2-distilled-fp8.safetensors

# ワークフローとハンドラー（Python）をコンテナ内にコピー
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

CMD ["python3", "-u", "/rp_handler.py"]