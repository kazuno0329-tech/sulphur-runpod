#!/bin/bash
# ネットワークストレージのパス
NETWORK_STORAGE="/runpod-volume/checkpoints"
# ComfyUIがモデルを探すディレクトリ
COMFY_DIR="/comfyui/models/checkpoints"
MODEL_REPO="Kijai/Sulphur-2-distilled-fp8"
MODEL_FILE="sulphur_distil_fp8mixed.safetensors"


# 1. ネットワークストレージ側のフォルダを作成
mkdir -p "$NETWORK_STORAGE"

# 2. まだファイルがない場合のみダウンロード（ネットワークストレージへ）
if [ ! -f "$NETWORK_STORAGE/$MODEL_FILE" ]; then
    echo "Downloading model to network storage: $NETWORK_STORAGE"
    python3 -c "
from huggingface_hub import hf_hub_download
import os

token = os.environ.get('HUGGING_FACE_TOKEN')

# トークンの中身をログに出力（デバッグ用）
print(f'DEBUG: Found token: {token}')

hf_hub_download(
    repo_id='$MODEL_REPO',
    filename='$MODEL_FILE',
    local_dir='$NETWORK_STORAGE',
    token=token
)
"
    if [ $? -ne 0 ]; then
        echo "Download failed. Check your token and license agreement."
        exit 1
    fi
else
    echo "Model already exists in network storage."
fi

# 3. ネットワークストレージからComfyUIのディレクトリへリンクを貼る
# （既に存在する場合のエラーを防ぐため rm -f を使用）
ln -sf "$NETWORK_STORAGE/$MODEL_FILE" "$COMFY_DIR/$MODEL_FILE"
echo "Symbolic link created."

# 起動
echo "Starting ComfyUI..."
python3 /rp_handler.py