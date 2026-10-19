#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""HANDSHAKE_VALIDATE Check model handshake package completeness. v3.0.0.

Python equivalent of handshake_validate.m.

Validates 7 required fields plus extra quality checks:
  - validation_cases >= 2
  - invariants >= 1
  - variable_map entries >= 1
"""

from __future__ import annotations

import json
import os
import tempfile
from typing import Any

REQUIRED_FIELDS = [
    "model_id",
    "math_formulation",
    "variable_map",
    "pseudo_code",
    "parameter_bounds",
    "validation_cases",
    "invariants",
]


def handshake_validate(handshake_path: str) -> tuple[bool, list[str], dict[str, Any]]:
    """Validate a handshake JSON package.

    Args:
        handshake_path: Path to the handshake JSON file.

    Returns:
        (valid, missing_fields, details) tuple:
          - valid: True if all checks pass
          - missing_fields: list of missing required field names
          - details: dict with extra counts (validation_cases_count, etc.)
    """
    if not os.path.isfile(handshake_path):
        return False, ["FILE_NOT_FOUND"], {}

    if not handshake_path.lower().endswith(".json"):
        return False, ["INVALID_FORMAT"], {}

    try:
        with open(handshake_path, "r", encoding="utf-8") as f:
            hs = json.load(f)
    except (json.JSONDecodeError, OSError):
        return False, ["JSON_PARSE_ERROR"], {}

    # Check required fields
    missing_fields = [field for field in REQUIRED_FIELDS if field not in hs]

    # Extra quality checks
    details: dict[str, Any] = {}

    validation_cases = hs.get("validation_cases")
    if isinstance(validation_cases, list) and validation_cases:
        details["validation_cases_count"] = len(validation_cases)
    else:
        details["validation_cases_count"] = 0

    invariants = hs.get("invariants")
    if isinstance(invariants, list) and invariants:
        details["invariants_count"] = len(invariants)
    else:
        details["invariants_count"] = 0

    variable_map = hs.get("variable_map")
    if isinstance(variable_map, list) and variable_map:
        details["variable_map_rows"] = len(variable_map)
    else:
        details["variable_map_rows"] = 0

    # Composite validity
    valid = (
        len(missing_fields) == 0
        and details["validation_cases_count"] >= 2
        and details["invariants_count"] >= 1
        and details["variable_map_rows"] >= 1
    )

    return valid, missing_fields, details


# ---------------------------------------------------------------------------
# Self-test
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    tmpdir = tempfile.mkdtemp()

    # Test 1: complete package
    hs_complete = {
        "model_id": "Q1-TOPSIS",
        "math_formulation": "min f(x)",
        "variable_map": [
            {"name": "x1", "meaning": "a", "unit": "m"},
            {"name": "x2", "meaning": "b", "unit": "s"},
        ],
        "pseudo_code": "Step1: ...",
        "parameter_bounds": {"alpha": [0.01, 0.99]},
        "validation_cases": [
            {"name": "v1", "expected": 0.5, "tol": 1e-3},
            {"name": "v2", "expected": 0.8, "tol": 1e-3},
        ],
        "invariants": ["sum(w)=1"],
    }
    hs_complete_path = os.path.join(tmpdir, "hs_valid.json")
    with open(hs_complete_path, "w", encoding="utf-8") as f:
        json.dump(hs_complete, f)

    ok, missing, details = handshake_validate(hs_complete_path)
    assert ok, "Complete handshake should be valid"
    assert len(missing) == 0, f"Should have no missing fields, got {missing}"
    assert details["validation_cases_count"] == 2
    assert details["invariants_count"] == 1
    assert details["variable_map_rows"] == 2

    # Test 2: incomplete package — only 2 of 7 fields
    hs_incomplete = {
        "model_id": "test",
        "math_formulation": "f(x)",
    }
    hs_incomplete_path = os.path.join(tmpdir, "hs_invalid.json")
    with open(hs_incomplete_path, "w", encoding="utf-8") as f:
        json.dump(hs_incomplete, f)

    ok2, missing2, details2 = handshake_validate(hs_incomplete_path)
    assert not ok2, "Incomplete handshake should be invalid"
    assert len(missing2) >= 5, f"Should list >=5 missing fields, got {len(missing2)}"
    assert details2["validation_cases_count"] == 0

    # Test 3: file not found
    ok3, missing3, _ = handshake_validate("/nonexistent/path.json")
    assert not ok3
    assert "FILE_NOT_FOUND" in missing3

    print("handshake_validate self-test passed.")
