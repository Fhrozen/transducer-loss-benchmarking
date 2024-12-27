#!/bin/bash

set -e
set -u
set -o pipefail

MAIN_DIR=${PWD}

# Additionals
conda install -y numba

# Install torchaudio
# At the moment pytorch 2.5.1
conda install -y pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

# Install K2
cuda_version=$(python3 <<EOF
try:
    import torch
except:
    raise RuntimeError("Please install torch before running this script")

if torch.cuda.is_available():
    version=torch.version.cuda.split(".")
    # 10.1.aa -> 10.1
    print(version[0] + "." + version[1])
else:
    print("")
EOF
)
torch_version=$(python3 <<EOF
import torch
# e.g. 1.10.0+cpu -> 1.10.0
torch_version=torch.__version__.split("+")[0]
print(torch_version)
EOF
)
pip_k2_version=1.24.4.dev20241127
# https://huggingface.co/csukuangfj/k2/resolve/main/ubuntu-cuda/k2-1.24.4.dev20241127+cuda12.4.torch2.5.1-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
# conda install -y -c k2-fsa -c pytorch -c conda-forge k2=1.24.4.dev20241127 "cudatoolkit=${cuda_version}" "pytorch=${torch_version}"
pip install "k2==${pip_k2_version}+cuda${cuda_version}.torch${torch_version}" -f https://k2-fsa.github.io/k2/cuda.html

# # Install optimized_transducer
# pip install optimized_transducer

# Install warprnnt_numba
pip install --upgrade git+https://github.com/titu1994/warprnnt_numba.git

# Install warp-transducer
# cd /opt
# git clone --single-branch --branch update_torch2.1 https://github.com/b-flo/warp-transducer.git
# (
#     set -euo pipefail
#     cd warp-transducer

#     mkdir build
#     (
#         set -euo pipefail
#         cd build && cmake -DWITH_OMP=ON .. && make
#         # cd build && cmake -DWITH_OMP="${with_openmp}" -DCMAKE_CXX_FLAGS="-std=c++1z" .. && make
#     )

#     (
#         set -euo pipefail
#         cd pytorch_binding && python3 -m pip install -e .
#     )
# )
# cd ${MAIN_DIR}

# Install warp_rnnt
# The installation of warp_rnnt is skipped.

# Install SpeechBrain
# You don't need to install SpeechBrain. 
# We have saved the file that is for computing RNN-T loss into this repo using the following commands:
rnnt_link="https://raw.githubusercontent.com/speechbrain/speechbrain/develop/speechbrain/nnet/loss/transducer_loss.py"

wget ${rnnt_link}
mv transducer_loss.py speechbrain_rnnt_loss.py
echo "# This file is downloaded from ${rnnt_link}" >> speechbrain_rnnt_loss.py

# Install PyTorch profiler TensorBoard plugin
pip install torch-tb-profiler
