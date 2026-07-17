FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 必要なOSパッケージをインストール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# ComfyUIのディレクトリ作成と本体の配置
WORKDIR /comfyui
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Pythonライブラリのインストール
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod && \
    pip3 install -r requirements.txt

# ワークフローとハンドラーの配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 起動スクリプトの作成（確実なHeredoc形式）
RUN cat <<EOF > /entrypoint.sh
#!/bin/bash
python3 main.py --listen 0.0.0.0 --port 8188 > /dev/null 2>&1 &
echo "ComfyUI started in background."
python3 /rp_handler.py
EOF
RUN chmod +x /entrypoint.sh

# エントリーポイントの設定
ENTRYPOINT ["/entrypoint.sh"]