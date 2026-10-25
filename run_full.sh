#!/bin/bash
#SBATCH --job-name=eeg_full
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --time=12:00:00
#SBATCH --gres=gpu:a100:1
#SBATCH --array=0-14%3
#SBATCH --output=eeg_full_%A_%a.log

module purge
module load anaconda3

cd /storage/work/naf5446/__codes__and__data__/Python
PY=/storage/work/naf5446/.conda/envs/eeg/bin/python

EXPERTS=(A B C)
WINDOWS=(1 2 5 10 20)
E=${EXPERTS[$((SLURM_ARRAY_TASK_ID / 5))]}
W=${WINDOWS[$((SLURM_ARRAY_TASK_ID % 5))]}
NB=EEG_full_${E}_${W}.ipynb

nvidia-smi
echo "expert $E window $W"
$PY make_nb.py EEG_neonatal_fixed_versions_v2_test.ipynb $NB $E $W

$PY -m jupyter nbconvert --to notebook --execute $NB --output EEG_full_${E}_${W}_done.ipynb --ExecutePreprocessor.timeout=-1 --ExecutePreprocessor.kernel_name=eeg
