# 最新の PyTorch 環境を指定
FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /comfyui

# 基本ツールのインストール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# pipのアップグレード
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# ★ここが重要：PyTorchを最新バージョンに強制アップグレードする
RUN pip3 install --no-cache-dir --upgrade torch torchvision torchaudio

# ComfyUI本体のインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# 必要なライブラリのインストール
RUN pip3 install --no-cache-dir scipy numpy pillow tqdm PyYAML runpod

# カスタムノードのインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite

# 設定ファイルの配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

CMD ["python3", "-u", "/rp_handler.py"]