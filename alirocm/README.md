alipier/alirocm
===============

`alipier/alidock`-based container to support ROCm develompment and cross-compilation.
See main project at [alidock](htpps://github.com/alidock/alidock).

_To execute ROCm enabled apps you will require an host system with the full ROCm driver stack
installed._

Run it with Docker with:

    docker pull alipier/alirocm
    docker run -it --device=/dev/kfd --device=/dev/dri --group-add video mconcas/alirocm
