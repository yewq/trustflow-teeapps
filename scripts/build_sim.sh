#!/bin/bash
#
# Copyright 2023 Ant Group Co., Ltd.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e

BLUE='\033[1;34m'
NC='\033[0m'

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" >/dev/null 2>&1 && pwd )"
workspace_dir="$(dirname "$script_dir")"

target_dir="/home/teeapp"
python_dir="$target_dir/python"

mkdir -p $target_dir/task

cd $workspace_dir
bazel --output_base=target build -c opt --copt=-DSPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_DEBUG //teeapps/...
rm -rf $target_dir/sim
mkdir -p $target_dir/sim

cd $target_dir/sim
mkdir -p teeapps/biz

# copy biz algorithms
for folder in $workspace_dir/teeapps/biz/*; do
  if [ -d "$folder" ]; then
    folder_name=$(basename "$folder")
    if [ $folder_name == "testdata" ]; then
      continue
    fi
    cp $folder/*.py teeapps/biz/
  fi
done

cd $target_dir/sim/teeapps/biz
# Note: secretflow/spec and teeapps/proto can copy from any biz dir
cp -rL $workspace_dir/bazel-bin/teeapps/biz/psi/psi.runfiles/sf_spec/secretflow ./
# copy common
mkdir -p teeapps/biz/common/
cp $workspace_dir/teeapps/biz/common/common.py teeapps/biz/common/

cd $target_dir
[ -d $python_dir ] || conda create --prefix $python_dir -y python=3.8.10 pandas protobuf scikit-learn xgboost lightgbm statsmodels

if [ ! -d $python_dir ];then
    echo "Error: cannot stat '$python_dir' directory"
    exit 1
fi

cp $workspace_dir/bazel-bin/teeapps/framework/main $target_dir/sim/teeapps/.

mkdir -p /host/certs

# test dataset
mkdir -p /host/testdata/breast_cancer
mkdir -p /host/integration_test
cp -r $workspace_dir/integration_test/* /host/integration_test/

# build llama.cpp
apt update -y
apt install git cmake g++ -y
cd $workspace_dir
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
cmake -B build
cmake --build build -j 8
cp $workspace_dir/llama.cpp/build/bin/llama-cli $target_dir/sim/teeapps/biz/llama-cli
cp $workspace_dir/llama.cpp/build/src/libllama.so $target_dir/sim/teeapps/biz/libllama.so
cp $workspace_dir/llama.cpp/build/ggml/src/*.so $target_dir/sim/teeapps/biz/
