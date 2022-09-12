FS_PATH=/rds/user/sm2558/hpc-work/
CONDA_PATH=$FS_PATH/conda_envs/rllib
REPO_PATH=$FS_PATH/repos
CONDA_CLEAN=true
CONDA_INSTALL_TORCH=true
CONDA_INSTALL_RAY=true
CONDA_INSTALL_HABITAT=false
INSTALL_TASKS=false

# Setup miniconda
if [ "$CONDA_CLEAN" = true ]; then
	rm -r $CONDA_PATH
	mkdir -p $CONDA_PATH
	conda init
	source .bashrc
	conda create -y -p $CONDA_PATH  python=3.7 numpy scipy cmake=3.14.0
fi

conda activate $CONDA_PATH

if [ "$CONDA_INSTALL_TORCH" = true ]; then
	# Install and verify latest torch
	conda install -y pytorch torchvision cudatoolkit=10.2 -c pytorch
	python3 -c "import torch; torch.Tensor(1.0).cuda()"

	# Install and verify torch geometric
	conda install -y pyg -c pyg
	python3 -c "import torch, torch_geometric; torch_geometric.nn.GraphConv(3,3)(torch.ones(3,3).cuda())"
fi

if [ "$CONDA_INSTALL_RAY" = true ]; then
	# Install and verify ray
	conda install dm-tree lz4 hyperopt tensorboardX tensorboard uvicorn starlette
	pip install -U "ray[rllib]==1.11.0" 
	rllib train \
		--run A2C \
		--env CartPole-v0 \
		--framework "torch" \
		--ray-num-gpus 0.1
		
		
fi

if [ "$CONDA_INSTALL_HABITAT" = true ]; then
	# Install habitat-sim
	pip3 install lmdb ifcfg webdataset==0.1.40	
	conda install habitat-sim withbullet headless -c conda-forge -c aihabitat

	# Install and verify habitat-lab
	mkdir -p $REPO_PATH
	git clone --branch stable https://github.com/facebookresearch/habitat-lab.git $REPO_PATH
	pushd $REPO_PATH/habitat-lab
	python setup.py develop --all
	python3 examples/example.py
	popd 

	# Tasks
	curl http://dl.fbaipublicfiles.com/habitat/habitat-test-scenes.zip --output habitat-test-scenes.zip \
		&& unzip habitat-test-scenes.zip -d /root/habitat-lab \
		# mp3d objectnav
		&& curl https://dl.fbaipublicfiles.com/habitat/data/datasets/objectnav/m3d/v1/objectnav_mp3d_v1.zip \
			--output objectnav_mp3d_v1.zip \ 
		&& mkdir -p /root/habitat-lab/data/datasets/objectnav/mp3d/v1/ \
		&& unzip objectnav_mp3d_v1.zip -d /root/habitat-lab/data/datasets/objectnav/mp3d/v1/ \
		&& rm objectnav_mp3d_v1.zip \
		# mp3d pointnav
		&& curl https://dl.fbaipublicfiles.com/habitat/data/datasets/pointnav/mp3d/v1/pointnav_mp3d_v1.zip \
			--output pointnav_mp3d_v1.zip \
		&& mkdir -p /root/habitat-lab/data/datasets/pointnav/mp3d/v1/ \
		&& unzip pointnav_mp3d_v1.zip -d /root/habitat-lab/data/datasets/pointnav/mp3d/v1/ \
		&& rm pointnav_mp3d_v1.zip \

	# Symlink to predownloaded maps on /rds
	ln -s /root/scene_datasets/mp3d /root/habitat-lab/data/scene_datasets \
		&& ln -s /root/scene_datasets/gibson /root/habitat-lab/data/scene_datasets


fi
