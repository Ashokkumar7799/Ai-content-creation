import gradio as gr
from f5_tts.infer.utils_infer import load_model, load_vocoder, infer_process
from f5_tts.model.backbones.dit import DiT
import os

print("Loading Telugu Model... (This takes a few seconds)")

# Define local paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models", "telugu_model", "F5TTS_v1_Base")

ckpt_path = os.path.join(MODEL_DIR, "model_250000.pt")
vocab_file = os.path.join(MODEL_DIR, "vocab.txt")

vocoder = load_vocoder()
model_cfg = dict(dim=1024, depth=22, heads=16, ff_mult=2, text_dim=512, conv_layers=4)

# Force-load the custom Telugu Checkpoint
model = load_model(
    model_cls=DiT,
    model_cfg=model_cfg,
    ckpt_path=ckpt_path,
    vocab_file=vocab_file,
    mel_spec_type="vocos",
    use_ema=True,
)

print("✅ Telugu Model Loaded Successfully!")

def generate_telugu(ref_audio, ref_text, gen_text):
    if not ref_audio:
        raise gr.Error("Please upload a Reference Audio file.")
    if not ref_text or ref_text.strip() == "":
        raise gr.Error("Please enter the Reference Text (what the person is saying in the audio).")
    if not gen_text or gen_text.strip() == "":
        raise gr.Error("Please enter the Text to Generate.")
    
    # Strip whitespace to prevent hidden trailing space issues
    ref_text = ref_text.strip()
    gen_text = gen_text.strip()
    
    # Safety fallback to prevent IndexError inside F5-TTS core if somehow still empty
    if len(ref_text) == 0:
        ref_text = "."
    audio_out, sample_rate, spec = infer_process(
        ref_audio,
        ref_text,
        gen_text,
        model,
        vocoder,
        cross_fade_duration=0.15
    )
    return (sample_rate, audio_out)

# Build the Web UI
with gr.Blocks() as app:
    gr.Markdown("# F5-TTS Telugu Voice Generator 🇮🇳")
    with gr.Row():
        with gr.Column():
            ref_audio = gr.Audio(type="filepath", label="Reference Audio (Upload someone speaking Telugu)")
            ref_text = gr.Textbox(label="Reference Text (What are they saying in the audio?)", value="సరిహద్దు వద్దకు అదనపు బలగాలను పంపడం నిలిపివేయాలని నిర్ణయించుకున్నాయి..")
            gen_text = gr.Textbox(label="Text to Generate", value="నమస్కారం, మీరు ఎలా ఉన్నారు?")
            btn = gr.Button("Generate Telugu Speech", variant="primary")

        with gr.Column():
            output_audio = gr.Audio(label="Generated Audio")

    btn.click(generate_telugu, inputs=[ref_audio, ref_text, gen_text], outputs=[output_audio])

# Run on port 7860 to map nicely with our Pinggy setup
if __name__ == "__main__":
    app.launch(server_name="0.0.0.0", server_port=7860, share=False)
