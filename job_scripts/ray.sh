#!/bin/bash

singularity exec --nv /home/sm2558/rds/ray_img python3 /root/vnav/src/start.py /root/vnav/src/cfg/cartpole.py --hpc
