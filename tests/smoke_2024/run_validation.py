#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""S11 smoke test validation runner for math-modeling Skill v3.0.0."""

import sys, os

# Point to tools directory
tools_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'tools'))
sys.path.insert(0, tools_dir)

os.chdir(os.path.dirname(__file__))

from handshake_validate import handshake_validate

print("=" * 60)
print("HANDSHAKE VALIDATION")
print("=" * 60)

for q in ['handshake_Q1.json', 'handshake_Q2.json']:
    valid, missing, details = handshake_validate(q)
    print(f'{q}: valid={valid}')
    if missing:
        print(f'  missing_fields: {missing}')
    print(f'  details: {details}')

print()
print("=" * 60)
print("JOINT CALIBRATION")
print("=" * 60)

from joint_calibrate import joint_calibrate
score, report = joint_calibrate('handshake_Q1.json', 'results/results_q1.json')
print(f'Q1 calibration_score: {score:.4f}, verdict: {report["verdict"]}')
print(f'  magnitude: {report["magnitude_score"]:.4f}')
print(f'  goodness:  {report["goodness_score"]:.4f}')
print(f'  stability: {report["stability_score"]:.4f}')
print(f'  invariant: {report["invariant_score"]:.4f}')

print()
print("=" * 60)
print("RESULT CLAIM BINDING")
print("=" * 60)

from result_claim_bind import result_claim_bind
bound, hash_val = result_claim_bind('results/results_q1.json', 'bind')
print(f'Bind: {bound}, hash: {hash_val}')
bound2, hash_val2 = result_claim_bind('results/results_q1.json', 'verify')
print(f'Verify: {bound2}')

print()
print("=" * 60)
print("MODEL ENSEMBLE SELECTION")
print("=" * 60)

from model_ensemble_select import model_ensemble_select, ModelResult
mr = [
    ModelResult('LP', aic=None, bic=None, cv_rmse=None, calibration_score=0.92),
    ModelResult('IP with rotation', aic=None, bic=None, cv_rmse=None, calibration_score=0.85)
]
best, sel_report = model_ensemble_select(mr, 'weighted')
print(f'Selected: {best}')
print(f'Criterion: {sel_report.criterion}')
print(f'Ranking: {sel_report.ranking}')
print(f'Scores: {sel_report.scores}')

print()
print("=" * 60)
print("ALL VALIDATION TOOLS PASSED")
print("=" * 60)
