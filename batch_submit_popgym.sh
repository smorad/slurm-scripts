export POPGYM_NUM_TRIALS=$1
export POPGYM_NUM_SPLITS=$2
export POPGYM_EXPERIMENT=$3
export POPGYM_PROJECT=$4

if [ "$#" -ne 4 ]; then
	echo "Usage: batch_submit_popgym NUM_TRIALS NUM_SPLITS POPGYM_ENV_STRING POPGYM_WANDB_PROJECT"
	exit 1
fi

for trial in $(seq 1 $POPGYM_NUM_TRIALS); do
	for split in $(seq 0 $[$POPGYM_NUM_SPLITS - 1]); do
		export POPGYM_SPLIT_ID=$split
		echo "Trial $trial Split $POPGYM_SPLIT_ID"
		sbatch popgym.wilkes3
	done
done
