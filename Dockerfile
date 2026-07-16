FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /comfyui

RUN apt-get update && apt-get install -y git ffmpeg && rm -rf /var/lib/apt/lists/*

# 必要最低限のパッケージのみインストール
RUN pip3 install --no-cache-dir runpod

# ComfyUI本体
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# requirements.txt をコピーする前に、競合を避けるために最新のセットアップツールを入れる
RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir -r requirements.txt

# カスタムノード (最低限必要なものだけに絞る)
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite

# 設定ファイルの配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 実行
CMD ["python3", "-u", "/rp_handler.py"]