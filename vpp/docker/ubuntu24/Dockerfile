FROM ubuntu:24.04

RUN groupadd -g 2000 alexan && \
    useradd -u 2000 -g alexan -d /home/alexan -s /bin/bash -m alexan

LABEL maintainer="nanfengnan@foxmail.com"

# update ubuntu source
ARG source=/etc/apt/sources.list.d/ubuntu.sources
RUN echo "Types: deb" > ${source} && \
    echo "URIs: http://mirrors.tuna.tsinghua.edu.cn/ubuntu/" >> ${source} && \
    echo "Suites: noble noble-updates noble-security" >> ${source} && \
    echo "Components: main restricted universe multiverse" >> ${source} && \
    echo "Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg" >> ${source} && \
    apt-get update

# update timezone
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    apt-get install -y --no-install-recommends \
        tzdata vim

# install alexan deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl build-essential autoconf automake ccache debhelper \
        dkms git libtool libapr1-dev dh-python libconfuse-dev git-review \
        exuberant-ctags cscope pkg-config gcovr lcov chrpath autoconf \
        libnuma-dev python3-all python3-setuptools check libffi-dev \
        python3-ply libunwind-dev cmake ninja-build python3-jsonschema \
        python3-yaml python3-venv python3-dev python3-pip libnl-3-dev \
        libnl-route-3-dev libmnl-dev python3-virtualenv libssl-dev \
        libelf-dev libpcap-dev  iperf3  nasm iperf ethtool libpcap-dev \
        tshark jq libssl-dev llvm-15 clang-15 clang-format-15 enchant-2 libffi8 \
	dialog gdb

RUN ln -sf /usr/bin/clang-15 /usr/bin/clang

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*


USER alexan
WORKDIR /home/alexan

CMD ["/bin/bash"]
