FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 再ビルド用トリガー（ビルドのたびにこの数値を変更してください）
ENV REBUILD_ID=20260716_01

ENV DEBIAN_FRONTEND=noninteractive

# 必要なツール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# 新しい作業ディレクトリを作成（古い場所と完全に分離）
WORKDIR /opt/comfyui

# ComfyUIをクリーンインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# ライブラリのインストール
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod

# 明示的に必要なファイルだけを配置
COPY rp_handler.py /opt/rp_handler.py
COPY workflow_api.json /opt/workflow_api.json

# 起動コマンド
# コンテナ起動時にComfyUIとrp_handlerを両方動かす
CMD ["sh", "-c", "python3 main.py --listen 8188 & python3 /opt/rp_handler.py"]