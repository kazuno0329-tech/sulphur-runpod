FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 必要なOSパッケージをインストール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir runpod huggingface_hub

# ビルド引数の定義（Gatedモデル等でトークンが必要な場合に使用）
ARG HUGGING_FACE_TOKEN

# ComfyUIのディレクトリ作成と本体の配置
WORKDIR /comfyui
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip3 install --no-cache-dir -r requirements.txt

# 1. モデル保存用のディレクトリを明示的に作成
RUN mkdir -p /comfyui/models/checkpoints \
             /comfyui/models/latent_upscale_models \
             /comfyui/models/loras \
             /comfyui/models/text_encoders

# 2. モデルのダウンロード (huggingface-cliを使用)
# ※トークンが必要な場合はビルド時に --build-arg HUGGING_FACE_TOKEN=your_token を指定してください
RUN huggingface-cli download Seregil13th/Sulphur-2-base sulphur_dev_fp8mixed.safetensors \
    --local-dir /comfyui/models/checkpoints/ ${HUGGING_FACE_TOKEN:+--token $HUGGING_FACE_TOKEN}

RUN huggingface-cli download huggingface-metadata/ltx-2.3-spatial-upscaler-x2-1.0 ltx-2.3-spatial-upscaler-x2-1.0.safetensors \
    --local-dir /comfyui/models/latent_upscale_models/ ${HUGGING_FACE_TOKEN:+--token $HUGGING_FACE_TOKEN}

RUN huggingface-cli download huggingface-metadata/ltx-2.3-22b-lora ltx-2.3-22b-distilled-lora-1.1_fro90_ceil72_condsafe.safetensors \
    --local-dir /comfyui/models/loras/ ${HUGGING_FACE_TOKEN:+--token $HUGGING_FACE_TOKEN}

RUN huggingface-cli download huggingface-metadata/gemma-3-12b-fp4 gemma_3_12B_it_fp4_mixed.safetensors \
    --local-dir /comfyui/models/text_encoders/ ${HUGGING_FACE_TOKEN:+--token $HUGGING_FACE_TOKEN}

# 3. 必要なファイルを配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 4. 起動コマンド
CMD ["python3", "/rp_handler.py"]