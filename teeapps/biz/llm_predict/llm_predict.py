import json
import logging
import sys
import subprocess

from teeapps.biz.common import common

COMPONENT_NAME = "llm_predict"

def run_llm_predict(task_config: dict) -> None:
    logging.info("Running llm_predict...")

    assert (
        task_config[common.COMPONENT_NAME] == COMPONENT_NAME
    ), f"Component name should be {COMPONENT_NAME}, but got {task_config[common.COMPONENT_NAME]}"

    inputs = task_config[common.INPUTS]
    outputs = task_config[common.OUTPUTS]
    assert len(inputs) == 2, f"{COMPONENT_NAME} should have only 2 input"
    assert len(outputs) == 1, f"{COMPONENT_NAME} should have only 1 output"

    # run llama-cli for predict
    with open(inputs[0][common.DATA_PATH], 'r') as file:
        prompt = file.read()
    predict = subprocess.run(["llama-cli", "--model", inputs[1][common.DATA_PATH], "--prompt", prompt, "--predict", "128"], capture_output=True, text=True)

    # dump predict
    logging.info("Dumping predict...")
    predict_path = outputs[0][common.DATA_PATH]
    with open(predict_path, "w") as file:
        file.write(predict.stdout)

def main():
    assert len(sys.argv) == 2, f"Wrong arguments number: {len(sys.argv)}"
    # load task_config json
    task_config_path = sys.argv[1]
    logging.info("Reading task config file...")
    with open(task_config_path, "r") as task_config_f:
        task_config = json.load(task_config_f)
        logging.debug(f"Configurations: {task_config}")
        run_llm_predict(task_config)

if __name__ == "__main__":
    # TODO set log level
    logging.basicConfig(
        stream=sys.stdout,
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    main()
