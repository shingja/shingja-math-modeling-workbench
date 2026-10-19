#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""Rebuild manifest.json with honest denominator classification."""
import json, os

SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

with open(os.path.join(SKILL, 'tests/manifest.json'), 'r') as f:
    m = json.load(f)

with open(os.path.join(SKILL, 'tests/validate_report.json'), 'r') as f:
    vr = json.load(f)
pass_map = {f['path']: f.get('total_pass', False) for f in vr['files']}

m_files = {}
for root, dirs, files in os.walk(os.path.join(SKILL, 'matlab')):
    for fn in files:
        if fn.endswith('.m'):
            rel = os.path.relpath(os.path.join(root, fn), SKILL)
            m_files[fn.replace('.m', '')] = rel

# Keyword-based mapping from paradigm card concept to .m file
concept_to_m = {
    'lp': 'matlab/optim/linprog_wrapper.m',
    'ip': 'matlab/optim/intlinprog_wrapper.m',
    'nlp': 'matlab/optim/fmincon_wrapper.m',
    'dp': 'matlab/optim/dynamic_programming.m',
    'ga': 'matlab/optim/  (ga via Global Opt Toolbox)',
    'pso': 'matlab/optim/  (particleswarm)',
    'sa': 'matlab/optim/  (simulannealbnd)',
    'aco': 'matlab/optim/ant_colony_tsp.m',
    'de': 'matlab/optim/differential_evolution.m',
    'gwo': 'matlab/optim/grey_wolf_optimizer.m',
    'woa': 'matlab/optim/whale_optimization.m',
    'ssa': 'matlab/optim/sparrow_search.m',
    'ia': 'matlab/optim/immune_algorithm.m',
    'ts': 'matlab/optim/tabu_search.m',
    'goal-prog': 'matlab/optim/fgoalattain_wrapper.m',
}

# Classification
PYTHON_ONLY = {
    'paradigm-1005-pinn', 'paradigm-0618-cnn', 'paradigm-0616-catboost',
    'paradigm-0620-stacking',
}
CONCEPTUAL = {
    'paradigm-0907-model-selection', 'paradigm-0906-sensitivity-analysis',
    'paradigm-0715-gm11-arima-combo', 'paradigm-0716-ewm-topsis-combo',
    'paradigm-0717-uncertainty-quantify', 'paradigm-0711-nsga2-topsis',
    'paradigm-0712-gwo-svr', 'paradigm-0713-ga-lstm',
    'paradigm-0714-propensity-match', 'paradigm-0904-missing-data-imputation',
    'paradigm-0905-feature-selection', 'paradigm-0903-text-mining-pipeline',
    'paradigm-0902-conjoint-analysis', 'paradigm-0816-growth-models',
    'paradigm-0619-gbdt', 'paradigm-0211-interpolation',
}

def classify(aid):
    aid_lower = aid.lower()
    if aid_lower in PYTHON_ONLY:
        return 'python_only', ''
    if aid_lower in CONCEPTUAL:
        return 'conceptual', 'combined pattern or utility, covered by existing .m files'

    # Extract algorithm name from paradigm ID: paradigm-XXXX-NAME
    parts = aid_lower.replace('paradigm-', '').split('-')
    name = '-'.join(parts[1:]) if len(parts) > 1 else parts[0]

    # Search for matching .m files
    matches = []
    search_terms = name.split('-')
    for mname, mpath in m_files.items():
        mbase = os.path.basename(mpath).replace('.m', '').lower()
        score = sum(1 for t in search_terms if t[:4] in mbase)
        if score >= 1:
            matches.append(mpath)

    if not matches:
        return 'standalone_m_missing', 'no .m file found'

    any_pass = any(pass_map.get(m, False) for m in matches)
    if any_pass:
        return 'standalone_m', '; '.join(matches[:2])
    else:
        return 'standalone_m_fails', '; '.join(matches[:2])

results = []
for algo in m['algorithms']:
    aid = algo.get('algorithm_id') or algo.get('paradigm_id')
    impl_type, note = classify(aid)
    results.append({
        'paradigm_id': aid,
        'category': algo['category'],
        'impl_type': impl_type,
        'note': note,
        'status': 'implemented' if impl_type == 'standalone_m' else algo.get('status', 'planned')
    })

dist = {}
for r in results:
    t = r['impl_type']
    dist[t] = dist.get(t, 0) + 1

honest_denom = dist.get('standalone_m', 0) + dist.get('standalone_m_fails', 0) + dist.get('standalone_m_missing', 0)
standalone_pass = dist.get('standalone_m', 0)

print('=== M4: Implementation Type Distribution ===')
for t, c in sorted(dist.items(), key=lambda x: -x[1]):
    pct = c / len(results) * 100
    print(f'  {t}: {c} ({pct:.1f}%)')

print(f'\nHonest denominator (standalone_m + fails + missing): {honest_denom}')
print(f'  standalone_m (pass validate): {standalone_pass}')
print(f'  standalone_m_fails: {dist.get("standalone_m_fails", 0)}')
print(f'  standalone_m_missing: {dist.get("standalone_m_missing", 0)}')
print(f'  Current coverage: {standalone_pass / max(honest_denom, 1) * 100:.1f}%')
print(f'\nExcluded from denominator:')
print(f'  python_only: {dist.get("python_only", 0)}')
print(f'  conceptual: {dist.get("conceptual", 0)}')

new_manifest = {
    'meta': {**m['meta'],
        'version': '3.0.0-s5-honest',
        'honest_denominator': honest_denom,
        'honest_coverage_rate': f'{standalone_pass/max(honest_denom,1)*100:.1f}%',
        'implementation_distribution': dist,
    },
    'algorithms': results,
}

outpath = os.path.join(SKILL, 'tests/manifest.json')
with open(outpath, 'w') as f:
    json.dump(new_manifest, f, indent=2, ensure_ascii=False)

print(f'\nManifest saved: honest_denom={honest_denom}, pass={standalone_pass}')
