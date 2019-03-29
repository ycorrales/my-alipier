alipier/alidock:slc6
====================

This one is based on `alisw/slc6-builder`, the default image used by ALICE to build Run 2 software
for the Grid. This flavour can be run through [alidock](https://github.com/alidock/alidock/) for
debugging purposes.

All `aliBuild` commands ran inside this image do not download packages from upstream by default. You
should manually specify `--remote-store` when building in order to benefit from cached builds:

    aliBuild build AliPhysics --remote-store https://alicache.cern.ch/
