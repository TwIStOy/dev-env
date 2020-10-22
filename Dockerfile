FROM ubuntu:18.04
MAINTAINER Hawtian Wang twistoy.wang@gmail.com

# install dependencies
RUN apt update && apt install -y \
    gcc \
    g++ \
    git \
    make \
    pkg-config \
    automake \
    libtool \
    curl \
    unzip \
    libtool-bin \
    gettext \
    wget \
    python3-pip \
    libssl-dev \
    openssl

# install latest node && npm
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm install -g yarn

# install latest cmake
RUN mkdir -p /tmp/cmake && cd /tmp/cmake && \
  wget https://github.com/Kitware/CMake/releases/download/v3.19.0-rc1/cmake-3.19.0-rc1.tar.gz && \
  tar xf cmake-3.19.0-rc1.tar.gz && \
  cd /tmp/cmake/cmake-3.19.0-rc1/ && \
  ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release && \
  make -j4 && make install && rm -rf /tmp/cmake

# install latest clang && clangd
RUN mkdir -p /tools/llvm && cd /tools/llvm && \
  wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/llvm-11.0.0.src.tar.xz && \
  wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang-11.0.0.src.tar.xz && \
  wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang-tools-extra-11.0.0.src.tar.xz && \
  tar xf llvm-11.0.0.src.tar.xz && tar xf clang-11.0.0.src.tar.xz && tar xf clang-tools-extra-11.0.0.src.tar.xz && \
  rm *.tar.xz && \
  mv llvm-11.0.0.src/ llvm && mv clang-11.0.0.src llvm/tools/clang && \
  mv clang-tools-extra-11.0.0.src/ llvm/tools/clang/tools/extra && \
  mkdir -p /tools/llvm/build && cd /tools/llvm/build && \
  cmake -G "Unix Makefiles" ../llvm/ && make clangd -j4

# install neovim libraries
RUN python3 -m pip install --no-cache-dir pynvim && npm install -g neovim

# install latest neovim
RUN mkdir -p /tmp/neovim && cd /tmp/neovim && \
  wget https://github.com/neovim/neovim/archive/master.zip && unzip master.zip && \
  cd neovim-master/ && make CMAKE_BUILD_TYPE=RelWithDebInfo -j4 && \
  make install && rm -rf /tmp/neovim

# install neovim plugins












