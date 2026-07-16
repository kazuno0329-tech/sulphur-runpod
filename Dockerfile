FROM runpod/worker-comfy:2.1.0

# 必要なカスタムノード（動画書き出し用のVHSノード）をインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /workspace/ComfyUI/custom_nodes/ComfyUI-VideoHelperSuite

# Sulphur-2の単一モデルファイルを、ビルド時にあらかじめダウンロードしてコンテナ内に配置します
RUN wget -O /workspace/ComfyUI/models/checkpoints/Sulphur-2-distilled-fp8.safetensors \
    https://huggingface.co/Civitai/Sulphur-2-distilled-fp8/resolve/main/Sulphur-2-distilled-fp8.safetensors

# ワークフローとハンドラー（Python）をコンテナ内にコピー
COPY workflow_api.json /workspace/workflow_api.json
COPY rp_handler.py /workspace/rp_handler.py

CMD ["python3", "-u", "/workspace/rp_handler.py"]