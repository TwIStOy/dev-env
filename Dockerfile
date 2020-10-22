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
    wget

# install latest node && npm
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm install -g yarn

# install latest cmake
RUN mkdir -p /tmp/cmake && cd /tmp/cmake && \
  wget https://github.com/Kitware/CMake/releases/download/v3.19.0-rc1/cmake-3.19.0-rc1.tar.gz && \
  tar xf cmake-3.19.0-rc1.tar.gz && \
  cd /tmp/cmake/cmake-3.19.0-rc1/ && ./bootstrap && make -j4 && make install && rm -rf /tmp/cmake

# install latest clang && clangd
RUN mkdir -p /tools/llvm && cd /tools/llvm && \
  wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/llvm-11.0.0.src.tar.xz && \
  wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang-11.0.0.src.tar.xz && \
  wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang-tools-extra-11.0.0.src.tar.xz && \
  tar xf llvm-11.0.0.src.tar.xz && tar xf clang-11.0.0.src.tar.xz && tar xf clang-tools-extra-11.0.0.src.tar.xz && \
  rm *.tar.xz && \
  mv llvm-11.0.0.src/ llvm && mv clang-11.0.0.src llvm/tools/clang && \
  mv clang-tools-extra-11.0.0.src/ llvm/tools/clang/extra && \
  mkdir -p /tools/build && cd /tools/build && \
  cmake -G "Unix Makefiles" ../llvm && make clangd -j4


# install latest neovim

# install neovim plugins

