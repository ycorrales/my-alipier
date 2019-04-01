FROM alipier/alidock:latest

LABEL maintainer="Yasser Corrales Morales <ycorrale@cern.ch>"

ENV SINGULARITY_GIT_VERSION 2.5.0

RUN yum install -y libarchive-devel squashfs-tools && \
    rm -rf /var/cache/yum/*
RUN cd /tmp && \
    git clone https://github.com/sylabs/singularity.git -b $SINGULARITY_GIT_VERSION && \
    pushd singularity && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j10 && \
    make install && \
    popd && \
    rm -rf *
