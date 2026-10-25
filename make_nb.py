import json, sys
src, dst, expert, window = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
nb = json.load(open(src))
rep = [
    ("COMPLETE_CALCULATIONS = False", "COMPLETE_CALCULATIONS = True"),
    ('which_expert = np.array (["A", "B", "C"])', 'which_expert = np.array (["%s"])' % expert),
    ("windows = [1, 2, 5, 10, 20]", "windows = [%s]" % window),
]
counts = [0, 0, 0]
for c in nb["cells"]:
    if c["cell_type"] != "code":
        continue
    s = "".join(c["source"])
    for k, (a, b) in enumerate(rep):
        counts[k] += s.count(a)
        s = s.replace(a, b)
    c["source"] = s.splitlines(keepends=True)
    c["outputs"] = []
json.dump(nb, open(dst, "w"))
print("replaced:", counts)
