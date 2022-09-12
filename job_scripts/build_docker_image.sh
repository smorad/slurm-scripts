#!/bin/bash
# Builds a docker image and places it in shared disk for nodes to access
set -x

TOKEN=hpc:2xKpgmxUBAyAkiiJssdw
IMAGE_PATH=/rds/user/sm2558/hpc-work/vnav_img
REPO_DIR=/tmp/vnav

#rm -rf $REPO_DIR
git clone https://${TOKEN}@gitlab.developers.cam.ac.uk/cst/prorok-lab/vnav $REPO_DIR

docker build -t local/habitat $REPO_DIR/docker
singularity build --sandbox $IMAGE_PATH docker-daemon://local/habitat
singularity exec $IMAGE_PATH -nv python3 /root/vnav/src/start.py /root/vnat/src/cfg/memory.py
