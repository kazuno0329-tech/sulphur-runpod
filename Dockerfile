FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 再ビルド用ID（これを変えると強制再ビルドされます）
ENV REBUILD_ID=20260717_05
ENV DEBIAN_FRONTEND=noninteractive

# 1. 過去の残骸をすべて削除
RUN rm -rf /comfyui /opt/comfyui /app /build_env

# 2. 新しい作業場所を作成
WORKDIR /home/comfy_setup

# 3. 必要なツール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*

# 4. ComfyUI本体を、これまでの残骸とは無縁の場所にクローン
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /home/comfy_setup/ui

# 5. ライブラリインストール
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod

# 6. カスタムノード
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /home/comfy_setup/ui/custom_nodes/ComfyUI-VideoHelperSuite

# 7. 必要なファイルだけを「明示的」にコピー
# COPY . . ではなく、ファイル単位で指定することで、リポジトリの3ファイル以外を無視します
COPY rp_handler.py /home/comfy_setup/rp_handler.py
COPY workflow_api.json /home/comfy_setup/workflow_api.json

# 8. 起動
# ComfyUIのディレクトリに移動してサーバーを立ち上げ、rp_handlerを起動
CMD ["sh", "-c", "cd /home/comfy_setup/ui && python3 main.py --listen 8188 & python3 /home/comfy_setup/rp_handler.py"]