import os
import torch
import runpod
from diffusers import DiffusionPipeline
from diffusers.utils import export_to_video

# キャッシュディレクトリの設定
cache_dir = "/app/huggingface-cache"
os.makedirs(cache_dir, exist_ok=True)

# グローバル変数としてパイプラインを保持
pipe = None

def load_model():
    global pipe
    # model_id = "Civitai/Sulphur-2-distilled-fp8"
    model_id = "Kijai/Sulphur-2-distilled-fp8"
    print(f"Loading model: {model_id} ...")
    
    try:
        # FP8モデルを安全に読み込むための設定
        pipe = DiffusionPipeline.from_pretrained(
            model_id,
            cache_dir=cache_dir,
            torch_dtype=torch.bfloat16,  # 内部計算用の精度
            device_map="balanced",           # "auto" から "balanced" に修正
            local_files_only=False
        )
        print("Model loaded successfully!")
    except Exception as e:
        print(f"❌ FATAL ERROR: Failed to load model: {str(e)}")
        import traceback
        print(traceback.format_exc())
        pipe = None  # 明示的にNoneにしておく

# コンテナ起動時にモデルをロード
load_model()

def handler(job):
    """
    RunPod Serverlessのジョブを処理するハンドラー関数
    """
    global pipe
    
    # 起動時にロードが失敗していた場合は、リクエスト時点でエラーを返却する
    if pipe is None:
        return {
            "status": "error",
            "message": "Model is not loaded. Please check the container initialization logs."
        }
        
    try:
        job_input = job.get("input", {})
        prompt = job_input.get("prompt", "A futuristic city at night, 4k, high resolution")
        negative_prompt = job_input.get("negative_prompt", "worst quality, low quality")
        
        num_frames = job_input.get("num_frames", 161)
        width = job_input.get("width", 768)
        height = job_input.get("height", 512)
        num_inference_steps = job_input.get("num_inference_steps", 30)
        guidance_scale = job_input.get("guidance_scale", 3.0)
        
        print(f"Generating video for prompt: '{prompt}'")
        
        # ビデオ生成の実行
        with torch.inference_mode():
            video_frames = pipe(
                prompt=prompt,
                negative_prompt=negative_prompt,
                width=width,
                height=height,
                num_frames=num_frames,
                num_inference_steps=num_inference_steps,
                guidance_scale=guidance_scale,
                output_type="np"
            ).frames[0]
            
        output_path = "/tmp/output_video.mp4"
        export_to_video(video_frames, output_path, fps=24)
        print(f"Video saved to {output_path}")
        
        return {
            "status": "success",
            "message": "Video generated successfully",
            "local_path": output_path
        }
        
    except Exception as e:
        import traceback
        error_msg = f"Error during execution: {str(e)}\n{traceback.format_exc()}"
        print(error_msg)
        return {
            "status": "error",
            "message": error_msg
        }

# RunPodのワーカーサービスを開始
runpod.serverless.start({"handler": handler})