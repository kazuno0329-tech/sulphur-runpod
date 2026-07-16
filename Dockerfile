# 【超重要】CUDA 12.1ベースで、どのGPUでも100%動く安定イメージを指定します
FROM runpod/worker-comfy:3.1.0

# システムパッケージを更新し、gitとwgetをインストール
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# huggingface-cliを有効にするためライブラリをインストール
RUN pip install --no-cache-dir huggingface_hub

# 必要なカスタムノード（動画書き出し用のVHSノード）をインストール
# ※このベースイメージでは、ComfyUIのルートパスが「/workspace/ComfyUI」になります
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /workspace/ComfyUI/custom_nodes/ComfyUI-VideoHelperSuite

# ワークフローとハンドラー（Python）をコンテナ内にコピー
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 起動コマンド
CMD ["python3", "-u", "/rp_handler.py"]