import argparse
import torch
from transformers import AutoTokenizer, RobertaForMaskedLM


def main(args=None) -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True, choices=["trace", "state-dict"])
    parser.add_argument("--model", required=True)
    parser.add_argument("--input")
    parser.add_argument("--output", required=True)
    parser.add_argument("--tokenizer-output", required=True)
    args = parser.parse_args()

    tokenizer = AutoTokenizer.from_pretrained(args.model)
    with open(args.tokenizer_output, 'w') as fp:
        fp.write(tokenizer.backend_tokenizer.to_str(pretty=False))

    if args.mode == "trace":
        model = RobertaForMaskedLM.from_pretrained(args.model, torchscript=True)
        model.eval()
        inputs = tokenizer(args.input, return_tensors="pt")  # Batch size 1
        traced_script_module = torch.jit.trace(
            model, (inputs.input_ids, inputs.attention_mask, inputs.token_type_ids)
        )
        traced_script_module.save(args.output)
    elif args.mode == "state-dict":
        model = RobertaForMaskedLM.from_pretrained(args.model, torchscript=False)
        d = dict(model.state_dict())
        torch.save(d, args.output, _use_new_zipfile_serialization=True)
    else:
        raise NotImplementedError()


if __name__ == "__main__":
    main()
