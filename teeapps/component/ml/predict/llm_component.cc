#include "llm_component.h"

namespace teeapps
{
    namespace component
    {
        void LlmPredComponent::Init()
        {
            AddIo(IoType::INPUT, "llm_prompt", "Input prompt.", {DistDataType::LLM_PROMPT});
            AddIo(IoType::INPUT, "llm_model", "Input model.", {DistDataType::LLM_MODEL});
            AddIo(IoType::OUTPUT, "predict", "Output prediction.", {DistDataType::LLM_PREDICT});
        }
    }
}
