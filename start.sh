#!/bin/bash
TARGET_DIR="/comfyui/models/checkpoints"
MODEL_REPO="Seregil13th/Sulphur-2-base"
MODEL_FILE="sulphur_dev_fp8mixed.safetensors"

# ディレクトリが存在するか確認（なければ作成）
mkdir -p "$TARGET_DIR"

# ファイルが存在するか確認
if [ ! -f "$TARGET_DIR/$MODEL_FILE" ]; then
    echo "Downloading model from Hugging Face..."
    
    # Pythonを使用して信頼性の高いダウンロードを実行
    python3 -c "
from huggingface_hub import hf_hub_download
import os

token = os.environ.get('HUGGING_FACE_TOKEN')
hf_hub_download(
    repo_id='$MODEL_REPO',
    filename='$MODEL_FILE',
    local_dir='$TARGET_DIR',
    token=token
)
"
    if [ $? -eq 0 ]; then
        echo "Download successful."
    else
        echo "Download failed!"
        exit 1
    fi
else
    echo "Model already exists in $TARGET_DIR."
fi

# 起動
echo "Starting ComfyUI..."
python3 /rp_handler.py