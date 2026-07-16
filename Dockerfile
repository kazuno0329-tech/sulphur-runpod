FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# 必要なツールのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# ComfyUIを専用フォルダにクローン (ルート直下ではない)
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI

# ライブラリインストール
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod

# カスタムノードのインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /app/ComfyUI/custom_nodes/ComfyUI-VideoHelperSuite

# 設定ファイルを適切な場所にコピー
COPY workflow_api.json /app/workflow_api.json
COPY rp_handler.py /app/rp_handler.py

# 実行コマンドの修正 (ComfyUIフォルダ内のmain.pyを指す)
# また、rp_handler.pyも/app配下で実行するように変更
CMD ["python3", "-u", "/app/rp_handler.py"]