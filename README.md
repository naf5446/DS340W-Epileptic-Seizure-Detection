> ## An Improved Deep Learning Framework for Epileptic Seizure Detection based on Neonatal EEG Signals ##

by *Nicholas Finn*

e-mail: naf5446@psu.edu

1. Start by downloading the data and files from the authors GitHub: https://github.com/artur-gramacki/Epileptic-Seizure-Detection

2. Upload the 79 edf and 3 csv files to the edf and annotations directories respectively.

3. Download any needed packages and run the R code. (Can alternatively download them ~17GB via working/inputs/__read_me__.txt)

4. Download EEG_neonatal.ipynb, EEG_calib_done_LSTM.ipynb, collect_results.py, lstm_configs.txt, lstm_a1s.txt, make_report_tables.py, run_full.sh, and run_lstm.sh from this GitHub.

5. Correct any directories in the files you just downloaded to make sure they are set to your own.

6. Upload the files to your working directory.

7. Open shell access and create the eeg environment needed for the ipnyb's.
   
            conda create -n eeg python=3.11 -y
            conda activate eeg
            pip install "numpy==1.26.4" "scipy==1.13.1" "pandas==2.2.2" "scikit-learn==1.5.2" "matplotlib==3.8.4" \
                        "h5py==3.14.0" "tensorflow==2.20.0" "keras==3.10.0" "tensorboard==2.20.0" "silence-tensorflow==1.2.3" \
                        jupyter nbconvert ipykernel
            python -m ipykernel install --user --name eeg

9. Go to your working directory and run the baseline CNN model using run_full.sh. (Not needed since the results from the authors are already in the zip as .txt files.)
    
            sbatch run_full.sh

11. Run the CNN+LSTM model runs.

            sbatch --array=0 --time=06:00:00 --export=ALL,CONFIGS=lstm_a1s.txt,LSTM_KFOLD=1 run_lstm.sh
            sbatch --array=0-3 run_lstm.sh
            sbatch --array=4-6 --time=02:30:00 --export=ALL,LSTM_KFOLD=1 run_lstm.sh
            sbatch --array=4 --time=01:30:00 --export=ALL,RUN_CNN_LSTM=0,RUN_CNN_ADAM_CONTROL=1,LSTM_KFOLD=1 run_lstm.sh

12. Collect results.
    
            cd Python
            /storage/work/naf5446/.conda/envs/eeg/bin/python collect_results.py | tee collector_output.txt
            python make_report_tables.py
    
