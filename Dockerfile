FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 1. 必要なファイルをコピー
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

# 2. 【重要】ビルド時にルートディレクトリの中身を強制表示させる
# これにより、ビルド完了時に /workflow_api.json が本当に存在しているか確認できます
RUN ls -la /

# 3. 起動コマンド
CMD ["sh", "-c", "echo '--- Checking file existence before starting ---' && ls -la /workflow_api.json && python3 /rp_handler.py"]