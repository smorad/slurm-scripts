FS_PATH=/rds/user/sm2558/hpc-work/
CONDA_PATH=$FS_PATH/conda_envs/rllib
REPO_PATH=$FS_PATH/repos
CONDA_CLEAN=false
CONDA_INSTALL_TORCH=false
CONDA_INSTALL_TORCH_GEOM=false
CONDA_INSTALL_RAY=true
INSTALL_POPGYM=true
INSTALL_TASKS=false
PIP=$CONDA_PATH/bin/pip

ray_patch=cat <<EOF > ray_patch.patch
From b622db6f7951f16ba957f5db4080f778c9c76bea Mon Sep 17 00:00:00 2001
From: Steven Morad <smorad@anyscale.com>
Date: Wed, 24 Aug 2022 12:24:32 +0100
Subject: [PATCH] Log histograms in wandb

Signed-off-by: Steven Morad <smorad@anyscale.com>
---
 python/ray/air/callbacks/wandb.py | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/python/ray/air/callbacks/wandb.py b/python/ray/air/callbacks/wandb.py
index 2e24a936496b..ec3ad2bd3bc1 100644
--- a/python/ray/air/callbacks/wandb.py
+++ b/python/ray/air/callbacks/wandb.py
@@ -35,8 +35,17 @@
 # It takes in a W&B run object and doesn't return anything.
 # Example: "your.module.wandb_process_run_info_hook".
 WANDB_PROCESS_RUN_INFO_HOOK = "WANDB_PROCESS_RUN_INFO_HOOK"
-_VALID_TYPES = (Number, wandb.data_types.Video, wandb.data_types.Image)
-_VALID_ITERABLE_TYPES = (wandb.data_types.Video, wandb.data_types.Image)
+_VALID_TYPES = (
+    Number,
+    wandb.data_types.Video,
+    wandb.data_types.Image,
+    wandb.data_types.Histogram,
+)
+_VALID_ITERABLE_TYPES = (
+    wandb.data_types.Video,
+    wandb.data_types.Image,
+    wandb.data_types.Histogram,
+)
 
 
 def _is_allowed_type(obj):
EOF



# Setup miniconda
if [ "$CONDA_CLEAN" = true ]; then
	rm -r $CONDA_PATH
	mkdir -p $CONDA_PATH
	conda init
	source .bashrc
	conda create -y -p $CONDA_PATH  python=3.9 numpy scipy cmake=3.14.0 pip
fi

conda activate $CONDA_PATH

if [ "$CONDA_INSTALL_TORCH" = true ]; then
	# Install and verify latest torch
	#conda install -y pytorch torchvision cudatoolkit=10.2 -c pytorch
	#conda install pytorch cudatoolkit=11.6 -c pytorch -c conda-forge
	$PIP install torch  --extra-index-url https://download.pytorch.org/whl/cu116
	python3 -c "import torch; torch.tensor(1.0).cuda()" || echo "FAILED TO INSTALL TORCH"
fi

if [ "$CONDA_INSTALL_TORCH_GEOM" = true ]; then
	# Install and verify torch geometric
	conda install -y pyg -c pyg
	python3 -c "import torch, torch_geometric; torch_geometric.nn.GraphConv(3,3)(torch.ones(3,3).cuda())" 
fi

if [ "$CONDA_INSTALL_RAY" = true ]; then
	# Install and verify ray
	$PIP install dm-tree lz4 hyperopt tensorboardX tensorboard uvicorn starlette
	#$PIP install -U "ray[rllib]==2.0.0" --upgrade
	$PIP install -U "ray[rllib]==2.0.0" --upgrade  || exit 1
	patch -p1 $CONDA_PATH/lib/python3.9/site-packages/ray/air/callbacks/wandb.py ray_patch.patch || echo "FAILED TO INSTALL RAY"
fi


if [ "$INSTALL_POPGYM" = true ]; then
	#$PIP install -e "$REPO_PATH/popgym[baselines]"
	$PIP install -e "$REPO_PATH/popgym"
	$PIP install opt_einsum wandb dnc einops gym==0.24.0
fi
