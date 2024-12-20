FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
LABEL maintainer="nanfengnan@foxmail.com"

WORKDIR /opt/

# update ubuntu source
ARG source=/etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse" > ${source} \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse" >> ${source} \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse" >> ${source} \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse" >> ${source} \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse" >> ${source}

# update timezone
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

# extra tools
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
      tzdata apt-utils vim ripgrep dialog gdb wget

# vpp deps
RUN apt-get install -y --no-install-recommends \
      curl build-essential autoconf automake ccache debhelper \
      dkms git libtool libapr1-dev dh-python libconfuse-dev \
      git-review exuberant-ctags cscope pkg-config gcovr lcov \
      chrpath autoconf libnuma-dev python3-all python3-setuptools \
      check libffi-dev python3-ply libunwind-dev cmake ninja-build \
      python3-jsonschema python3-yaml python3-venv python3-dev \
      python3-pip libnl-3-dev libnl-route-3-dev libmnl-dev python3-virtualenv \
      libssl-dev libelf-dev nasm libpcap-dev iperf3 iperf ethtool libpcap-dev \
      tshark jq python3-virtualenv libssl-dev llvm-15 clang-15 clang-format-15 enchant-2 libffi7

# virtual python envirment for doc and test
RUN pip install --upgrade pip
RUN pip3 install virtualenv
RUN virtualenv venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt /opt/
RUN pip install -r requirements.txt

# update nasm -> 16.02
# RUN mkdir -p /opt/deps/ \
#    && cd /opt/deps/ \
#    && wget https://gitee.com/mirrors/nasm/repository/archive/nasm-2.16.02.zip \
#    && unzip nasm-2.16.02.zip \
#    && cd nasm-nasm-2.16.02 \
#    && ./autogen.sh && ./configure \
#    && make -j`nproc` && make install

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    rm -fr /opt/deps

CMD ["/bin/bash"]
