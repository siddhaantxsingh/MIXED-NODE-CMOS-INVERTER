#!/usr/bin/env python3
"""
Extract MOSFET metrics from Sentaurus SDevice Id-Vg output (.plt, DF-ISE text).
Same definitions as devsim/characterize.py, so numbers are directly comparable
with results/nmos_params.json and results/pmos_params.json.

Usage (in the folder where you ran sdevice):
    python3 device_params.py IdVg_lin_idvg_nmos_180_des.plt IdVg_sat_idvg_nmos_180_des.plt
    python3 device_params.py IdVg_lin_idvg_pmos_180_des.plt IdVg_sat_idvg_pmos_180_des.plt

Pure Python 3, no numpy needed. Uses |Vg| and |Id| so it works for nMOS and pMOS.
SDevice 2D currents are per um of width, so Id is already in A/um.
"""
import math
import re
import sys

VDD = 1.8
VD_LIN = 0.05
ICC = 1e-7  # constant-current Vt criterion, 100 nA/um


def read_plt(path):
    text = open(path, encoding="latin-1").read()
    m = re.search(r"datasets\s*=\s*\[(.*?)\]", text, re.S)
    if not m:
        sys.exit(f"{path}: no 'datasets' header (is this a .plt file?)")
    names = re.findall(r'"([^"]*)"', m.group(1))
    d = re.search(r"Data\s*\{(.*)\}", text, re.S)
    nums = [float(x) for x in d.group(1).split()]
    n = len(names)
    rows = [nums[i:i + n] for i in range(0, len(nums) - n + 1, n)]
    return names, {nm: [r[i] for r in rows] for i, nm in enumerate(names)}


def pick(names, data, *pats):
    for nm in names:
        if all(re.search(p, nm, re.I) for p in pats):
            return data[nm]
    sys.exit(f"no dataset matching {pats}. Available:\n  " + "\n  ".join(names))


def gate_sweep(path):
    names, data = read_plt(path)
    vg = [abs(v) for v in pick(names, data, r"^gate", r"OuterVoltage")]
    idr = [abs(i) for i in pick(names, data, r"^drain", r"TotalCurrent")]
    # keep only the part where Vg actually increases (drops any ramp points)
    pts, last = [], -1.0
    for v, i in zip(vg, idr):
        if v > last + 1e-9:
            pts.append((v, i))
            last = v
    return [p[0] for p in pts], [p[1] for p in pts]


def grad(y, x):
    g = []
    for k in range(len(x)):
        a, b = max(k - 1, 0), min(k + 1, len(x) - 1)
        g.append((y[b] - y[a]) / (x[b] - x[a]) if x[b] != x[a] else 0.0)
    return g


def interp(x0, xs, ys):
    for k in range(1, len(xs)):
        a, b = xs[k - 1], xs[k]
        if (a - x0) * (b - x0) <= 0 and a != b:
            return ys[k - 1] + (x0 - a) / (b - a) * (ys[k] - ys[k - 1])
    return float("nan")


def main(lin_path, sat_path):
    vg_l, id_l = gate_sweep(lin_path)
    vg_s, id_s = gate_sweep(sat_path)

    gm = grad(id_l, vg_l)
    k = max(range(len(gm)), key=lambda j: gm[j])
    vt_gm = vg_l[k] - id_l[k] / gm[k] - VD_LIN / 2

    lg = lambda arr: [math.log10(max(i, 1e-30)) for i in arr]
    vt_lin = interp(math.log10(ICC), lg(id_l), vg_l)
    vt_sat = interp(math.log10(ICC), lg(id_s), vg_s)

    ss = grad(vg_l, lg(id_l))
    ss_sub = [s for s, i in zip(ss, id_l) if 1e-12 < i < ICC and s > 0]
    ss_mv = min(ss_sub) * 1000 if ss_sub else float("nan")

    res = dict(
        Vt_maxgm_V=vt_gm,
        Vt_cc_lin_V=vt_lin,
        Vt_cc_sat_V=vt_sat,
        DIBL_mV_per_V=(vt_lin - vt_sat) / (VDD - VD_LIN) * 1000,
        SS_mV_per_dec=ss_mv,
        Ion_uA_per_um=id_s[-1] * 1e6,
        Ioff_pA_per_um=id_s[0] * 1e12,
        Ion_Ioff=id_s[-1] / max(id_s[0], 1e-30),
    )
    for name, v in res.items():
        print(f"  {name:16s} {v:12.4g}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
