FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 必要なツールとライブラリ
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir runpod

# 1. ComfyUI を配置するためのディレクトリを作成
WORKDIR /app/comfyui

# 2. ここで本体をクローンする（これで /app/comfyui/main.py が必ず存在するようになります）
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# 3. 必要なファイル（3ファイル）を配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 4. 実行
# これで「/app/comfyui/main.py」が確実に存在し、パスの食い違いは解消されます
CMD ["python3", "/rp_handler.py"]