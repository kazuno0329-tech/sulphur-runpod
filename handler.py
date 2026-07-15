import os
import torch
import runpod
# ⭕ 正しい公式クラス名「LTXPipeline」をインポート
from diffusers import LTXPipeline
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

# グローバル変数としてパイプラインを保持（起動時にロード）
pipe = None

def load_model():
    global pipe
    model_id = "Civitai/Sulphur-2-distilled-fp8"
    print(f"Loading model: {model_id} ...")
    
    # LTX-Videoは公式にbfloat16推奨のため、VRAMとメモリの節約を兼ねてbf16でロードします
    pipe = LTXPipeline.from_pretrained(
        model_id,
        cache_dir=cache_dir,
        torch_dtype=torch.bfloat16,
        local_files_only=False
    ).to("cuda")
    
    print("Model loaded successfully!")

# コンテナ起動時にモデルをロード（コールドスタート時に実行されます）
load_model()

def handler(job):
    """
    RunPod Serverlessのジョブを処理するハンドラー関数
    """
    try:
        job_input = job.get("input", {})
        prompt = job_input.get("prompt", "A futuristic city at night, 4k, high resolution")
        negative_prompt = job_input.get("negative_prompt", "worst quality, low quality")
        
        # LTX-Video用の各種パラメータ（必要に応じてクライアントから調整可能）
        num_frames = job_input.get("num_frames", 161) # LTX-Videoは「8 * n + 1」フレームが推奨
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
            
        # 生成されたフレームをmp4ビデオファイルとして保存
        output_path = "/tmp/output_video.mp4"
        export_to_video(video_frames, output_path, fps=24)
        print(f"Video saved to {output_path}")
        
        # TODO: 実際の運用時は、ここで生成されたビデオファイルをS3や
        # RunPodオブジェクトストレージ等にアップロードし、そのURLを返却することをお勧めします。
        # 今回はパスまたは仮の完了メッセージを返します。
        return {
            "status": "success",
            "message": "Video generated successfully",
            "local_path": output_path
        }
        
    except Exception as e:
        print(f"Error during execution: {str(e)}")
        return {
            "status": "error",
            "message": str(e)
        }

# RunPodのワーカーサービスを開始
runpod.serverless.start({"handler": handler})