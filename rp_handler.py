import os
import json
import urllib.request
import subprocess
import time
import runpod
from runpod.serverless.utils import rp_upload
from huggingface_hub import hf_hub_download

# --- 設定 ---
COMFYUI_PORT = 8188
MODEL_PATH = "/comfyui/models/checkpoints/sulphur_dev_fp8mixed.safetensors"

def wait_for_comfyui(timeout=300):
    """ComfyUIサーバーが立ち上がるまで待機"""
    start_time = time.time()
    print(f"Waiting for ComfyUI on port {COMFYUI_PORT}...")
    while time.time() - start_time < timeout:
        try:
            with urllib.request.urlopen(f"http://127.0.0.1:{COMFYUI_PORT}"):
                print("ComfyUI is ready!")
                return True
        except:
            time.sleep(2)
    return False

def download_model():
    """モデルをダウンロード"""
    if not os.path.exists(MODEL_PATH):
        print("Downloading model...")
        hf_token = os.environ.get("HF_TOKEN")
        os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
        hf_hub_download(
            repo_id="SulphurAI/Sulphur-2-base",
            filename="sulphur_dev_fp8mixed.safetensors",
            local_dir="/comfyui/models/checkpoints",
            token=hf_token
        )

def queue_prompt(prompt_workflow):
    """ComfyUIにプロンプトを送信"""
    data = json.dumps({"prompt": prompt_workflow}).encode('utf-8')
    req = urllib.request.Request(f"http://127.0.0.1:{COMFYUI_PORT}/prompt", data=data)
    req.add_header('Content-Type', 'application/json')
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode('utf-8'))

def handler(job):
    # 1. コンテナ起動時に一度だけモデルを確認
    download_model()
    
    # 2. ComfyUIをバックグラウンドで起動
    subprocess.Popen(["python3", "/comfyui/main.py", "--port", str(COMFYUI_PORT), "--listen", "0.0.0.0"])
    
    # 3. 起動待ち
    if not wait_for_comfyui():
        return {"status": "error", "message": "ComfyUI failed to start"}

    # 4. ワークフロー処理
    job_input = job.get("input", {})
    with open("/workflow_api.json", "r") as f:
        workflow = json.load(f)
    
    # (ここにプロンプト差し替え処理などがあれば記述)

    result = queue_prompt(workflow)
    
    # 5. 生成完了待ち（簡易）
    time.sleep(10) 
    
    # 6. 結果返却
    return {"status": "success", "message": "Job processed"}

if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})