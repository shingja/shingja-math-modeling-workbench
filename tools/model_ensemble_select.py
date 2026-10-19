#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""MODEL_ENSEMBLE_SELECT Multi-model selection via AIC/BIC/CV/calibration. v3.0.0.

Python equivalent of model_ensemble_select.m.

Criteria:
  aic          — lowest AIC wins
  bic          — lowest BIC wins
  cv_rmse      — lowest cross-validation RMSE wins
  calibration  — highest calibration_score wins
  weighted     — 0.4*cal + 0.3*(1-cv_rmse_norm) + 0.3*(1-aic_norm)
"""

from __future__ import annotations

import math
import tempfile
from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class ModelResult:
    """Data for a single candidate model."""

    name: str
    aic: Optional[float] = None
    bic: Optional[float] = None
    cv_rmse: Optional[float] = None
    calibration_score: Optional[float] = None


@dataclass
class SelectionReport:
    """Container for model selection output."""

    names: list[str] = field(default_factory=list)
    scores: list[float] = field(default_factory=list)
    selected: str = ""
    criterion: str = "weighted"
    ranking: list[str] = field(default_factory=list)


VALID_CRITERIA = {"aic", "bic", "cv_rmse", "calibration", "weighted"}


def model_ensemble_select(
    model_results: list[ModelResult],
    criterion: str = "weighted",
) -> tuple[str, SelectionReport]:
    """Select the best model from candidates using the given criterion.

    Args:
        model_results: List of ModelResult dataclass instances (>= 2 required).
        criterion: One of 'aic', 'bic', 'cv_rmse', 'calibration', 'weighted'.

    Returns:
        (best_model_name, SelectionReport) tuple.
    """
    if criterion not in VALID_CRITERIA:
        raise ValueError(
            f"Invalid criterion '{criterion}'. Must be one of {VALID_CRITERIA}"
        )

    n = len(model_results)
    if n < 2:
        raise ValueError(f"Need at least 2 candidate models, got {n}")

    names = [m.name for m in model_results]
    scores: list[float] = []
    report = SelectionReport(names=names, criterion=criterion)

    if criterion == "aic":
        metrics = [m.aic for m in model_results]
        # Handle None values
        valid_indices = [i for i, v in enumerate(metrics) if v is not None]
        if not valid_indices:
            raise ValueError("No valid AIC values in model results")
        min_aic = min(metrics[i] for i in valid_indices)
        idx = min(valid_indices, key=lambda i: metrics[i])
        scores = [-m for m in metrics]  # negate so higher = better
        min_score = min(scores)
        max_score = max(scores)
        denom = max(max_score - min_score, 1)
        scores = [(s - min_score) / denom for s in scores]

    elif criterion == "bic":
        metrics = [m.bic for m in model_results]
        valid_indices = [i for i, v in enumerate(metrics) if v is not None]
        if not valid_indices:
            raise ValueError("No valid BIC values in model results")
        idx = min(valid_indices, key=lambda i: metrics[i])
        scores = [-m for m in metrics]
        min_score = min(scores)
        max_score = max(scores)
        denom = max(max_score - min_score, 1)
        scores = [(s - min_score) / denom for s in scores]

    elif criterion == "cv_rmse":
        metrics = [m.cv_rmse for m in model_results]
        valid_indices = [i for i, v in enumerate(metrics) if v is not None]
        if not valid_indices:
            raise ValueError("No valid CV_RMSE values in model results")
        idx = min(valid_indices, key=lambda i: metrics[i])
        lo = min(metrics[i] for i in valid_indices)
        hi = max(metrics[i] for i in valid_indices)
        denom = max(hi - lo, 1e-10)
        scores = [1.0 - (m - lo) / denom for m in metrics]

    elif criterion == "calibration":
        metrics = [m.calibration_score for m in model_results]
        valid_indices = [i for i, v in enumerate(metrics) if v is not None]
        if not valid_indices:
            raise ValueError("No valid calibration_score values in model results")
        idx = max(valid_indices, key=lambda i: metrics[i])
        scores = [m if m is not None else 0.0 for m in metrics]

    elif criterion == "weighted":
        # 0.4*cal + 0.3*(1-cv_norm) + 0.3*(1-aic_norm)
        cal = [m.calibration_score if m.calibration_score is not None else 0.5 for m in model_results]

        rmses = [m.cv_rmse for m in model_results]
        valid_rmse = [v for v in rmses if v is not None]
        if not valid_rmse:
            cv_norm = [0.0] * n
        else:
            lo, hi = min(valid_rmse), max(valid_rmse)
            denom = max(hi - lo, 1e-10)
            cv_norm = [(v - lo) / denom if v is not None else 0.5 for v in rmses]

        aics = [m.aic for m in model_results]
        valid_aic = [v for v in aics if v is not None]
        if not valid_aic:
            aic_norm = [0.0] * n
        else:
            lo, hi = min(valid_aic), max(valid_aic)
            denom = max(hi - lo, 1e-10)
            aic_norm = [(v - lo) / denom if v is not None else 0.5 for v in aics]

        scores = [
            0.4 * cal[i] + 0.3 * (1.0 - cv_norm[i]) + 0.3 * (1.0 - aic_norm[i])
            for i in range(n)
        ]
        idx = scores.index(max(scores))

    report.scores = scores
    report.selected = names[idx]

    # Ranking (descending score)
    ranking = sorted(zip(names, scores), key=lambda x: x[1], reverse=True)
    report.ranking = [name for name, _ in ranking]

    return report.selected, report


# ---------------------------------------------------------------------------
# Self-test
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    mr = [
        ModelResult(name="Model-A", aic=120, bic=135, cv_rmse=0.05, calibration_score=0.91),
        ModelResult(name="Model-B", aic=95, bic=110, cv_rmse=0.08, calibration_score=0.78),
        ModelResult(name="Model-C", aic=150, bic=165, cv_rmse=0.12, calibration_score=0.65),
    ]

    # AIC: Model-B should win (lowest AIC=95)
    best_aic, rep_aic = model_ensemble_select(mr, "aic")
    assert best_aic == "Model-B", f"AIC should select Model-B (lowest), got {best_aic}"
    assert rep_aic.ranking[0] == "Model-B"

    # BIC: Model-B should win (lowest BIC=110)
    best_bic, rep_bic = model_ensemble_select(mr, "bic")
    assert best_bic == "Model-B", f"BIC should select Model-B (lowest), got {best_bic}"

    # Calibration: Model-A should win (highest cal=0.91)
    best_cal, rep_cal = model_ensemble_select(mr, "calibration")
    assert best_cal == "Model-A", f"Calibration should select Model-A (highest), got {best_cal}"

    # CV_RMSE: Model-A should win (lowest cv_rmse=0.05)
    best_cv, rep_cv = model_ensemble_select(mr, "cv_rmse")
    assert best_cv == "Model-A", f"CV_RMSE should select Model-A (lowest), got {best_cv}"

    # Weighted composite
    best_w, rep_w = model_ensemble_select(mr, "weighted")
    assert len(rep_w.ranking) == 3, "Should have 3 candidates ranked"
    assert rep_w.selected in ["Model-A", "Model-B", "Model-C"], "Selected must be a valid model"

    # Verify report structure
    assert rep_w.names == ["Model-A", "Model-B", "Model-C"]
    assert rep_w.criterion == "weighted"
    assert len(rep_w.scores) == 3
    # Highest score should be ranked first
    assert rep_w.ranking[0] == rep_w.selected

    print("model_ensemble_select self-test passed.")
