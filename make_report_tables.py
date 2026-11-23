#!/usr/bin/env python
"""
make_report_tables.py -- turns results/all_results.csv into the tables and figures
for the PowerPoint and the paper. CPU only, takes seconds.

Run collect_results.py FIRST (it writes results/all_results.csv), then:
    python make_report_tables.py                 # uses the default working folder below
    python make_report_tables.py /path/to/working/

Writes to  working/results/report/ :
    table1_main_comparison.csv / .md   CNN vs CNN + LSTM on the SAME folds, per configuration
    table2_lstm_metrics.csv / .md      AUC, precision, recall, F1 of the CNN + LSTM (class 1 = positive)
    table3_per_fold.csv / .md          per-fold test accuracy where the Adam control was run
    fig1_window_trend.png              accuracy vs window length (chunks = 20)
    fig2_chunk_sweep.png               accuracy vs number of chunks (needs several chunk settings)
    fig3_cost.png                      parameter count and training-time ratio
"""
import os, sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

WRK_DIR = sys.argv[1] if len(sys.argv) > 1 else "/storage/home/naf5446/work/__codes__and__data__/working/"
if not WRK_DIR.endswith("/"):
    WRK_DIR += "/"
RES = WRK_DIR + "results/"
OUT = RES + "report/"
os.makedirs(OUT, exist_ok = True)

CNN, LSTM, ADAM = "CNN (baseline)", "CNN + LSTM", "CNN (Adam control)"
CFG = ["expert", "window", "chunks"]
EXPERT_COLORS = {"A": "tab:blue", "B": "tab:orange", "C": "tab:green"}


def md_table(df):
    cols = list(df.columns)
    lines = ["| " + " | ".join(cols) + " |", "|" + "|".join(["---"] * len(cols)) + "|"]
    for _, r in df.iterrows():
        lines.append("| " + " | ".join("-" if (isinstance(v, float) and np.isnan(v)) else str(v) for v in r) + " |")
    return "\n".join(lines)


def save_table(df, name, note):
    df.to_csv(OUT + name + ".csv", index = False)
    with open(OUT + name + ".md", "w") as f:
        f.write(md_table(df) + "\n\n" + note + "\n")
    print("\n=== %s ===" % name)
    print(df.to_string(index = False))
    print(note)


def cnn_params(T):
    """Parameter count of the baseline CNN for a window of T samples
    (matches the Keras summaries: 113,025 at 64 samples, 424,321 at 1280)."""
    p = 3 * 3 * 1 * 128 + 128 + 4 * 128
    p += 3 * 3 * 128 * 64 + 64 + 4 * 64
    p += 3 * 3 * 64 * 32 + 32 + 4 * 32
    flat = (T // 8) * (18 // 8) * 32
    return p + flat * 32 + 32 + 32 * 64 + 64 + 64 + 1


d = pd.read_csv(RES + "all_results.csv")
for col in ["window", "chunks", "fold"]:
    d[col] = d[col].astype(int)

# ---------------------------------------------------------------- Table 1
rows = []
for cfg, g in d.groupby(CFG):
    a, b = g[g.model == CNN], g[g.model == LSTM]
    folds = sorted(set(a.fold) & set(b.fold))
    if not folds:
        continue
    a, b = a[a.fold.isin(folds)], b[b.fold.isin(folds)]
    sd = lambda x: round(100 * x.std(ddof = 1), 2) if len(x) > 1 else np.nan
    rows.append({
        "expert": cfg[0], "window_s": cfg[1], "chunks": cfg[2], "folds": len(folds),
        "CNN_acc_%": round(100 * a.test_acc.mean(), 2), "CNN_sd": sd(a.test_acc),
        "LSTM_acc_%": round(100 * b.test_acc.mean(), 2), "LSTM_sd": sd(b.test_acc),
        "diff_pp": round(100 * (b.test_acc.mean() - a.test_acc.mean()), 2),
        "CNN_min_per_fold": round(a.minutes.mean(), 1), "LSTM_min_per_fold": round(b.minutes.mean(), 1),
        "time_ratio": round(b.minutes.mean() / a.minutes.mean(), 2) if a.minutes.mean() > 0 else np.nan,
    })
t1 = pd.DataFrame(rows).sort_values(["expert", "window_s", "chunks"]) if rows else pd.DataFrame()
if not t1.empty:
    save_table(t1, "table1_main_comparison",
               "Test accuracy (mean over the folds that BOTH models ran; sd only when more than 1 fold). "
               "diff_pp = CNN + LSTM minus CNN, in percentage points. Folds = 1 means fold 0 only.")

# ---------------------------------------------------------------- Table 2
l = d[d.model == LSTM]
if not l.empty and "auc" in l.columns:
    t2 = (l.groupby(CFG).agg(folds = ("fold", "nunique"), params = ("params", "first"),
                              auc = ("auc", "mean"), precision = ("precision", "mean"),
                              recall = ("recall", "mean"), f1 = ("f1", "mean")).round(4).reset_index())
    t2 = t2.rename(columns = {"window": "window_s"})
    save_table(t2, "table2_lstm_metrics",
               "CNN + LSTM, mean over the folds that were run; class 1 is the positive class, threshold 0.5.")

# ---------------------------------------------------------------- Table 3
ad = d[d.model == ADAM]
if not ad.empty:
    out = []
    for cfg, g in d[d.set_index(CFG).index.isin(set(map(tuple, ad[CFG].drop_duplicates().values)))].groupby(CFG):
        p = g.pivot_table(index = "fold", columns = "model", values = "test_acc", aggfunc = "last") * 100
        p = p.round(2).reset_index()
        for k, v in reversed(list(zip(CFG, cfg))):
            p.insert(0, k, v)
        out.append(p)
    t3 = pd.concat(out, ignore_index = True)
    t3 = t3.rename(columns = {"window": "window_s"})
    save_table(t3, "table3_per_fold",
               "Per-fold test accuracy (%). Values near 50 mean that fold never learned (training stayed at chance).")

# ---------------------------------------------------------------- Figure 1
c20 = d[d.chunks == 20]
if not c20.empty:
    fig, ax = plt.subplots(figsize = (7.5, 5))
    for e in sorted(c20.expert.unique()):
        cnn = c20[(c20.expert == e) & (c20.model == CNN)].groupby("window").test_acc.mean() * 100
        if len(cnn):
            ax.plot(cnn.index, cnn.values, "-o", color = EXPERT_COLORS.get(e), label = "CNN, expert %s" % e)
        lst = c20[(c20.expert == e) & (c20.model == LSTM)].groupby("window").test_acc.mean() * 100
        if len(lst):
            ax.plot(lst.index, lst.values, "X", color = EXPERT_COLORS.get(e), markersize = 11,
                    markeredgecolor = "black", linestyle = "none", label = "CNN + LSTM, expert %s" % e)
    ax.set_xscale("log")
    ax.set_xticks([1, 2, 5, 10, 20])
    ax.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax.set_xlabel("Window length (s)")
    ax.set_ylabel("Test accuracy (%)")
    ax.set_title("Accuracy vs window length (20 chunks)")
    ax.grid(alpha = 0.4)
    ax.legend(fontsize = 8, ncol = 2)
    fig.tight_layout()
    fig.savefig(OUT + "fig1_window_trend.png", dpi = 200)
    plt.close(fig)
    print("\nsaved fig1_window_trend.png  (CNN: mean over its folds; LSTM X markers: mean over the folds that were run)")

# ---------------------------------------------------------------- Figure 2
cands = []
for (e, w), g in d.groupby(["expert", "window"]):
    ok = sorted(c for c, gg in g.groupby("chunks")
                if set(gg[gg.model == CNN].fold) & set(gg[gg.model == LSTM].fold)
                and len(set(gg[gg.model == LSTM].fold)) >= 2)
    if len(ok) >= 3:
        cands.append((e, w, ok))
if cands:
    fig, axes = plt.subplots(1, len(cands), figsize = (6 * len(cands), 4.5), squeeze = False)
    for ax, (e, w, ok) in zip(axes[0], cands):
        g = d[(d.expert == e) & (d.window == w) & (d.chunks.isin(ok))]
        for m, style in [(CNN, "-o"), (LSTM, "-s")]:
            s = g[g.model == m].groupby("chunks").test_acc.agg(["mean", "std"]) * 100
            ax.errorbar(s.index, s["mean"], yerr = s["std"], fmt = style, capsize = 3, label = m)
        ax.set_xscale("log")
        ax.set_xticks(ok)
        ax.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
        ax.set_xlabel("Chunks")
        ax.set_ylabel("Test accuracy (%)")
        ax.set_title("Expert %s, %d s window (mean +/- sd over folds)" % (e, w))
        ax.grid(alpha = 0.4)
        ax.legend()
    fig.tight_layout()
    fig.savefig(OUT + "fig2_chunk_sweep.png", dpi = 200)
    plt.close(fig)
    print("saved fig2_chunk_sweep.png")

# ---------------------------------------------------------------- Figure 3
if not t1.empty:
    fig, (a1, a2) = plt.subplots(1, 2, figsize = (12, 4.5))
    wins = [1, 2, 5, 10, 20]
    a1.plot(wins, [cnn_params(64 * w) for w in wins], "-o", label = "Baseline CNN")
    lp = l.params.iloc[0] if (not l.empty and "params" in l.columns) else 74465
    a1.plot(wins, [lp] * len(wins), "-s", label = "CNN + LSTM")
    a1.set_xscale("log"); a1.set_xticks(wins)
    a1.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    a1.set_xlabel("Window length (s)"); a1.set_ylabel("Parameters")
    a1.set_title("Model size"); a1.grid(alpha = 0.4); a1.legend()
    labels = ["%s %ds c%d" % (r.expert, r.window_s, r.chunks) for r in t1.itertuples()]
    a2.bar(range(len(t1)), t1.time_ratio.values)
    a2.axhline(1, color = "black", lw = 0.8)
    a2.set_xticks(range(len(t1))); a2.set_xticklabels(labels, rotation = 60, ha = "right", fontsize = 8)
    a2.set_ylabel("Training time per fold, LSTM / CNN")
    a2.set_title("Training cost")
    a2.grid(axis = "y", alpha = 0.4)
    fig.tight_layout()
    fig.savefig(OUT + "fig3_cost.png", dpi = 200)
    plt.close(fig)
    print("saved fig3_cost.png")

print("\nEverything is in:", OUT)
