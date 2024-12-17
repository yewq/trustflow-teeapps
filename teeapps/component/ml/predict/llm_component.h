#pragma once

#include "../../component.h"

namespace teeapps {
namespace component {

class LlmPredComponent : public Component {
 private:
  void Init();

  explicit LlmPredComponent(
      const std::string& name = "llm_predict",
      const std::string& domain = "ml.predict",
      const std::string& version = "0.0.1",
      const std::string& desc = "Predict using the llm model.")
      : Component(name, domain, version, desc) {
    Init();
  }
  ~LlmPredComponent() {}
  LlmPredComponent(const LlmPredComponent&) = delete;
  const LlmPredComponent& operator=(const LlmPredComponent&) = delete;

 public:
  static LlmPredComponent& GetInstance() {
    static LlmPredComponent instance;
    return instance;
  }
};

}  // namespace component
}  // namespace teeapps