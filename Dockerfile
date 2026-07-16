FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 1. 必要なOSパッケージのインストール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# 2. ComfyUIのディレクトリ作成と本体の配置
WORKDIR /comfyui
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# 3. Pythonライブラリのインストール
# pipの更新とrunpodのインストールを確実に行います
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod && \
    pip3 install -r requirements.txt

# 4. ワークフローとハンドラーの配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 5. 起動スクリプトの作成（ここが重要！）
# ComfyUIをバックグラウンド( & )で起動し、その後rp_handler.pyを起動します
# --listen 0.0.0.0 と --port 8188 を指定してOSErrorを回避します
RUN echo '#!/bin/bash\n\
python3 main.py --listen 0.0.0.0 --port 8188 > /dev/null 2>&1 &\n\
echo "ComfyUI started in background."\n\
python3 /rp_handler.py' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 6. エントリーポイントの設定
ENTRYPOINT ["/entrypoint.sh"]