#!/usr/bin/env python
"""
collect_results.py -- put the results of EVERYTHING in one place. CPU only, takes seconds.

Reads
  * the CNN results already written by your sweep:  working/results/results_expert_*.txt
  * the CNN + LSTM runs:                              working/results/summary_seq_models.csv
Writes
  * working/results/all_results.csv   (one row per model / expert / window / chunks / fold)
  * working/results/all_results.png   (test accuracy, CNN vs the other models)
and prints: test accuracy per configuration, the difference to the CNN on the SAME folds,
and the training time per fold (so you can see how much longer the LSTM takes).

Usage (terminal, no GPU needed):   python collect_results.py
         or in a notebook cell:      %run collect_results.py
Optional: python collect_results.py /path/to/working/
"""
import os, re, sys, glob
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

WRK_DIR = sys.argv[1] if len(sys.argv) > 1 else "/storage/home/naf5446/work/__codes__and__data__/working/"
if not WRK_DIR.endswith("/"):
    WRK_DIR += "/"
RES = WRK_DIR + "results/"
CFG = ["expert", "window", "chunks"]
CNN_LABEL = "CNN (baseline)"
LABELS = {"CNN_LSTM": "CNN + LSTM", "LSTM": "LSTM only", "CNN_ADAM": "CNN (Adam control)"}


def parse_cnn_file(path):
    """One results_expert_X_Ysec_Zchunk_64Hz.txt -> rows of the LAST run in the file."""
    m = re.match(r"results_expert_([ABC])_(\d+)sec_(\d+)chunk_(\d+)Hz\.txt$", os.path.basename(path))
    if not m:
        return []
    expert, window, chunks = m.group(1), int(m.group(2)), int(m.group(3))
    text = open(path, errors = "ignore").read()
    # The file is appended to on every run; each run starts with a '# expert_...hdf5' header block.
    block = re.split(r"#{10,}\n# expert_[^\n]*\n#{10,}", text)[-1]
    parts = re.split(r"\nFold:\s+(\d+)\s*\n", block)       # [pre, fold, body, fold, body, ...]
    rows = []
    for k in range(1, len(parts) - 1, 2):
        fold, body = int(parts[k]), parts[k + 1]
        va = re.search(r"--Best model validation accuracy:\s*([0-9.]+)%", body)
        te = re.search(r"--Best model test accuracy:\s*([0-9.]+)%", body)
        tm = re.search(r"Time:\s*(\d+)\s*m\s*(\d+)\s*s", body)
        if not te:
            continue
        rows.append({
            "model": CNN_LABEL, "expert": expert, "window": window, "chunks": chunks, "fold": fold,
            "val_acc": float(va.group(1)) / 100 if va else np.nan,
            "test_acc": float(te.group(1)) / 100,
            "minutes": int(tm.group(1)) + int(tm.group(2)) / 60 if tm else np.nan,
        })
    return rows


def load_all():
    cnn_rows = []
    for p in sorted(glob.glob(RES + "results_expert_*.txt")):
        cnn_rows += parse_cnn_file(p)
    cnn = pd.DataFrame(cnn_rows)

    seq_path = RES + "summary_seq_models.csv"
    seq = pd.DataFrame()
    if os.path.exists(seq_path):
        seq = pd.read_csv(seq_path)
        seq["model"] = seq["model"].map(lambda t: LABELS.get(t, t))
        # a re-run replaces the earlier row (e.g. the 3-epoch timing test)
        seq = seq.drop_duplicates(subset = ["model"] + CFG + ["fold"], keep = "last")
    return pd.concat([cnn, seq], ignore_index = True, sort = False)


def pct(v):
    return "" if pd.isna(v) else "%.2f%%" % (100 * v)


def main():
    df = load_all()
    if df.empty:
        print("No results found in", RES)
        return
    df.sort_values(CFG + ["model", "fold"]).to_csv(RES + "all_results.csv", index = False)
    models = [m for m in [CNN_LABEL, "CNN + LSTM", "CNN (Adam control)", "LSTM only"] if m in set(df["model"])]
    print("Saved:", RES + "all_results.csv")
    print("Models found:", ", ".join(models), "| rows:", len(df))

    # 1) test accuracy per configuration (mean over the folds each model has)
    acc = df.pivot_table(index = CFG, columns = "model", values = "test_acc", aggfunc = "mean")[models]
    nf = df.pivot_table(index = CFG, columns = "model", values = "fold", aggfunc = "nunique")[models]
    show = acc.copy()
    for m in models:
        show[m] = [pct(a) + (" (%d fold%s)" % (n, "" if n == 1 else "s") if not pd.isna(a) else "")
                   for a, n in zip(acc[m], nf[m].fillna(0))]
    print("\n=== Test accuracy (mean over the folds that were run) ===")
    print(show.to_string())

    # 2) difference to the CNN on exactly the same folds
    others = [m for m in models if m != CNN_LABEL]
    if CNN_LABEL in models and others:
        rows = []
        for cfg, g in df.groupby(CFG):
            cnn = g[g["model"] == CNN_LABEL]
            for m in others:
                o = g[g["model"] == m]
                folds = sorted(set(o["fold"]) & set(cnn["fold"]))
                if not folds:
                    continue
                a = o[o["fold"].isin(folds)]["test_acc"].mean()
                b = cnn[cnn["fold"].isin(folds)]["test_acc"].mean()
                rows.append(dict(zip(CFG, cfg), model = m, folds = len(folds),
                                 cnn = pct(b), other = pct(a), diff_pct_points = round(100 * (a - b), 2)))
        if rows:
            print("\n=== Difference to the CNN on the SAME folds (percentage points) ===")
            print(pd.DataFrame(rows).to_string(index = False))

    # 3) time per fold, and how many epochs the LSTM models ran
    if df["minutes"].notna().any():
        tm = df.pivot_table(index = CFG, columns = "model", values = "minutes", aggfunc = "mean")[models].round(1)
        if CNN_LABEL in models:
            for m in others:
                tm["x CNN: " + m] = (tm[m] / tm[CNN_LABEL]).round(2)
        print("\n=== Training time per fold (minutes) and ratio to the CNN ===")
        print(tm.to_string())
        if "epochs_run" in df.columns and df["epochs_run"].notna().any():
            print("\nNote: the ratio is only meaningful if both models ran the same number of epochs"
                  " (the CNN sweep used 300; chunks = 10000 stops earlier).")

    # 4) extra metrics that only the new models record (class 1 = positive)
    extra = [c for c in ["auc", "precision", "recall", "f1"] if c in df.columns]
    seq = df[df["model"].isin(others)]
    if extra and not seq.empty and seq[extra].notna().any().any():
        print("\n=== Extra metrics of the new models (class 1 as positive) ===")
        print(seq.groupby(["model"] + CFG)[extra].mean().round(4).to_string())

    # 5) chart
    cfgs = list(acc.index)
    if cfgs:
        fig, ax = plt.subplots(figsize = (max(8, 1.3 * len(cfgs) + 3), 5))
        w = 0.8 / len(models)
        for k, m in enumerate(models):
            ax.bar(np.arange(len(cfgs)) + k * w, 100 * acc[m].values, w, label = m)
        ax.set_xticks(np.arange(len(cfgs)) + 0.4 - w / 2)
        ax.set_xticklabels(["%s, %ds, %d chunks" % c for c in cfgs], rotation = 30, ha = "right")
        ax.set_ylabel("Test accuracy (%)")
        lo = np.nanmin(100 * acc.values)
        ax.set_ylim(max(0, lo - 5), 100)
        ax.grid(axis = "y", alpha = 0.4)
        ax.legend()
        ax.set_title("Test accuracy per configuration")
        plt.tight_layout()
        plt.savefig(RES + "all_results.png", dpi = 130)
        print("\nChart saved:", RES + "all_results.png")


main()
