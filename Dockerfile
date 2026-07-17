FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir runpod

# 1. RunPodが探しに行く場所（/comfyui）を強制的に作成し、そこに本体を配置する
WORKDIR /comfyui
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip3 install --no-cache-dir -r requirements.txt

# 2. 必要なファイルを配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 3. ハンドラーのみを実行（サーバー起動はハンドラー内で管理されるため）
CMD ["python3", "/rp_handler.py"]