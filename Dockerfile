FROM ubuntu:18.04

RUN \
    echo "===== change tsinghua mirrors =====" && \
    cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "# deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake git build-essential curl && \
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN \
    echo "===== install opencv4 =====" && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common && \
    add-apt-repository "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main" && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev \
    libavformat-dev libswscale-dev python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev \
    libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev \
    libopenexr-dev libxvidcore-dev libx264-dev libatlas-base-dev gfortran ffmpeg && \
    echo "downloading opencv4..." && \
    git clone https://github.com/opencv/opencv.git $HOME/install/opencv --branch 4.1.2 --progress && \
    git clone https://github.com/opencv/opencv_contrib.git $HOME/install/opencv_contrib --branch 4.1.2 --progress && \
    echo "making opencv4..." && \
    mkdir $HOME/install/opencv/build && \
    cd $HOME/install/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D OPENCV_ENABLE_NONFREE=ON -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=$HOME/install/opencv_contrib/modules .. && \
    cp -r $HOME/install/opencv/.cache/xfeatures2d/* $HOME/install/opencv_contrib/modules/xfeatures2d/src/ && \
    make -j$(nproc) && make install && \
    echo "/usr/local/opencv4/lib" > /etc/ld.so.conf.d/opencv4.conf && ldconfig && \
    echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opencv4/lib/pkgconfig" >> /etc/bash.bashrc && \
    echo "export PKG_CONFIG_PATH" >> /etc/bash.bashrc && \
    /bin/bash -c "source /etc/bash.bashrc" && \
    rm -rf $HOME/install/opencv/ $HOME/install/opencv_contrib/ && \
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN \
    echo "===== install spdlog =====" && \
    echo "downloading spdlog..." && \
    git clone https://github.com/gabime/spdlog.git $HOME/install/spdlog --branch v1.4.2 --progress && \
    echo "making spdlog..." && \
    mkdir $HOME/install/spdlog/build && cd $HOME/install/spdlog/build && \
    cmake .. && make -j$(nproc) && make install && \
    rm -rf $HOME/install/spdlog/ && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN \
    echo "===== install mxnet =====" && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential git libatlas-base-dev libopencv-dev python && \
    echo "downloading mxnet..." && \
    git clone --no-checkout https://github.com/apache/incubator-mxnet.git $HOME/install/mxnet --progress && \
    cd $HOME/install/mxnet && \
    git checkout 1.5.1 -b 1.5.1 && \
    git submodule update --init && \
    echo "making mxnet..." && \
    cp $HOME/install/mxnet/make/config.mk $HOME/install/mxnet && \
    sed -i 's/USE_CPP_PACKAGE = 0/USE_CPP_PACKAGE = 1/g' $HOME/install/mxnet/config.mk && \
    sed -i 's/USE_MKLDNN =/USE_MKLDNN = 1/g' $HOME/install/mxnet/config.mk && \
    make -j$(nproc) && \
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libyaml-cpp-dev libjpeg-turbo8-dev qt5-default nano && \
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ADD library.tar.xz /
