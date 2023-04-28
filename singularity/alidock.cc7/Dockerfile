FROM alipier/alidock:latest

LABEL maintainer="Yasser Corrales Morales <ycorrale@cern.ch>"

ENV SINGULARITY_GIT_VERSION v3.11.2

# Install RPM packages for dependencies
RUN yum groupinstall -y 'Development Tools' &&  \
    yum install -y libseccomp-devel glib2-devel \
    squashfs-tools cryptsetup runc git wget && \
    rm -rf /var/cache/yum/*

RUN export VERSION=1.20.3 OS=linux ARCH=amd64 && \
    wget -O /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz \
    https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz && \
    tar -C /usr/local -xzf /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc &&\
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
    | sh -s -- -b $(go env GOPATH)/bin &&\
    echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc && source ~/.bashrc && \
    cd /tmp && \
    git clone --recurse-submodules https://github.com/sylabs/singularity.git -b $SINGULARITY_GIT_VERSION && \
    pushd singularity && \
    ./mconfig && \
    make -j$(nproc) -C builddir && \
    make -C builddir install && \
    popd && \
    rm -rf *
