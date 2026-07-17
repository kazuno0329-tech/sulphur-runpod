#!/bin/bash
VOLUME_PATH="/runpod-volume" 

# まだダウンロードしていない場合のみ、初回ダウンロードを行う（初回起動時のみ実行）
if [ ! -d "$VOLUME_PATH/checkpoints" ]; then
    echo "Downloading model... (This will take time)"
    mkdir -p "$VOLUME_PATH/checkpoints"
    # --token が正しく渡されているか確認し、進捗を表示する
    huggingface-cli download Seregil13th/Sulphur-2-base sulphur_dev_fp8mixed.safetensors \
        --local-dir "$VOLUME_PATH/checkpoints" --token "${HUGGING_FACE_TOKEN}"
else
    echo "Model already exists."
fi

# ネットワークボリュームのマウント先
VOLUME_PATH="/runpod-volume" 

# ComfyUIのディレクトリへリンクを貼る
ln -s "$VOLUME_PATH/checkpoints"/* /comfyui/models/checkpoints/ 2>/dev/null

# 起動
python3 /rp_handler.py