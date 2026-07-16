import os
import json
import urllib.request
import time
import subprocess
import runpod

def wait_for_server(url, timeout=60):
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            with urllib.request.urlopen(url):
                return True
        except:
            time.sleep(2)
    return False

def handler(job):
    api_url = "http://127.0.0.1:8188"
    
    # ワークフロー読み込み
    with open("/workflow_api.json", "r") as f:
        workflow = json.load(f)
    
    # プロンプト設定
    job_input = job.get("input", {})
    prompt_text = job_input.get("prompt", "A high-tech machinery.")
    if "267:266" in workflow:
        workflow["267:266"]["inputs"]["value"] = prompt_text

    # プロンプト送信
    req_data = json.dumps({"prompt": workflow}).encode('utf-8')
    req = urllib.request.Request(f"{api_url}/prompt", data=req_data)
    req.add_header('Content-Type', 'application/json')
    
    try:
        with urllib.request.urlopen(req) as response:
            pass # 送信成功
    except Exception as e:
        return {"status": "error", "message": f"Connection failed: {str(e)}"}

    # 生成待機（タイムアウトを少し長めに設定）
    time.sleep(90) 
    
    # ファイル転送
    output_dir = "/comfyui/output"
    files = [os.path.join(output_dir, f) for f in os.listdir(output_dir) if f.endswith(('.mp4', '.avi'))]
    if not files:
        return {"status": "error", "message": "Video not found"}
    
    latest_file = max(files, key=os.path.getctime)
    try:
        upload_cmd = f"curl --upload-file {latest_file} https://transfer.sh/{os.path.basename(latest_file)}"
        download_url = subprocess.check_output(upload_cmd, shell=True).decode('utf-8').strip()
        return {"status": "success", "download_url": download_url}
    except Exception as e:
        return {"status": "error", "message": f"Upload failed: {str(e)}"}

if __name__ == "__main__":
    # ComfyUIを起動（バックグラウンド）
    subprocess.Popen(["python3", "/comfyui/main.py", "--port", "8188", "--preview-method", "none"])
    runpod.serverless.start({"handler": handler})