#!/bin/bash
#SBATCH --job-name=eeg_lstm
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --time=01:00:00
#SBATCH --gres=gpu:a100:1
#SBATCH --array=0-4%3
#SBATCH --output=eeg_lstm_%A_%a.log

# Each array task runs ONE line of lstm_configs.txt:  <expert> <window> <chunks>
#   array index 0 = first line, 1 = second line, ...   (so --array=0-4 for a 5-line file)
# Defaults: fold 0 only, 300 epochs (about 20-25 min per configuration). Change at submit time, e.g.
#   sbatch --array=0 --time=00:15:00 --export=ALL,LSTM_EPOCHS=10 run_lstm.sh   (timing test, first line only)
#   sbatch --time=03:00:00 --export=ALL,LSTM_KFOLD=1 run_lstm.sh                (all 5 folds, about 2 h each)

module purge
module load anaconda3

cd /storage/work/naf5446/__codes__and__data__/Python
PY=/storage/work/naf5446/.conda/envs/eeg/bin/python

CONFIGS=${CONFIGS:-lstm_configs.txt}
LINE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$CONFIGS" | tr -d '\r')
read -r E W C <<< "$LINE"
if [ -z "$E" ] || [ -z "$W" ] || [ -z "$C" ]; then
  echo "No valid line $((SLURM_ARRAY_TASK_ID + 1)) in $CONFIGS: '$LINE'"; exit 1
fi

# Settings read by the LSTM cells of the notebook through environment variables
export LSTM_EXPERT=$E
export LSTM_WINDOW=$W
export LSTM_CHUNKS_LIST=$C                        # one value, or comma separated like 5,20
export LSTM_KFOLD=${LSTM_KFOLD:-0}                # 0 = fold 0 only, 1 = all 5 folds
export LSTM_EPOCHS=${LSTM_EPOCHS:-300}
export LSTM_PATIENCE=${LSTM_PATIENCE:-10000}
export RUN_CNN_LSTM=${RUN_CNN_LSTM:-1}
export RUN_PURE_LSTM=${RUN_PURE_LSTM:-0}
export RUN_CNN_ADAM_CONTROL=${RUN_CNN_ADAM_CONTROL:-0}

SRC=EEG_calib_done_LSTM.ipynb
NB=EEG_LSTM_${E}_${W}_c${C//,/-}.ipynb

nvidia-smi
echo "config line $((SLURM_ARRAY_TASK_ID + 1)): expert $E window $W chunks $C | kfold $LSTM_KFOLD epochs $LSTM_EPOCHS"

# Temporary copy of the SAME notebook without the cells tagged "skip_in_lstm_job"
# (HDF5 check, CNN __Run__ cell, everything after the LSTM section).
$PY - "$SRC" "$NB" <<'PYEOF'
import json, sys
nb = json.load(open(sys.argv[1]))
nb["cells"] = [c for c in nb["cells"] if "skip_in_lstm_job" not in c.get("metadata", {}).get("tags", [])]
json.dump(nb, open(sys.argv[2], "w"), indent=1)
print("cells kept:", len(nb["cells"]))
PYEOF

$PY -m jupyter nbconvert --to notebook --execute $NB --output ${NB%.ipynb}_done.ipynb --ExecutePreprocessor.timeout=-1 --ExecutePreprocessor.kernel_name=eeg
