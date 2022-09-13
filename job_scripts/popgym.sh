set -x
FS_PATH=/rds/user/sm2558/hpc-work/
CONDA_PATH=$FS_PATH/conda_envs/rllib
REPO_PATH=$FS_PATH/repos


#export POPGYM_EXPERIMENT="ALL_NOISY_ENVS"
#export POPGYM_NUM_SPLITS=2
#export POPGYM_SPLIT_ID=0
#export POPGYM_PROJECT="popgym-noisy-all"
#export POPGYM_GPU=0.1

# For conda
conda init bash
source ~/.bashrc
conda deactivate
conda activate $CONDA_PATH
echo "Environment is $(env)"
python "$REPO_PATH/popgym/popgym/baselines/ppo.py" 
