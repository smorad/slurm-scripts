FS_PATH=/rds/user/sm2558/hpc-work/
CONDA_PATH=$FS_PATH/conda_envs/rllib
REPO_PATH=$FS_PATH/repos
CONDA_CLEAN=true
CONDA_INSTALL_TORCH=true
CONDA_INSTALL_TORCH_GEOM=false
CONDA_INSTALL_RAY=true
INSTALL_POPGYM=true
INSTALL_TASKS=false
PIP=$CONDA_PATH/bin/pip

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
	python3 -c "import torch; torch.Tensor(1.0).cuda()"
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
	$PIP install -U "ray[rllib] @ https://s3-us-west-2.amazonaws.com/ray-wheels/latest/ray-3.0.0.dev0-cp39-cp39-manylinux2014_x86_64.whl" --upgrade
fi


if [ "$INSTALL_POPGYM" = true ]; then
	#$PIP install -e "$REPO_PATH/popgym[baselines]"
	$PIP install -e "$REPO_PATH/popgym"
	$PIP install opt_einsum wandb dnc einops gym==0.24.0
fi
