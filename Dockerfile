FROM ubuntu:18.04
MAINTAINER Hawtian Wang twistoy.wang@gmail.com

ARG SHA_SHORT="short"

# install dependencies
RUN apt update && apt install -y \
    sudo \
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
    openssl \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg-agent

# install docker inside container
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
  apt install -y docker-ce docker-ce-cli containerd.io

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
RUN mkdir -p /tools/llvm/ && cd /tools/llvm/ && \
  wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz && \
  tar xf clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz && \
  rm *.tar.xz && mv clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-16.04/ llvm

# install fish shell
RUN apt-add-repository ppa:fish-shell/release-3 -y && \
  apt update && apt install -y fish

# install neovim libraries
RUN python3 -m pip install --no-cache-dir pynvim && npm install -g neovim

# install other language servers
RUN yarn global add diagnostic-languageserver && \
  python3 -m pip install --no-cache-dir cpplint && \
  mkdir -p /tools/cppcheck && cd /tools/cppcheck && \
  wget https://github.com/danmar/cppcheck/archive/2.2.tar.gz && \
  tar xf 2.2.tar.gz && rm 2.2.tar.gz && cd cppcheck-2.2 && \
  make -j4

ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  apt install -y expect && \
  dpkg-reconfigure --frontend noninteractive tzdata

# FORCE REFRESH
COPY /tmp/git_commit /tmp/build_commit

# install latest neovim
RUN mkdir -p /tmp/neovim && cd /tmp/neovim && \
  wget https://github.com/neovim/neovim/archive/master.zip && unzip master.zip && \
  cd neovim-master/ && make CMAKE_BUILD_TYPE=RelWithDebInfo -j4 && \
  make install && rm -rf /tmp/neovim

RUN useradd -m dev && echo "dev:dev" | chpasswd && \
  usermod -aG docker dev && \
  usermod -aG sudo dev && \
  sed -i 's/^%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers

USER dev
WORKDIR /home/dev

# install fisher
RUN curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish && \
  fish -c "fisher add laughedelic/pisces" && \
  fish -c "fisher add oh-my-fish/theme-coffeeandcode"

# install rust, cargo and other tools
COPY rust.expect /tmp/rust.expect
RUN cd /tmp && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/install_rust.sh && \
  chmod +x /tmp/install_rust.sh && expect rust.expect && \
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc && \
  /home/dev/.cargo/bin/rustup update && /home/dev/.cargo/bin/rustup default stable

# RUN /home/dev/.cargo/bin/cargo install 
RUN /home/dev/.cargo/bin/cargo install \
  ripgrep skim zoxide fd-find bat exa fselect tree cargo-add bindgen

COPY dotvim.toml /home/dev/.dotvim.toml
COPY wakatime.cfg /home/dev/.wakatime.cfg

# install neovim plugins
RUN cd /home/dev && git clone https://github.com/TwIStOy/dotvim.git .dotvim && \
  mkdir -p /home/dev/.config/nvim/ && \
  echo 'set runtimepath+=$HOME/.dotvim' > /home/dev/.config/nvim/init.vim && \
  echo 'call dotvim#bootstrap()' >> /home/dev/.config/nvim/init.vim

# setup coc
COPY coc-settings.json /home/dev/.config/nvim/coc-settings.json

# special LeaderF
RUN sudo apt install -y python3-dev python-dev && \
  mkdir -p ~/.cache/dein/repos/github.com/Yggdroot/ && cd ~/.cache/dein/repos/github.com/Yggdroot/ && \
  git clone https://github.com/Yggdroot/LeaderF.git && cd LeaderF && \
  ./install.sh

# install missing plugins
RUN nvim -c ':qall'
RUN nvim ":CocInstall -sync coc-clangd coc-fish coc-git coc-highlight coc-json coc-tabnine coc-template coc-tsserver coc-ultisnips coc-vimlsp|q"
