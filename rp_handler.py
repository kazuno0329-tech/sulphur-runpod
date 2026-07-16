import os
import json
import urllib.request
import urllib.parse
import runpod
from runpod.serverless.utils import rp_upload
from huggingface_hub import hf_hub_download

# --- コンテナ起動時にモデルが存在しない場合、自動でダウンロードする ---
MODEL_PATH = "/comfyui/models/checkpoints/Sulphur-2-distilled-fp8.safetensors"
if not os.path.exists(MODEL_PATH):
    print("Sulphur-2 model not found. Starting secure download from Hugging Face...")
    hf_token = os.environ.get("HF_TOKEN")
    if not hf_token:
        print("WARNING: 'HF_TOKEN' environment variable is not set! Download might fail if the repo is private/gated.")
    
    try:
        os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
        downloaded_file = hf_hub_download(
            repo_id="SulphurAI/Sulphur-2-base",
            filename="Sulphur-2-distilled-fp8.safetensors",
            local_dir="/comfyui/models/checkpoints",
            local_dir_use_symlinks=False,
            token=hf_token
        )
        print(f"Model downloaded successfully to: {downloaded_file}")
    except Exception as e:
        print(f"Error during model download: {e}")
        raise e
# ----------------------------------------------------------------------

COMFYUI_ADDRESS = "127.0.0.1:8188"

def queue_prompt(prompt_workflow):
    p = {"prompt": prompt_workflow}
    data = json.dumps(p).encode('utf-8')
    req = urllib.request.Request(f"http://{COMFYUI_ADDRESS}/prompt", data=data)
    req.add_header('Content-Type', 'application/json')
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode('utf-8'))

def handler(job):
    job_input = job.get("input", {})
    
    prompt_text = job_input.get("prompt", "A futuristic city at night, 4k, high resolution")
    negative_prompt_text = job_input.get("negative_prompt", "worst quality, low quality")
    seed = job_input.get("seed", 42)
    
    # 1. 保存した設計図をロード
    with open("/workflow_api.json", "r") as f:
        workflow = json.load(f)
        
    # 2. ワークフロー内のプロンプト書き換え
    for node_id, node in workflow.items():
        if node.get("class_type") == "CLIPTextEncode" and "positive" in str(node.get("_meta", {}).get("title", "")).lower():
            node["inputs"]["text"] = prompt_text
        elif node.get("class_type") == "CLIPTextEncode" and "negative" in str(node.get("_meta", {}).get("title", "")).lower():
            node["inputs"]["text"] = negative_prompt_text
        elif "Sampler" in node.get("class_type", ""):
            if "seed" in node["inputs"]:
                node["inputs"]["seed"] = seed

    print("Submitting workflow to ComfyUI...")
    result = queue_prompt(workflow)
    prompt_id = result.get("prompt_id")
    print(f"Workflow submitted! Prompt ID: {prompt_id}")
    
    # 3. 動画ができるのを監視
    import time
    output_dir = "/comfyui/output"
    video_path = None
    
    for _ in range(180):
        time.sleep(1)
        if os.path.exists(output_dir):
            files = [os.path.join(output_dir, f) for f in os.listdir(output_dir) if f.endswith(".mp4")]
            if files:
                video_path = max(files, key=os.path.getctime)
                break
            
    if not video_path:
        return {"status": "error", "message": "Video generation timed out inside ComfyUI"}

    print(f"Video generated successfully at: {video_path}")

    # 4. 生成した動画のアップロード or Base64返却
    if os.environ.get("BUCKET_ENDPOINT_URL"):
        print("Uploading video to cloud storage...")
        uploaded_url = rp_upload.upload_file(job["id"], video_path)
        return {
            "status": "success",
            "video_url": uploaded_url
        }
    else:
        import base64
        with open(video_path, "rb") as vf:
            encoded_video = base64.b64encode(vf.read()).decode("utf-8")
        return {
            "status": "success",
            "video_base64": encoded_video,
            "format": "mp4"
        }

runpod.serverless.start({"handler": handler})