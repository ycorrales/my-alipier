FROM alipier/alidock:latest

LABEL maintainer="Matteo Concas <mconcas@cern.ch>"

COPY rocm.repo /etc/yum.repos.d/rocm.repo

RUN yum install -y rocm-dev && \
    rm -rf /var/cache/yum/*

ENV PATH "${PATH}:/opt/rocm/bin"
ENV PATH "${PATH}:/opt/rocm/opencl/bin"
