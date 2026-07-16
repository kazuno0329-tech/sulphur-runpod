FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# ★再ビルド用トリガー（ビルドのたびに数値を必ず変更してください）
ENV REBUILD_ID=20260717_02
ENV DEBIAN_FRONTEND=noninteractive

# 必要なツール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# ComfyUIをルートから隔離してインストール
RUN mkdir -p /app/comfy
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/comfy

# ライブラリのインストール
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod

# カスタムノードのインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /app/comfy/custom_nodes/ComfyUI-VideoHelperSuite

# ★重要：ルート直下に配置（これで rp_handler.py がファイルを認識します）
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 起動コマンド
# 1. ComfyUIサーバーをバックグラウンドで起動
# 2. その後、ルートにある rp_handler.py を起動
CMD ["sh", "-c", "cd /app/comfy && python3 main.py --listen 8188 & python3 /rp_handler.py"]