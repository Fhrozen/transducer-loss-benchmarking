#!/bin/bash
set -e
set -u
set -o pipefail

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

batch_size=10

log "Benchmark Torchaudio"
# python benchmark_torchaudio.py --batch-size ${batch_size}

has_ot=$(python3 <<EOF
try:
    import optimized_transducer
    print("1")
except ImportError:
    print("0")
EOF
)
if [ ${has_ot} -gt 0 ]; then
    log "Benchmark Optimized Transducer"
    python benchmark_ot.py
fi

has_k2=$(python3 <<EOF
try:
    import k2
    print("1")
except ImportError:
    print("0")
EOF
)
if [ ${has_k2} -gt 0 ]; then
    log "Benchmark K2"
    # python benchmark_k2.py --batch-size ${batch_size}

    # log "Benchmark K2-pruneed"
    # python benchmark_k2_pruned.py --batch-size ${batch_size} 
fi

has_warprnnt_pytorch=$(python3 <<EOF
try:
    import warprnnt_pytorch
    print("1")
except ImportError:
    print("0")
EOF
)
if [ ${has_warprnnt_pytorch} -gt 0 ]; then
    log "Benchmark Warp Transducer"
    python benchmark_warp_transducer.py --batch-size ${batch_size} 
fi

log "Benchmark SpeechBrain"
python benchmark_speechbrain.py --batch-size ${batch_size} 

log "Done"
