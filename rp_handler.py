import os
import json
import urllib.request
import time
import subprocess
import runpod

# ComfyUIが起動するまで最大60秒待つ関数
def wait_for_server(url, timeout=60):
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            with urllib.request.urlopen(url):
                return True
        except:
            time.sleep(2) # 2秒待機してリトライ
    return False

def handler(job):
    # 1. ComfyUIのポート
    api_url = "http://127.0.0.1:8188"
    
    # 2. ComfyUIが既に起動しているか確認、なければ起動
    # ※サーバーレスなのでハンドラー内でプロセス管理をする必要がある
    if not wait_for_server(api_url, timeout=1):
        print("Starting ComfyUI...")
        subprocess.Popen(["python3", "/comfyui/main.py", "--port", "8188", "--cpu"])
        if not wait_for_server(api_url, timeout=60):
            return {"status": "error", "message": "ComfyUI failed to start"}

    # 3. ワークフロー読み込み
    with open("/workflow_api.json", "r") as f:
        workflow = json.load(f)
    
    # 4. プロンプト送信
    job_input = job.get("input", {})
    prompt_text = job_input.get("prompt", "A high-tech machinery.")
    if "267:266" in workflow:
        workflow["267:266"]["inputs"]["value"] = prompt_text

    req_data = json.dumps({"prompt": workflow}).encode('utf-8')
    req = urllib.request.Request(f"{api_url}/prompt", data=req_data)
    req.add_header('Content-Type', 'application/json')
    
    try:
        with urllib.request.urlopen(req) as response:
            return {"status": "success", "message": "Prompt queued"}
    except Exception as e:
        return {"status": "error", "message": f"Connection failed: {str(e)}"}

if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})