#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""RESULT_CLAIM_BIND Bind results to paper claims via SHA-256 hash. v3.0.0.

Python equivalent of result_claim_bind.m.

Modes:
  bind   — compute SHA-256 of JSON, write to .bind_hash
  verify — compare stored hash with current hash; warn on mismatch
"""

from __future__ import annotations

import hashlib
import json
import os
import tempfile
from typing import Optional


def result_claim_bind(
    results_json_path: str, mode: str = "bind"
) -> tuple[bool, Optional[str]]:
    """Bind or verify results JSON against a stored SHA-256 hash.

    Args:
        results_json_path: Path to the results JSON file.
        mode: 'bind' to write the hash, 'verify' to check it.

    Returns:
        (bound, hash_hex) tuple:
          - bound: True if bind succeeded or verify matched.
          - hash_hex: The computed SHA-256 hex digest (or None on error).
    """
    if mode not in ("bind", "verify"):
        raise ValueError(f"mode must be 'bind' or 'verify', got '{mode}'")

    results_dir = os.path.dirname(os.path.abspath(results_json_path))
    hash_path = os.path.join(results_dir, ".bind_hash")

    # Read JSON as raw bytes for exact hashing
    try:
        with open(results_json_path, "rb") as f:
            raw_content = f.read()
    except (OSError, IOError) as e:
        print(f"ERROR: Cannot read results JSON: {e}")
        return False, None

    # Compute SHA-256
    sha256_hash = hashlib.sha256(raw_content).hexdigest()

    if mode == "bind":
        try:
            with open(hash_path, "w", encoding="utf-8") as f:
                f.write(sha256_hash)
        except OSError as e:
            print(f"ERROR: Cannot write .bind_hash: {e}")
            return False, sha256_hash
        return True, sha256_hash

    # mode == 'verify'
    if not os.path.isfile(hash_path):
        print(
            "WARNING (RESULT_CLAIM:NoBind): "
            ".bind_hash not found. Run bind first."
        )
        return False, sha256_hash

    try:
        with open(hash_path, "r", encoding="utf-8") as f:
            stored_hash = f.read().strip()
    except OSError as e:
        print(f"ERROR: Cannot read .bind_hash: {e}")
        return False, sha256_hash

    if sha256_hash != stored_hash:
        print(
            "WARNING (RESULT_CLAIM:Mismatch): "
            f"Results JSON has changed since last bind! "
            f"Hash stored={stored_hash[:16]}..., current={sha256_hash[:16]}..."
        )
        return False, sha256_hash

    return True, sha256_hash


# ---------------------------------------------------------------------------
# Self-test
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    tmpdir = tempfile.mkdtemp()

    results_path = os.path.join(tmpdir, "test_claim.json")
    original = json.dumps({"score": 0.95, "method": "TOPSIS"})
    with open(results_path, "w", encoding="utf-8") as f:
        f.write(original)

    # 1) Bind
    b1, h1 = result_claim_bind(results_path, "bind")
    assert b1, "Bind should succeed"
    assert h1 is not None and len(h1) == 64, "Hash should be 64 hex chars"
    hash_file = os.path.join(tmpdir, ".bind_hash")
    assert os.path.isfile(hash_file), ".bind_hash should exist after bind"

    # 2) Verify unchanged
    b2, _ = result_claim_bind(results_path, "verify")
    assert b2, "Verify should pass immediately after bind"

    # 3) Tamper and verify should fail
    tampered = json.dumps({"score": 0.50, "method": "TOPSIS"})
    with open(results_path, "w", encoding="utf-8") as f:
        f.write(tampered)

    b3, _ = result_claim_bind(results_path, "verify")
    assert not b3, "Verify should FAIL after tampering"

    print("result_claim_bind self-test passed.")
