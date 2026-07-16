import os
import json
import urllib.request
import time
import runpod
from runpod.serverless.utils import rp_upload

def handler(job):
    job_input = job.get("input", {})
    prompt_text = job_input.get("prompt", "A futuristic high-tech machinery") # デフォルト値

    with open("/workflow_api.json", "r") as f:
        workflow = json.load(f)

    # 【重要】プロンプト差し替え
    # ノードID '267:266' は PrimitiveStringMultiline なので 'value' キーを書き換える
    if "267:266" in workflow:
        workflow["267:266"]["inputs"]["value"] = prompt_text

    # プロンプト送信（API形式）
    req_data = json.dumps({"prompt": workflow}).encode('utf-8')
    req = urllib.request.Request("http://127.0.0.1:8188/prompt", data=req_data)
    req.add_header('Content-Type', 'application/json')
    
    try:
        with urllib.request.urlopen(req) as response:
            response_data = json.loads(response.read().decode('utf-8'))
            prompt_id = response_data.get("prompt_id")
            
            # 生成完了を待つ（簡易的なポーリング）
            return {"status": "success", "prompt_id": prompt_id}
            
    except Exception as e:
        return {"status": "error", "message": f"ComfyUI Request Failed: {str(e)}"}

if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})