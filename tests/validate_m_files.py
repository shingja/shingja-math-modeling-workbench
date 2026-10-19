#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""
validate_m_files.py — Static structure validator for MATLAB .m files
Checks 7 items per V1 spec. Does NOT require MATLAB runtime.
Output: JSON report at tests/validate_report.json
"""

import os, re, json, sys
from pathlib import Path
from datetime import datetime

SKILL_ROOT = Path(__file__).resolve().parents[1]
MATLAB_DIR = SKILL_ROOT / 'matlab'
TESTS_DIR = SKILL_ROOT / 'tests'
MANIFEST_PATH = TESTS_DIR / 'manifest.json'
REPORT_PATH = TESTS_DIR / 'validate_report.json'

# Algorithms that DO use randomness (should have rng)
RANDOM_ALGOS = {
    'genetic', 'ga', 'pso', 'particle', 'swarm', 'simulated', 'annealing',
    'ant_colony', 'aco', 'differential_evolution', 'de', 'grey_wolf', 'gwo',
    'immune', 'whale', 'woa', 'sparrow', 'ssa', 'tabu', 'monte', 'carlo',
    'mcmc', 'metropolis', 'gibbs', 'random_forest', 'isolation_forest',
    'bootstrap', 'cellular_automata', 'queuing', 'neural', 'lstm',
    'nsga', 'moea', 'stochastic', 'chance', 'cvar',
}

def normalize_path(p):
    return str(Path(p).as_posix())

def count_logic_lines(content):
    """Count non-empty, non-comment, non-pure-end lines."""
    lines = content.split('\n')
    logic = 0
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith('%'):
            continue
        if stripped.lower() in ('end', 'end;'):
            continue
        logic += 1
    return logic

def has_self_test(content):
    """Check for %% Self-test or %% Test section with numerical assert."""
    # Find self-test section
    sections = re.split(r'^%%', content, flags=re.MULTILINE)
    for sec in sections:
        sec_lower = sec.lower()
        if 'self-test' in sec_lower or 'self test' in sec_lower or 'test' in sec_lower[:20]:
            # Check for any assert() call in the self-test section
            if re.search(r'\bassert\s*\(', sec):
                return True
    return False

def validate_file(filepath):
    """Run 7-item check on a single .m file. Returns dict."""
    fname = os.path.basename(filepath)
    relpath = os.path.relpath(filepath, SKILL_ROOT)

    try:
        with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
    except Exception as e:
        return {'file': fname, 'path': relpath, 'error': str(e), 'pass': False}

    results = {'file': fname, 'path': relpath}
    logic_lines = count_logic_lines(content)

    # Item 1: function signature
    has_func = bool(re.search(r'^\s*function\s+', content, re.MULTILINE | re.IGNORECASE))
    results['v1_function_signature'] = has_func

    # Item 2: arguments block or nargin check
    has_args = bool(re.search(r'^\s*arguments\b', content, re.MULTILINE))
    has_nargin = bool(re.search(r'nargin\b', content))
    has_input_parse = bool(re.search(r'inputParser\b', content))
    results['v2_arg_validation'] = has_args or has_nargin or has_input_parse

    # Item 3: rng seed (only required for random algorithms)
    fname_lower = fname.lower()
    is_random = any(keyword in fname_lower for keyword in RANDOM_ALGOS)
    # Also check content for randomization usage
    if not is_random:
        is_random = bool(re.search(r'\b(rand|randn|randi|randperm|rng)\b', content))

    has_rng = bool(re.search(r"rng\s*\(\s*\w+.*['\"]twister['\"]", content))
    has_rng_simple = bool(re.search(r"rng\s*\(\s*\w+\s*\)", content))
    has_seed_param = bool(re.search(r"seed\b", content, re.IGNORECASE))

    if is_random:
        results['v3_rng_seed'] = has_rng or has_rng_simple or has_seed_param
    else:
        results['v3_rng_seed'] = 'N/A (non-random)'
    results['is_random'] = is_random

    # Item 4: actual logic lines >= 20
    results['v4_logic_lines'] = logic_lines
    results['v4_logic_min_20'] = logic_lines >= 20

    # Item 5: fullfile usage (not hardcoded paths)
    has_fullfile = bool(re.search(r'\bfullfile\b', content))
    has_relative = bool(re.search(r"['\"][.][.]?/", content))  # relative path indicator
    # Check for hardcoded absolute windows paths
    has_hardcoded = bool(re.search(r"['\"][A-Z]:\\", content))
    results['v5_fullfile'] = has_fullfile or has_relative or (not has_hardcoded)
    results['v5_has_hardcoded_path'] = has_hardcoded

    # Item 6: exitflag / convergence / numerical sanity check
    has_exitflag = bool(re.search(r'\bexitflag\b', content))
    has_convergence = bool(re.search(r'(converged|convergence|tol\b|tolerance|stopping)', content, re.IGNORECASE))
    has_assert_numeric = bool(re.search(r'(assert|error|warning).*(abs|diff|err|close|tol|nan|inf|negative|bounds)', content, re.IGNORECASE))
    results['v6_exitflag_or_check'] = has_exitflag or has_convergence or has_assert_numeric

    # Item 7: self-test section with numerical assert
    results['v7_self_test'] = has_self_test(content)

    # Total pass
    check_keys = ['v1_function_signature', 'v2_arg_validation', 'v4_logic_min_20',
                  'v5_fullfile', 'v6_exitflag_or_check', 'v7_self_test']
    all_pass = all(results.get(k, False) for k in check_keys)
    rng_ok = results['v3_rng_seed'] in (True, 'N/A (non-random)')
    results['total_pass'] = all_pass and rng_ok
    results['failed_checks'] = [k for k in check_keys if not results.get(k, False)]
    if not rng_ok:
        results['failed_checks'].append('v3_rng_seed')

    return results


def main():
    m_files = list(MATLAB_DIR.rglob('*.m'))
    print(f'Found {len(m_files)} .m files in {MATLAB_DIR}')

    results = []
    passed = 0
    failed = 0

    for fp in sorted(m_files):
        r = validate_file(fp)
        results.append(r)
        if r.get('total_pass', False):
            passed += 1
        else:
            failed += 1

    # Summary
    by_category = {}
    for r in results:
        cat = r['path'].split('/')[1] if '/' in r['path'] else 'root'
        by_category.setdefault(cat, {'total': 0, 'passed': 0, 'failed': 0})
        by_category[cat]['total'] += 1
        if r.get('total_pass'):
            by_category[cat]['passed'] += 1
        else:
            by_category[cat]['failed'] += 1

    # Generate report
    report = {
        'meta': {
            'generated_utc': datetime.utcnow().isoformat() + 'Z',
            'validator_version': 'v1.0-static',
            'total_files': len(m_files),
            'passed': passed,
            'failed': failed,
            'pass_rate': f'{passed/len(m_files)*100:.1f}%' if m_files else 'N/A',
        },
        'by_category': by_category,
        'files': results,
        'failed_files': [r for r in results if not r.get('total_pass')],
    }

    with open(REPORT_PATH, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print(f'\n=== VALIDATE REPORT ===')
    print(f'Total: {len(m_files)} | Passed: {passed} | Failed: {failed} | Rate: {passed/len(m_files)*100:.1f}%')
    print(f'\nBy category:')
    for cat, stats in sorted(by_category.items()):
        print(f'  {cat}: {stats["passed"]}/{stats["total"]} passed')

    if failed > 0:
        print(f'\nFailed files ({failed}):')
        for r in report['failed_files']:
            fname = r['file']
            failed_items = r.get('failed_checks', [])
            print(f'  {fname}: {failed_items}')

    print(f'\nReport: {REPORT_PATH}')
    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
