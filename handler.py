import os
import torch
import runpod
from diffusers import DiffusionPipeline  # 汎用Pipelineクラスを使用する
from diffusers.utils import export_to_video

# キャッシュディレクトリの設定
cache_dir = "/app/huggingface-cache"
os.makedirs(cache_dir, exist_ok=True)

# 起動時のデバッグ用プリント
try:
    import diffusers
    print(f"--- DEBUG: Diffusers version is {diffusers.__version__} ---")
except Exception as e:
    print(f"--- DEBUG: Failed to check diffusers version: {e} ---")

# グローバル変数としてパイプラインを保持
pipe = None

def load_model():
    global pipe
    model_id = "Civitai/Sulphur-2-distilled-fp8"
    print(f"Loading model: {model_id} ...")
    
    # FP8モデルをロードするために最適な設定
    # DiffusionPipelineを使用することで、Hugging Face側で設定された正しいパイプラインクラスが自動選択されます
    pipe = DiffusionPipeline.from_pretrained(
        model_id,
        cache_dir=cache_dir,
        torch_dtype=torch.bfloat16,  # 内部計算用のdtype
        device_map="auto",           # メモリ節約と正しいデバイス配置のため
        local_files_only=False
    )
    
    # ⚠️ モデル全体のVRAM消費と起動速度のバランスを取るため、
    # もしエラー（OOM等）が起きる場合は、以下の行を有効にしてください
    # pipe.enable_model_cpu_offload() 
    
    print("Model loaded successfully!")

# コンテナ起動時にモデルをロード（コールドスタート時）
load_model()

def handler(job):
    """
    RunPod Serverlessのジョブを処理するハンドラー関数
    """
    try:
        job_input = job.get("input", {})
        prompt = job_input.get("prompt", "A futuristic city at night, 4k, high resolution")
        negative_prompt = job_input.get("negative_prompt", "worst quality, low quality")
        
        # パラメータの取得（LTX-Video推奨は 8*n + 1 フレーム）
        num_frames = job_input.get("num_frames", 161) # ~6-7秒分
        width = job_input.get("width", 768)
        height = job_input.get("height", 512)
        num_inference_steps = job_input.get("num_inference_steps", 30)
        
        # Distilled(蒸留)モデルの場合、guidance_scaleは 1.0 または 3.0 付近が推奨されます
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
            
        # 生成されたフレームをmp4ビデオファイルとして保存
        output_path = "/tmp/output_video.mp4"
        export_to_video(video_frames, output_path, fps=24)
        print(f"Video saved to {output_path}")
        
        # TODO: 生成した動画ファイルをS3等に転送し、そのURLを返す処理を推奨
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