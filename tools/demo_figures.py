#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""生成 README 示例图:banner / 工作流示意图 / 4 张出版级风格示例。

示例图走本 Skill 自己的出版规范(Okabe-Ito 色板 + 布局与设计双门禁 + SVG/PNG 双格式),
数据全部为合成数据,仅用于展示出图规范。

按 Skill 的路径隔离约定,图形先导出到临时 PROJECT_ROOT,再复制进 imgs/。

用法:
    python tools/demo_figures.py            # 生成全部
    python tools/demo_figures.py --keep     # 保留临时目录(便于检查中间产物)
"""
from __future__ import annotations

import argparse
import shutil
import sys
import tempfile
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "references" / "roles" / "Tide" / "scripts"))

import matplotlib  # noqa: E402

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch  # noqa: E402

import plot_style as ps  # noqa: E402

HANDOFF = ROOT / "imgs"
SEED = 20261008


def _style():
    return ps.apply_publication_style(language="en", width="double")


def figure_pareto_topsis():
    rng = np.random.default_rng(SEED)
    style = _style()
    fig, (ax1, ax2) = ps.publication_subplots(1, 2, width="double", aspect=0.46)

    # (a) Pareto front
    cost = rng.random(200)
    risk = (1.0 - cost) ** 1.6 + rng.normal(0, 0.045, 200)
    order = np.argsort(cost)
    front_x, front_y, best = [], [], np.inf
    for x, y in zip(cost[order], risk[order]):
        if y < best:
            front_x.append(x)
            front_y.append(y)
            best = y
    ax1.scatter(cost, risk, s=7, color=ps.PALETTE["neutral"], alpha=0.45,
                label="dominated designs")
    ax1.plot(front_x, front_y, color=ps.PALETTE["primary"], label="Pareto front",
             marker="o", markevery=3, ms=3.2)
    knee = int(np.argmin(np.abs(np.array(front_x) - 0.45)))
    ax1.annotate("knee / compromise", xy=(front_x[knee], front_y[knee]),
                 xytext=(0.52, 0.72), textcoords="axes fraction",
                 arrowprops=dict(arrowstyle="-", color=ps.PALETTE["dark"], lw=0.7))
    ax1.set_xlabel("Objective 1 — normalized cost")
    ax1.set_ylabel("Objective 2 — normalized risk")
    ax1.set_title("Pareto front (200 designs)")
    ax1.legend(loc="upper right")

    # (b) Entropy-TOPSIS ranking
    names = ["A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8"]
    closeness = np.array([0.42, 0.58, 0.36, 0.71, 0.49, 0.64, 0.55, 0.31])
    order = np.argsort(closeness)
    colors = [ps.PALETTE["primary"] if i == order[-1] else ps.PALETTE["neutral"]
              for i in order]
    ax2.barh(np.array(names)[order], closeness[order], color=colors, height=0.62)
    ax2.set_xlabel("Closeness coefficient")
    ax2.set_title("Entropy–TOPSIS ranking")
    ax2.set_xlim(0, 0.8)
    for y, value in enumerate(closeness[order]):
        ax2.text(value + 0.015, y, f"{value:.2f}", va="center", fontsize=6.5)

    return fig, "demo-01-optimization-evaluation"


def figure_forecast_mechanism():
    style = _style()
    fig, (ax1, ax2) = ps.publication_subplots(1, 2, width="double", aspect=0.46)

    # (a) Forecast with confidence band
    t = np.arange(60)
    level = 40 + 0.55 * t + 3.2 * np.sin(t / 4.4)
    rng = np.random.default_rng(SEED + 1)
    observed = level + rng.normal(0, 0.85, t.size)
    fit_t, fc_t = t[:40], t[39:]
    ax1.plot(fit_t, observed[:40], color=ps.PALETTE["dark"], marker="o", ms=2.6,
             markevery=5, label="observed")
    ax1.plot(fc_t, level[39:], color=ps.PALETTE["primary"], label="forecast")
    sigma = 1.9 * np.sqrt(np.maximum(fc_t - 40, 0)/1 + 1)
    ax1.fill_between(fc_t, level[39:] - 1.96 * sigma, level[39:] + 1.96 * sigma,
                     color=ps.PALETTE["sky"], alpha=0.25, lw=0, label="95% interval")
    ax1.axvline(40, color=ps.PALETTE["neutral"], ls=(0, (4, 3)), lw=0.7)
    ax1.annotate("forecast horizon", xy=(44, 46), fontsize=6.5,
                 color=ps.PALETTE["neutral"])
    ax1.set_xlabel("Time step")
    ax1.set_ylabel("Demand (scaled)")
    ax1.set_title("Forecast with 95% band")
    ax1.legend(loc="upper left", ncols=3)

    # (b) SEIR trajectories
    days = np.linspace(0, 160, 320)
    beta, sigma, gamma = 0.42, 0.18, 0.12
    S, E, I, R = 0.999, 0.001, 0.0, 0.0
    out = np.zeros((days.size, 4))
    for i, _ in enumerate(days):
        out[i] = (S, E, I, R)
        dS, dE, dI = -beta * S * I, beta * S * I - sigma * E, sigma * E - gamma * I
        S, E, I, R = S + dS/40, E + dE/40, I + dI/40, R + gamma * I/40
    labels = ["Susceptible", "Exposed", "Infectious", "Recovered"]
    for idx, label in enumerate(labels):
        ax2.plot(days, out[:, idx], label=label)
    ax2.annotate(f"$R_0$ = {beta/gamma:.1f}", xy=(0.66, 0.62),
                 xycoords="axes fraction", fontsize=7.5)
    ax2.set_xlabel("Day")
    ax2.set_ylabel("Population share")
    ax2.set_title("SEIR trajectories")
    ax2.legend(loc="center right")

    return fig, "demo-02-forecast-mechanism"


def figure_ml_statistics():
    style = _style()
    fig, (ax1, ax2) = ps.publication_subplots(1, 2, width="double", aspect=0.46)

    # (a) Confusion matrix
    matrix = np.array([[412, 37, 12], [24, 268, 31], [9, 18, 231]])
    ax1.imshow(matrix, cmap="Blues")
    for i in range(3):
        for j in range(3):
            ax1.text(j, i, str(matrix[i, j]), ha="center", va="center", fontsize=6.5,
                     color=ps.PALETTE["dark"] if matrix[i, j] < 300 else "white")
    ax1.set_xticks(range(3), ["Dent", "Hole", "Rust"])
    ax1.set_yticks(range(3), ["Dent", "Hole", "Rust"])
    ax1.set_xlabel("Predicted")
    ax1.set_ylabel("Observed")
    ax1.set_title("Confusion matrix (held-out)")
    ax1.grid(False)

    # (b) ROC curves
    fpr = np.linspace(0, 1, 200)
    for idx, (name, power) in enumerate([("Baseline", 2.2), ("Extended", 3.4), ("Ensemble", 4.6)]):
        tpr = 1 - (1 - fpr) ** power
        auc = power / (power + 1)
        ax2.plot(fpr, tpr, label=f"{name} (AUC {auc:.3f})")
    ax2.plot([0, 1], [0, 1], color=ps.PALETTE["neutral"], ls=(0, (4, 3)), lw=0.7,
             label="chance")
    ax2.set_xlabel("False positive rate")
    ax2.set_ylabel("True positive rate")
    ax2.set_title("Detection ROC comparison")
    ax2.legend(loc="lower right")

    return fig, "demo-03-ml-statistics"


def figure_sensitivity():
    style = _style()
    fig, (ax1, ax2) = ps.publication_subplots(1, 2, width="double", aspect=0.46)

    # (a) Sobol indices
    params = ["k_fin", "t_wall", "mdot", "T_in", "rough", "L_ch"]
    s1 = np.array([0.34, 0.22, 0.15, 0.09, 0.06, 0.04])
    st = np.array([0.46, 0.33, 0.24, 0.16, 0.11, 0.07])
    y = np.arange(len(params))
    ax1.barh(y + 0.19, st, height=0.36, color=ps.PALETTE["sky"], label="total order")
    ax1.barh(y - 0.19, s1, height=0.36, color=ps.PALETTE["primary"], label="first order")
    ax1.set_yticks(y, params)
    ax1.set_xlabel("Sobol index")
    ax1.set_title("Global sensitivity (Sobol)")
    ax1.set_xlim(0, 0.55)
    ax1.legend(loc="lower right")

    # (b) Convergence of optimizers
    iters = np.arange(1, 121)
    rng = np.random.default_rng(SEED + 2)
    curves = {
        "NSGA-II": 0.62 * np.exp(-iters / 26) + 0.07,
        "MOEA/D": 0.58 * np.exp(-iters / 31) + 0.075,
        "PSO": 0.66 * np.exp(-iters / 19) + 0.085,
        "DE": 0.60 * np.exp(-iters / 23) + 0.08,
    }
    for name, curve in curves.items():
        noise = rng.normal(0, 0.008, iters.size)
        best = np.minimum.accumulate(curve + noise)
        ax2.plot(iters, best, label=name)
    ax2.set_xlabel("Iteration")
    ax2.set_ylabel("Best objective")
    ax2.set_title("Optimizer convergence")
    ax2.set_yscale("log")
    ax2.set_ylim(0.05, 1.2)
    ax2.yaxis.set_minor_formatter(matplotlib.ticker.NullFormatter())
    ax2.legend(loc="upper right", ncols=2)

    return fig, "demo-04-sensitivity-convergence"


def figure_workflow():
    style = _style()
    fig = plt.figure(figsize=(12.6, 3.5))
    fig.set_layout_engine("none")
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 12.6)
    ax.set_ylim(0, 3.5)
    ax.axis("off")

    def box(x, y, w, h, text, *, face="#FFFFFF", edge=ps.PALETTE["neutral"], bold=False):
        ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.06,rounding_size=0.08",
                                    linewidth=0.8, edgecolor=edge, facecolor=face))
        ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=7.4,
                color=ps.PALETTE["dark"], fontweight="bold" if bold else "normal")

    def arrow(x1, y1, x2, y2, *, color=ps.PALETTE["dark"], style="-|>", ls="-"):
        ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2), arrowstyle=style, ls=ls,
                                     linewidth=0.9, color=color, shrinkA=1, shrinkB=1,
                                     mutation_scale=8))

    ax.text(0.15, 3.14, "Math Modeling Skill — three-role pipeline with quality gates",
            fontsize=9.4, fontweight="bold", color=ps.PALETTE["dark"])
    ax.text(0.15, 2.86, "Modeler / Coder / Writer · every stage verified before hand-off",
            fontsize=7.2, color=ps.PALETTE["neutral"])

    stages = [
        (0.15, "Problem\n+ data", ps.PALETTE["neutral"]),
        (1.85, "Modeler\nmodelling · M1", ps.PALETTE["primary"]),
        (3.85, "Coder\nsolve & plot\nP1 · C1 · P2", ps.PALETTE["secondary"]),
        (5.85, "Writer\npaper · W1 · W2", ps.PALETTE["positive"]),
        (7.85, "Delivery\npackage", ps.PALETTE["accent"]),
    ]
    for x, label, color in stages:
        box(x, 1.62, 1.5, 0.98, label, edge=color)
    for x in (1.65, 3.65, 5.65, 7.65):
        arrow(x, 2.11, x + 0.2, 2.11, color=ps.PALETTE["neutral"])

    box(1.85, 0.30, 5.5, 0.62,
        "M-Loop: metric target card → quality score → iterate or search beyond library",
        edge=ps.PALETTE["contrast"])
    arrow(4.6, 1.62, 4.6, 0.92, color=ps.PALETTE["contrast"])
    arrow(2.6, 0.92, 2.6, 1.62, color=ps.PALETTE["contrast"], style="-|>")
    ax.text(2.74, 1.27, "rework", fontsize=6.0, color=ps.PALETTE["contrast"])

    ax.text(7.85, 0.61,
            "In-stage Subagent audit (read-only) runs at every gate;\n"
            "failed checks send the stage back for rework.",
            fontsize=6.8, color=ps.PALETTE["sky"], va="center")

    return fig, "workflow"


def figure_banner():
    fig = plt.figure(figsize=(12.8, 2.7))
    fig.set_layout_engine("none")
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 12.8)
    ax.set_ylim(0, 2.7)
    ax.axis("off")
    ax.add_patch(FancyBboxPatch((0, 0), 12.8, 2.7, boxstyle="square,pad=0",
                                linewidth=0, facecolor="#0F2A43"))
    ax.add_patch(FancyBboxPatch((0, 0), 0.16, 2.7, boxstyle="square,pad=0",
                                linewidth=0, facecolor=ps.PALETTE["secondary"]))
    ax.text(0.62, 1.72, "Math Modeling Skill", fontsize=26, color="white",
            fontweight="bold")
    ax.text(0.66, 1.16, "Three-role agent workflow for mathematical-modeling competitions",
            fontsize=11.5, color="#C9D6E2")
    ax.text(0.66, 0.62,
            "12 problem categories  ·  164 paradigm cards  ·  MATLAB + Python  ·  "
            "6 quality gates  ·  v1.0.0",
            fontsize=9.2, color=ps.PALETTE["sky"])
    return fig, "banner"


def figure_social_preview():
    """GitHub 社交预览图：1280×640（2:1）。"""
    fig = plt.figure(figsize=(6.4, 3.2))
    fig.set_layout_engine("none")
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 6.4)
    ax.set_ylim(0, 3.2)
    ax.axis("off")
    ax.add_patch(FancyBboxPatch((0, 0), 6.4, 3.2, boxstyle="square,pad=0",
                                linewidth=0, facecolor="#0F2A43"))
    ax.add_patch(FancyBboxPatch((0, 0), 0.10, 3.2, boxstyle="square,pad=0",
                                linewidth=0, facecolor=ps.PALETTE["secondary"]))
    ax.text(0.42, 2.28, "Math Modeling Skill", fontsize=19, color="white",
            fontweight="bold")
    ax.text(0.44, 1.78, "Three-role agent workflow for mathematical-modeling\ncompetitions — "
            "modelling, solving, writing, with quality gates",
            fontsize=7.6, color="#C9D6E2", va="top")
    ax.text(0.44, 0.72,
            "164 paradigm cards  ·  MATLAB + Python  ·  6 gates\n"
            "publication-grade figures  ·  copyright-identifiers retained",
            fontsize=6.6, color=ps.PALETTE["sky"], va="top")
    ax.text(5.98, 0.42, "github.com/shingja", fontsize=6.2, color="#7E93A6",
            ha="right")
    return fig, "social-preview"


def stamp_png(path: Path) -> None:
    """给 PNG 写入作者/来源元数据（可被 exiftool / 图片属性查看，属归属证据）。"""
    try:
        from PIL import Image, PngImagePlugin
    except ImportError:
        return
    with Image.open(path) as image:
        meta = PngImagePlugin.PngInfo()
        for key, value in (
            ("Author", "shingja"),
            ("Copyright", "© 2026 shingja — dual-licensed, see LICENSE"),
            ("Source", "https://github.com/shingja/shingja-math-modeling-workbench"),
            ("Comment", "retains copyright identifiers; removing attribution violates the license"),
        ):
            meta.add_text(key, value)
        image.save(path, pnginfo=meta)


def main() -> int:
    parser = argparse.ArgumentParser(description="生成 README 示例图")
    parser.add_argument("--keep", action="store_true", help="保留临时 PROJECT_ROOT")
    args = parser.parse_args()

    work = Path(tempfile.mkdtemp(prefix="mm_demo_project_"))
    HANDOFF.mkdir(exist_ok=True)
    exported = []

    for builder in (figure_pareto_topsis, figure_forecast_mechanism,
                    figure_ml_statistics, figure_sensitivity):
        fig, stem = builder()
        outputs = ps.export_figure(fig, work / stem, grayscale_preview=False)
        plt.close(fig)
        for kind, source in outputs.items():
            target = HANDOFF / f"{stem}{Path(source).suffix}"
            shutil.copy2(source, target)
            exported.append(target)

    # Brand assets (banner / workflow / social-preview) are curated SVG files in
    # imgs/. Do not regenerate them here: matplotlib output would overwrite the
    #  visual identity. Only the four demo figures above are regenerated.

    for path in exported:
        if path.suffix.lower() == ".png":
            stamp_png(path)
        print("导出 " + path.relative_to(ROOT).as_posix())
    print(f"\n共 {len(exported)} 个文件;中间产物: {work}")
    if not args.keep:
        shutil.rmtree(work, ignore_errors=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
