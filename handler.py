import os
import torch
import runpod

import diffusers
import sys
print(f"--- DEBUG: Python version is {sys.version} ---")
print(f"--- DEBUG: Diffusers path is {diffusers.__file__} ---")
try:
    print(f"--- DEBUG: Diffusers version is {diffusers.__version__} ---")
except Exception as e:
    print(f"--- DEBUG: Cannot get version {e} ---")



from diffusers import LTXVideoPipeline

pipe = None

def load_model():
    global pipe
    if pipe is None:
        # コンテナ内のローカルストレージ上にキャッシュフォルダを作成
        cache_dir = "/app/huggingface-cache"
        model_id = "Civitai/Sulphur-2-distilled-fp8"
        
        print(f"Sulphur-2-FP8を読み込んでいます（キャッシュ先: {cache_dir}）...")
        
        # local_files_onlyはFalseにし、初回到着時のみネットからDLしてキャッシュに保存させます
        pipe = LTXVideoPipeline.from_pretrained(
            model_id,
            cache_dir=cache_dir,
            torch_dtype=torch.float16,
            local_files_only=False
        ).to("cuda")
        
        pipe.enable_model_cpu_offload() 
    return pipe

def handler(job):
    job_input = job['input']
    prompt = job_input.get("prompt", "A futuristic city at night, cinematic.")
    
    pipeline = load_model()
    
    with torch.inference_mode():
        video_frames = pipeline(
            prompt=prompt, 
            num_inference_steps=8,
            num_frames=121
        ).frames[0]
    
    # 完了メッセージを返す（動画の保存処理はここに後から追加可能）
    return {"status": "success", "message": "動画の生成が完了しました！"}

runpod.serverless.start({"handler": handler})