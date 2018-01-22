FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

MAINTAINER Boris Kovalev <borisko@mellanox.com>

WORKDIR /

# Pick up some MOFED and TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	net-tools \
        ethtool \
        perl \
        lsb-release \
        iproute2 \
        pciutils \
        libnl-route-3-200 \
        kmod \
        libnuma1 \
        lsof \
        linux-headers-4.4.0-92-generic \
        build-essential \
        curl \
        git \
        wget \
        libcurl3-dev \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python-dev \
        python-virtualenv \
        swig \
        python-wheel \
        libcupti-dev \
        python-numpy \
        python-pip \
        python-wheel \
        python-libxml2 \
        rsync \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev \
        openjdk-8-jdk \
        openjdk-8-jre-headless \
        git \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Mellanox OFED 4.2.1
RUN wget http://content.mellanox.com/ofed/MLNX_OFED-4.2-1.0.0.0/MLNX_OFED_LINUX-4.2-1.0.0.0-ubuntu16.04-x86_64.tgz && \
        tar -xzvf MLNX_OFED_LINUX-4.2-1.0.0.0-ubuntu16.04-x86_64.tgz && \
        MLNX_OFED_LINUX-4.2-1.0.0.0-ubuntu16.04-x86_64/mlnxofedinstall --user-space-only --without-fw-update --all -q && \
        cd .. && \
        rm -rf MLNX_OFED_LINUX-4.2-1.0.0.0-ubuntu16.04-x86_64 && \
        rm -rf *.tgz

# Download and install pip and pip packages
RUN curl -fSsL -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py
RUN pip --no-cache-dir install \
    ipykernel \
    matplotlib \
    numpy \
    scipy \
    sklearn \
    pandas \
    && \
   python -m ipykernel.kernelspec

# Download and pip install a TensorFlow v1.4 package with verbs support
RUN git clone https://github.com/boriskovalev/tf14docker.git && \
    pip --no-cache-dir install --upgrade /tf14docker/tensorflow-1.4.0-cp27-cp27mu-linux_x86_64.whl && \
    rm -rf /tf14docker/tensorflow-1.4.0-cp27-cp27mu-linux_x86_64.whl && \
    rm -rf /pip && \
    rm -rf /root/.cache

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# TensorBoard
EXPOSE 6006

RUN ["/bin/bash"]
