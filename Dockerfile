FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

# 必要なOSパッケージをインストール
RUN apt-get update && apt-get install -y git ffmpeg wget && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir runpod

# ComfyUIのディレクトリ作成と本体の配置
WORKDIR /comfyui
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip3 install --no-cache-dir -r requirements.txt

# 1. モデル保存用のディレクトリを明示的に作成
RUN mkdir -p /comfyui/models/checkpoints \
             /comfyui/models/latent_upscale_models \
             /comfyui/models/loras \
             /comfyui/models/text_encoders

# 2. モデルのダウンロード (イメージに焼き込み)
# ※ダウンロードURLはHugging Faceの該当モデルページから「ダウンロード」ボタンのリンクをコピーして、
#   末尾が /resolve/main/... となるURLを各行に貼り付けてください。
RUN wget -O /comfyui/models/checkpoints/sulphur_dev_fp8mixed.safetensors "https://huggingface.co/Seregil13th/Sulphur-2-base/resolve/main/sulphur_dev_fp8mixed.safetensors"
RUN wget -O /comfyui/models/latent_upscale_models/ltx-2.3-spatial-upscaler-x2-1.0.safetensors "https://huggingface.co/huggingface-metadata/ltx-2.3-spatial-upscaler-x2-1.0/resolve/main/ltx-2.3-spatial-upscaler-x2-1.0.safetensors"
RUN wget -O /comfyui/models/loras/ltx-2.3-22b-distilled-lora-1.1_fro90_ceil72_condsafe.safetensors "https://huggingface.co/huggingface-metadata/ltx-2.3-22b-lora/resolve/main/ltx-2.3-22b-distilled-lora-1.1_fro90_ceil72_condsafe.safetensors"
RUN wget -O /comfyui/models/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors "https://huggingface.co/huggingface-metadata/gemma-3-12b-fp4/resolve/main/gemma_3_12B_it_fp4_mixed.safetensors"

# 3. 必要なファイルを配置
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 4. 起動コマンド
CMD ["python3", "/rp_handler.py"]