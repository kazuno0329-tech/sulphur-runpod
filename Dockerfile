# 確実に存在する公式の安定したCUDAイメージ
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.0

# 必要なパッケージ
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# ComfyUIのインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip install --no-cache-dir -r requirements.txt

# VideoHelperSuiteのインストール
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /comfyui/custom_nodes/ComfyUI-VideoHelperSuite

# 各ファイルをコピー
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 直接ハンドラーを起動（これが最も安定します）
CMD ["python3", "-u", "/rp_handler.py"]