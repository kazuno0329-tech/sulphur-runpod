#!/bin/bash

# RunPodのModel Cache機能でダウンロードされたモデルは、
# 通常 /runpod-volume/ 以下に配置されます。
# 実際のパスは環境に合わせて調整してください。
CACHE_BASE="/runpod-volume"

# キャッシュ先からComfyUIのフォルダへリンクを貼る
# (例: チェックポイント、LoRA、テキストエンコーダー等)
ln -s ${CACHE_BASE}/checkpoints/* /comfyui/models/checkpoints/ 2>/dev/null
ln -s ${CACHE_BASE}/loras/* /comfyui/models/loras/ 2>/dev/null
# 必要に応じて他のディレクトリも追加してください

# ComfyUIの本体（handler）を起動
python3 /rp_handler.py