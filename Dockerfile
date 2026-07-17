FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 必要なOSパッケージをインストール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir runpod huggingface_hub

# ComfyUIのセットアップ
WORKDIR /comfyui
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip3 install --no-cache-dir -r requirements.txt

# モデル用ディレクトリの作成
RUN mkdir -p /comfyui/models/checkpoints \
             /comfyui/models/latent_upscale_models \
             /comfyui/models/loras \
             /comfyui/models/text_encoders

# 必要なファイルを配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# ★追加: 起動用スクリプトのコピーと設定
COPY start.sh /start.sh
RUN chmod +x /start.sh

# ★変更: 起動コマンドを start.sh に変更
CMD ["/start.sh"]