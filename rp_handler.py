import os
import json
import urllib.request
import time
import subprocess
import runpod

def wait_for_comfyui():
    """ComfyUIの起動を最大300秒待機する"""
    print("Waiting for ComfyUI to start...")
    for _ in range(150):
        try:
            with urllib.request.urlopen("http://127.0.0.1:8188"):
                return True
        except:
            time.sleep(2)
    return False

def handler(job):
    # 1. ジョブ入力からプロンプトを取得
    job_input = job.get("input", {})
    prompt_text = job_input.get("prompt", "A high-tech machinery self-assembling.")
    
    # 2. ワークフローの読み込み
    with open("/workflow_api.json", "r") as f:
        workflow = json.load(f)

    # 3. プロンプトの上書き (ノードID '267:266' は PrimitiveStringMultiline)
    if "267:266" in workflow:
        workflow["267:266"]["inputs"]["value"] = prompt_text

    # 4. ComfyUIへプロンプト送信
    req_data = json.dumps({"prompt": workflow}).encode('utf-8')
    req = urllib.request.Request("http://127.0.0.1:8188/prompt", data=req_data)
    req.add_header('Content-Type', 'application/json')
    
    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            prompt_id = result.get("prompt_id")
            print(f"Job queued: {prompt_id}")
    except Exception as e:
        return {"status": "error", "message": f"Queue failed: {str(e)}"}

    # 5. 生成完了を待機（簡易的なポーリング）
    # ※生成時間が長い場合は、ここでタイムアウト調整が必要
    time.sleep(60) 

    # 6. 生成された動画を探索
    output_dir = "/comfyui/output"
    files = [os.path.join(output_dir, f) for f in os.listdir(output_dir) if f.endswith(('.mp4', '.avi'))]
    if not files:
        return {"status": "error", "message": "Video not found in output directory"}
    
    latest_file = max(files, key=os.path.getctime)
    
    # 7. Transfer.sh を使って外部転送（無料・登録不要）
    try:
        upload_cmd = f"curl --upload-file {latest_file} https://transfer.sh/{os.path.basename(latest_file)}"
        download_url = subprocess.check_output(upload_cmd, shell=True).decode('utf-8').strip()
        
        return {
            "status": "success",
            "download_url": download_url,
            "message": "Generation complete and uploaded."
        }
    except Exception as e:
        return {"status": "error", "message": f"Upload failed: {str(e)}"}

if __name__ == "__main__":
    # ComfyUIをバックグラウンドで起動
    subprocess.Popen(["python3", "/comfyui/main.py", "--port", "8188", "--cpu"]) # GPUが認識されない場合は必要に応じてフラグ調整
    
    # ComfyUIの準備を待機してからハンドラー開始
    if wait_for_comfyui():
        runpod.serverless.start({"handler": handler})
    else:
        print("ComfyUI failed to start.")