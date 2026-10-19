#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""JOINT_CALIBRATE Compute joint calibration score. v3.0.0.

Python equivalent of joint_calibrate.m.
Protocol: protocols/joint_calibration_protocol.md

4-component scoring:
  score = 0.30*magnitude + 0.30*goodness + 0.20*stability + 0.20*invariant
"""

from __future__ import annotations

import json
import math
import os
import tempfile
from dataclasses import dataclass, field
from datetime import datetime
from typing import Any


@dataclass
class CalibrationReport:
    """Container for calibration scoring results."""

    magnitude_score: float = 0.0
    goodness_score: float = 0.0
    stability_score: float = 0.0
    invariant_score: float = 0.0
    score: float = 0.0
    verdict: str = "BLOCK"
    timestamp: str = ""


def joint_calibrate(
    handshake_path: str,
    results_path: str,
    threshold_pass: float = 0.85,
    threshold_warn: float = 0.70,
    n_seeds: int = 5,
) -> tuple[float, dict[str, Any]]:
    """Compute joint calibration score.

    Args:
        handshake_path: Path to handshake JSON file.
        results_path: Path to results JSON file.
        threshold_pass: Score threshold for PASS verdict.
        threshold_warn: Score threshold for WARN verdict (below this is BLOCK).
        n_seeds: Number of seeds for stability computations (reserved).

    Returns:
        (score, report) where report is a dict with all component scores and verdict.
    """
    # Load handshake
    with open(handshake_path, "r", encoding="utf-8") as f:
        handshake = json.load(f)

    # Load results
    with open(results_path, "r", encoding="utf-8") as f:
        results = json.load(f)

    report: dict[str, Any] = {}

    # D1: magnitude_score
    report["magnitude_score"] = _compute_magnitude_score(results, handshake)

    # D2: goodness_score
    report["goodness_score"] = _compute_goodness_score(results, handshake)

    # D3: stability_score
    report["stability_score"] = _compute_stability_score(results, handshake, n_seeds)

    # D4: invariant_score
    report["invariant_score"] = _compute_invariant_score(results, handshake)

    # Weighted composite score
    score = (
        0.30 * report["magnitude_score"]
        + 0.30 * report["goodness_score"]
        + 0.20 * report["stability_score"]
        + 0.20 * report["invariant_score"]
    )

    # Verdict
    if score >= threshold_pass:
        report["verdict"] = "PASS"
    elif score >= threshold_warn:
        report["verdict"] = "WARN"
    else:
        report["verdict"] = "BLOCK"

    report["score"] = score
    report["timestamp"] = datetime.now().isoformat()

    return score, report


def _compute_magnitude_score(results: dict, handshake: dict) -> float:
    """Compare key_results with validation_cases from handshake."""
    validation_cases = handshake.get("validation_cases")
    if not validation_cases:
        return 0.5  # neutral — no validation cases

    errors: list[float] = []
    key_results = results.get("key_results", [])

    for vc in validation_cases:
        actual = None
        vc_name = vc.get("name", "")
        vc_expected = vc.get("expected")

        # Find matching key_result by name (substring match)
        for kr in key_results:
            if vc_name in kr.get("name", ""):
                actual = kr.get("value")
                break

        if actual is not None and vc_expected is not None:
            denom = max(abs(vc_expected), 1e-10)
            err = abs(actual - vc_expected) / denom
            errors.append(err)

    if not errors:
        return 0.5

    mean_err = sum(errors) / len(errors)
    return max(0.0, min(1.0, 1.0 - mean_err))


def _compute_goodness_score(results: dict, handshake: dict) -> float:
    """Goodness: use residual, R^2, or conservation error from results."""
    goodness = results.get("goodness")
    if isinstance(goodness, dict) and "value" in goodness:
        return max(0.0, min(1.0, goodness["value"]))

    if "r_squared" in results:
        return max(0.0, min(1.0, results["r_squared"]))

    # Fallback: search key_results for goodness-related entries
    key_results = results.get("key_results", [])
    goodness_keywords = ("残差", "residual", "R2", "R-squared")
    for kr in key_results:
        kr_name = kr.get("name", "")
        if any(kw in kr_name for kw in goodness_keywords):
            return max(0.0, min(1.0, kr.get("value", 0.5)))

    return 0.5


def _compute_stability_score(
    results: dict, handshake: dict, n_seeds: int
) -> float:
    """Stability: sensitivity to random seed, based on CV."""
    stability = results.get("stability")
    if not isinstance(stability, dict) or "cv" not in stability:
        return 0.5

    cv_val = stability["cv"]
    return max(0.0, 1.0 - cv_val / 0.20)


def _compute_invariant_score(results: dict, handshake: dict) -> float:
    """Invariants: fraction of declared invariants that pass."""
    invariants = handshake.get("invariants")
    if not invariants:
        return 1.0

    n_invariants = len(invariants)
    results_invariants = results.get("invariants")
    if isinstance(results_invariants, dict) and "passed" in results_invariants:
        n_passed = results_invariants["passed"]
    else:
        # If results didn't explicitly report, assume all passed
        n_passed = n_invariants

    return n_passed / max(n_invariants, 1)


# ---------------------------------------------------------------------------
# Self-test
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    import random

    random.seed(42)

    # Build dummy handshake
    hs = {
        "model_id": "test-model",
        "variable_map": [{"name": "x1", "meaning": "var", "unit": "m"}],
        "validation_cases": [
            {"name": "score_A", "expected": 0.8234, "tol": 1e-3}
        ],
        "invariants": ["sum(w)=1", "w_i in [0,1]"],
    }

    tmpdir = tempfile.mkdtemp()
    hs_path = os.path.join(tmpdir, "test_handshake.json")
    with open(hs_path, "w", encoding="utf-8") as f:
        json.dump(hs, f)

    # Build dummy results (all perfect)
    res = {
        "key_results": [{"name": "score_A", "value": 0.8234}],
        "goodness": {"value": 0.95},
        "stability": {"cv": 0.03},
        "invariants": {"passed": 2},
    }
    res_path = os.path.join(tmpdir, "test_results.json")
    with open(res_path, "w", encoding="utf-8") as f:
        json.dump(res, f)

    sc, rp = joint_calibrate(hs_path, res_path)

    # Perfect match: magnitude=1, goodness=0.95, stability=0.85, invariants=1
    expected = 0.30 * 1.0 + 0.30 * 0.95 + 0.20 * 0.85 + 0.20 * 1.0
    print(f"Expected={expected:.4f}, Got={sc:.4f}")
    assert abs(sc - expected) < 0.01, f"Score mismatch: {sc:.4f} vs {expected:.4f}"
    assert rp["verdict"] == "PASS", "Should PASS for perfect results"
    assert rp["magnitude_score"] > 0.9, "Magnitude should be near 1"

    # Test WARN threshold — score is 0.955, raise pass bar to 0.96 to trigger WARN
    sc2, rp2 = joint_calibrate(hs_path, res_path, threshold_pass=0.96)
    assert rp2["verdict"] == "WARN", f"Should WARN for score below 0.96, got {rp2['verdict']}"

    print("joint_calibrate self-test passed.")
