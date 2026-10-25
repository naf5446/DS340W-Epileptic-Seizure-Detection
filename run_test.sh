#!/bin/bash
#SBATCH --job-name=eeg_test
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:30:00
#SBATCH --gres=gpu:a100:1
#SBATCH --output=eeg_test_%j.log

module purge
module load anaconda3

cd /storage/work/naf5446/__codes__and__data__/Python

PY=/storage/work/naf5446/.conda/envs/eeg/bin/python

nvidia-smi
$PY -c "import tensorflow as tf; print(tf.__version__, tf.config.list_physical_devices('GPU'))"

$PY -m jupyter nbconvert --to notebook --execute EEG_neonatal_fixed_versions_v2_test.ipynb --output EEG_test_done.ipynb --ExecutePreprocessor.timeout=-1 --ExecutePreprocessor.kernel_name=eeg
