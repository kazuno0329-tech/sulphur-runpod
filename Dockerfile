# 1. クリーンなベースイメージからスタート
FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

WORKDIR /comfyui

# 2. 最初の一手で完全にディレクトリを空にする
RUN rm -rf ./*

# 3. 必要なものを順番にインストール・配置する
# ※クローンとインストールを分けることで、環境を再現しやすくする
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# 必要なライブラリを一括インストール
RUN pip3 install --no-cache-dir torch torchvision torchaudio scipy numpy pillow tqdm PyYAML runpod

# 必要なカスタムノードのみ追加
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite

# 自作ファイルを配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 実行
CMD ["python3", "-u", "main.py", "--listen"]