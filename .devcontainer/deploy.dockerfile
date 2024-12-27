FROM nvidia/cuda:12.6.3-devel-ubuntu22.04
LABEL maintainer="Nelson Yalta <nyalta21@gmail.com>"

ENV NUM_BUILD_CORES=12
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        build-essential \
        cmake \
        libffi-dev \
        libncurses5-dev \
        software-properties-common \
        unzip \
        wget \
        zip \
        zlib1g-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Latest version of git
ENV TZ=Etc/UTC
RUN add-apt-repository ppa:git-core/ppa -y && \
    apt update && \
    apt install -y --no-install-recommends git-all && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --tries=3 -nv "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda && \
    /opt/miniconda/bin/conda config --prepend channels https://software.repos.intel.com/python/conda/ && \
    rm miniconda.sh

ENV PATH=/opt/miniconda/bin:${PATH}

RUN conda install -y python=3.10 && \
    conda clean -a -y

ENV HF_HOME=/workspace/.hf_cache
WORKDIR /
