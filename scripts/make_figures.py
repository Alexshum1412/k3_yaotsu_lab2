#!/usr/bin/env python3
"""Построение временных диаграмм (из VCD-файлов GHDL) и рисунков для отчёта.

Запуск (после scripts/run_sim.sh):  python3 scripts/make_figures.py
Рисунки сохраняются в report/img/.
"""
import os
import re
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(ROOT, "build")
IMG = os.path.join(ROOT, "report", "img")
os.makedirs(IMG, exist_ok=True)

FS_PER_NS = 1_000_000

C_BG = "#ffffff"
C_GRID = "#e3e6ea"
C_WAVE = "#1b7f3a"
C_BUS = "#1f5fa8"
C_X = "#c0392b"
C_TXT = "#222222"


# ------------------------------------------------------------------ VCD parser
def parse_vcd(path):
    """Возвращает {полное_имя: [(t_ns, value_str), ...]}"""
    ids, scope, data = {}, [], {}
    t = 0
    with open(path) as f:
        in_defs = True
        for line in f:
            tok = line.split()
            if not tok:
                continue
            if in_defs:
                if tok[0] == "$scope":
                    scope.append(tok[2])
                elif tok[0] == "$upscope":
                    scope.pop()
                elif tok[0] == "$var":
                    code, name = tok[3], tok[4]
                    name = re.sub(r"\[.*\]", "", name)
                    full = ".".join(scope[1:] + [name]) if len(scope) > 1 else name
                    ids.setdefault(code, []).append(full)
                    data[full] = []
                elif tok[0] == "$enddefinitions":
                    in_defs = False
                continue
            c = tok[0]
            if c[0] == "#":
                t = int(c[1:]) / FS_PER_NS
            elif c[0] == "b":
                for n in ids.get(tok[1], []):
                    data[n].append((t, c[1:]))
            elif c[0] in "01uxzUXZ-hlwHLW" and len(c) > 1:
                for n in ids.get(c[1:], []):
                    data[n].append((t, c[0]))
    return data


def value_at(ch, t):
    v = None
    for tt, vv in ch:
        if tt <= t:
            v = vv
        else:
            break
    return v


# --------------------------------------------------------------- waveform plot
def fmt_bus(v, width, radix):
    if v is None:
        return ""
    v = v.rjust(width, "0") if set(v) <= {"0", "1"} else v
    if not set(v) <= {"0", "1"}:
        return "U" if "u" in v.lower() else "X"
    n = int(v, 2)
    if radix == "dec":
        return str(n)
    if radix == "hex":
        return format(n, "0%dX" % ((width + 3) // 4))
    return v


def plot_waves(data, signals, t0, t1, fname, title=None, width_in=11.0,
               marks=(), step_label=None):
    """signals: [(label, key, kind, width, radix)] kind: 'bit' | 'bus'"""
    n = len(signals)
    h = 0.42 * n + 0.9
    fig, ax = plt.subplots(figsize=(width_in, h), dpi=200)
    fig.patch.set_facecolor(C_BG)
    ax.set_facecolor(C_BG)
    row_h = 1.0
    for i, (label, key, kind, width, radix) in enumerate(signals):
        y0 = (n - 1 - i) * row_h
        ch = data[key]
        pts = [(t0, value_at(ch, t0))] + [(t, v) for t, v in ch if t0 < t < t1]
        pts.append((t1, None))
        ax.text(t0 - (t1 - t0) * 0.012, y0 + 0.35, label, ha="right", va="center",
                fontsize=8, color=C_TXT, family="DejaVu Sans")
        if kind == "bit":
            xs, ys = [], []
            for (ta, va), (tb, _) in zip(pts[:-1], pts[1:]):
                if va in ("0", "1"):
                    lvl = y0 + (0.62 if va == "1" else 0.05)
                    xs += [ta, tb]; ys += [lvl, lvl]
                else:
                    ax.fill_between([ta, tb], y0, y0 + 0.7, color=C_X, alpha=0.25, lw=0)
                    xs += [ta, tb]; ys += [y0 + 0.35, y0 + 0.35]
            ax.plot(xs, ys, color=C_WAVE, lw=1.1, solid_joinstyle="miter")
        else:
            for (ta, va), (tb, _) in zip(pts[:-1], pts[1:]):
                d = min((t1 - t0) * 0.004, (tb - ta) / 3)
                ok = va is not None and set(va) <= {"0", "1"}
                col = C_BUS if ok else C_X
                ax.plot([ta, ta + d, tb - d, tb], [y0 + 0.35, y0 + 0.7, y0 + 0.7, y0 + 0.35],
                        color=col, lw=0.9)
                ax.plot([ta, ta + d, tb - d, tb], [y0 + 0.35, y0, y0, y0 + 0.35],
                        color=col, lw=0.9)
                txt = fmt_bus(va, width, radix)
                span = tb - ta
                need = (len(txt) * 0.047 + 0.03) / (width_in * 0.86) * (t1 - t0)
                if txt and span > need:
                    ax.text((ta + tb) / 2, y0 + 0.35, txt, ha="center", va="center",
                            fontsize=6.3, color=C_TXT, family="DejaVu Sans Mono")
    for tm, lab in marks:
        ax.axvline(tm, color="#d35400", lw=0.8, ls="--")
        ax.text(tm, n * row_h - 0.05, lab, fontsize=6.5, color="#d35400",
                ha="left", va="bottom")
    ax.set_xlim(t0, t1)
    ax.set_ylim(-0.3, n * row_h + (0.25 if marks else 0))
    ax.set_yticks([])
    ax.grid(axis="x", color=C_GRID, lw=0.6)
    ax.set_axisbelow(True)
    for s in ("top", "right", "left"):
        ax.spines[s].set_visible(False)
    ax.tick_params(axis="x", labelsize=7)
    ax.set_xlabel("t, нс", fontsize=8)
    if title:
        ax.set_title(title, fontsize=9)
    fig.subplots_adjust(left=0.13, right=0.99, top=0.93 if title else 0.97, bottom=0.8 / h)
    fig.savefig(os.path.join(IMG, fname), facecolor=C_BG)
    plt.close(fig)
    print("saved", fname)


# ================================================================ Task 3.3
d = parse_vcd(os.path.join(BUILD, "tb_mux45_1.vcd"))
sig = [("STB", "stb", "bit", 1, None),
       ("A[5:0]", "a", "bus", 6, "dec"),
       ("D[44:0]", "d", "bus", 45, "hex"),
       ("Y", "y", "bit", 1, None)]
plot_waves(d, sig, 0, 2560, "mux45_full.png", width_in=11)
plot_waves(d, sig, 1280, 1400, "mux45_stb1_a0_5.png", width_in=11)
plot_waves(d, sig, 2140, 2280, "mux45_stb1_a43_49.png", width_in=11)
plot_waves(d, sig, 0, 120, "mux45_stb0.png", width_in=11)

# ================================================================ Task 3.3 доп.
d = parse_vcd(os.path.join(BUILD, "tb_mux_demux_prio.vcd"))
sig = [("MODE", "mode", "bit", 1, None),
       ("PRIO", "prio", "bit", 1, None),
       ("STB", "stb", "bit", 1, None),
       ("SEL[2:0]", "sel", "bus", 3, "dec"),
       ("REQ[7:0]", "req", "bus", 8, "bin"),
       ("X[7:0]", "x", "bus", 8, "bin"),
       ("DIN", "din", "bit", 1, None),
       ("Y", "y", "bit", 1, None),
       ("Q[7:0]", "q", "bus", 8, "bin"),
       ("CH[2:0]", "ch", "bus", 3, "dec"),
       ("VALID", "valid", "bit", 1, None)]
plot_waves(d, sig, 0, 320, "muxdemux_part1.png", width_in=12)

# ================================================================ Task 3.4
d = parse_vcd(os.path.join(BUILD, "tb_circuit_v7.vcd"))
sig = [("x1", "dut_s.x1", "bit", 1, None),
       ("x2", "dut_s.x2", "bit", 1, None),
       ("x3", "dut_s.x3", "bit", 1, None),
       ("x4", "dut_s.x4", "bit", 1, None),
       ("x1..x4", "test_x", "bus", 4, "bin"),
       ("y1 (Struct)", "dut_s.y1", "bit", 1, None),
       ("y2 (Struct)", "dut_s.y2", "bit", 1, None),
       ("y3 (Struct)", "dut_s.y3", "bit", 1, None),
       ("y4 (Struct)", "dut_s.y4", "bit", 1, None),
       ("y1..y4 (Struct)", "ys", "bus", 4, "bin"),
       ("y1..y4 (Behav)", "yb", "bus", 4, "bin")]
plot_waves(d, sig, 50, 450, "circuit_full.png", width_in=12)

# увеличенный фрагмент: набор 1010 (критический путь, 19 нс)
sig_cp = [("x1..x4", "test_x", "bus", 4, "bin"),
          ("x2", "dut_s.x2", "bit", 1, None),
          ("DD3 O2 (s_o2)", "dut_s.s_o2", "bit", 1, None),
          ("DD6 NMX2 (y4)", "dut_s.s_nmx2", "bit", 1, None),
          ("DD9 NO4 (s_no4)", "dut_s.s_no4", "bit", 1, None),
          ("DD10 NO3A2", "dut_s.s_no3a2", "bit", 1, None),
          ("DD11 N (y2)", "dut_s.y2", "bit", 1, None),
          ("y3 (Struct)", "dut_s.y3", "bit", 1, None),
          ("y1..y4 (Struct)", "ys", "bus", 4, "bin"),
          ("y1..y4 (Behav)", "yb", "bus", 4, "bin")]
t = 300
plot_waves(d, sig_cp, t - 3, t + 25, "circuit_critical.png", width_in=11,
           marks=[(t, "0 нс"), (t + 2, "2"), (t + 8, "8"), (t + 13, "13"),
                  (t + 18, "18"), (t + 19, "19 нс")])
