import argparse
import torch
from transformers import (
    AutoTokenizer,
    Speech2TextProcessor,
    Speech2TextForConditionalGeneration,
)
from datasets import load_dataset
import soundfile as sf


def map_to_array(batch):
    speech, _ = sf.read(batch["file"])
    batch["speech"] = speech
    return batch


def main(args=None) -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    processor = Speech2TextProcessor.from_pretrained(args.model)
    model = Speech2TextForConditionalGeneration.from_pretrained(
        args.model, torchscript=True
    )
    model.eval()
    ds = load_dataset(
        "patrickvonplaten/librispeech_asr_dummy", "clean", split="validation"
    )
    ds = ds.map(map_to_array)
    inputs = processor.(ds["speech"][0], sampling_rate=16_000, return_tensors="pt")
    generated_ids = model.generate
        (
            inputs["input_features"],
            inputs["attention_mask"]
        )
    transcription = processor.batch_decode(generated_ids)
    with open(args.output, 'w') as fp:
        fp.write(transcription.to_str())


if __name__ == "__main__":
    main()
