# 1. PyTorchを最新に近いバージョン (2.4.0+) に引き上げる
FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /comfyui

# 必要な基本ツールのインストール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# pipのアップグレード
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# ComfyUI本体のインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# 2. requirements.txtを使わず、ここで主要なライブラリを直接インストールする
# ComfyUIに必要な最小限の依存関係を直接指定します
RUN pip3 install --no-cache-dir \
    torchvision torchaudio \
    scipy numpy pillow \
    tqdm PyYAML \
    runpod

# カスタムノードのインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite

# 設定ファイルの配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 実行
CMD ["python3", "-u", "/rp_handler.py"]