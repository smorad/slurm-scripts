#!/bin/bash
set -e

nvidia-smi
nvcc --version
which nvcc
singularity exec --nv /home/sm2558/rds/hpc-work/images/ray_habitat nvcc --version
singularity exec --nv /home/sm2558/rds/hpc-work/images/ray_habitat which nvcc
singularity exec --nv /home/sm2558/rds/hpc-work/images/ray_habitat nvidia-smi
singularity exec --nv /home/sm2558/rds/hpc-work/images/ray_habitat python3 /root/vnav/src/start.py /root/vnav/src/cfg/cartpole.py --hpc
