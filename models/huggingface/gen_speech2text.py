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
    parser.add_argument("--mode", required=True, choices=["trace", "state-dict"])
    parser.add_argument("--model", required=True)
    parser.add_argument("--input")
    parser.add_argument("--decoder-input")
    parser.add_argument("--output", required=True)
    parser.add_argument("--tokenizer-output", required=True)
    args = parser.parse_args()

    tokenizer = AutoTokenizer.from_pretrained(args.model)
    with open(args.tokenizer_output, 'w') as fp:
        fp.write(tokenizer.backend_tokenizer.to_str(pretty=False))

    if args.mode == "trace":
        processor = Speech2TextProcessor.from_pretrained(args.model)
        model = Speech2TextForConditionalGeneration.from_pretrained(
            args.model, torchscript=True
        )
        model.eval()
        ds = load_dataset(
            "patrickvonplaten/librispeech_asr_dummy", "clean", split="validation"
        )
        ds = ds.map(map_to_array)
        inputs = processor(ds["speech"][0], sampling_rate=16_000, return_tensors="pt")
        decoder_inputs = tokenizer(args.decoder_input, return_tensors="pt")
        traced_script_module = torch.jit.trace(
            model,
            (
                inputs["input_features"],
                inputs["attention_mask"],
                decoder_inputs.input_ids,
                decoder_inputs.attention_mask,
            ),
        )
        traced_script_module.save(args.output)
    elif args.mode == "state-dict":
        model = Speech2TextForConditionalGeneration.from_pretrained(
            args.model, torchscript=False
        )
        d = dict(model.state_dict())
        torch.save(d, args.output, _use_new_zipfile_serialization=True)
    else:
        raise NotImplementedError()


if __name__ == "__main__":
    main()
