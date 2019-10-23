FROM alisw/slc6-builder
LABEL maintainer="Dario Berzano <dario.berzano@gmail.com>"
RUN rpmdb --rebuilddb && yum clean all && rm -rf /var/cache/yum && \
    yum -y install openssh-server xorg-x11-apps tmux htop bash-completion tig pigz nano && \
    yum clean all && rm -rf /var/cache/yum
RUN cd /tmp && \
    curl -LO https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.tgz && \
    tar xzf cloudflared*.tgz && \
    mv -v cloudflared /usr/sbin && \
    which cloudflared && \
    rm -f /tmp/cloudflared*.tgz
RUN cd /tmp && \
    curl -LO https://github.com/github/hub/releases/download/v2.6.0/hub-linux-amd64-2.6.0.tgz && \
    tar xzf hub-linux*.tgz && \
    rm -f hub-linux*.tgz && \
    cd hub-linux* && \
    ./install && \
    cd .. && \
    rm -rf hub-linux*
RUN pip install alibuild==v1.5.5
