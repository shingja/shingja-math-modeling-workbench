# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
import json, os, sys

SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
with open(os.path.join(SKILL, 'tests/manifest.json')) as f:
    m = json.load(f)

m_files = set()
for root, dirs, files in os.walk(os.path.join(SKILL, 'matlab')):
    for fn in files:
        if fn.endswith('.m'):
            m_files.add(fn.replace('.m', ''))

paradigm_to_mfile = {
    'PARADIGM-0101-LP': ('EXISTS', 'linprog_wrapper.m'),
    'PARADIGM-0102-IP': ('EXISTS', 'intlinprog_wrapper.m'),
    'PARADIGM-0103-NLP': ('EXISTS', 'fmincon_wrapper.m'),
    'PARADIGM-0104-DP': ('EXISTS', 'dynamic_programming.m'),
    'PARADIGM-0106-PSO': ('BUILTIN', 'particleswarm (Global Opt Toolbox)'),
    'PARADIGM-0107-ACO': ('EXISTS', 'ant_colony_tsp.m'),
    'PARADIGM-0110-GWO': ('EXISTS', 'grey_wolf_optimizer.m'),
    'PARADIGM-0112-WOA': ('EXISTS', 'whale_optimization.m'),
    'PARADIGM-0113-SSA': ('EXISTS', 'sparrow_search.m'),
    'PARADIGM-0116-MULTI-START': ('BUILTIN', 'MultiStart/GlobalSearch'),
    'PARADIGM-0118-BILEVEL': ('NEW', 'bilevel_opt.m (mid)'),
    'PARADIGM-0201-GM11': ('NEW', 'gm11_predict.m (mid)'),
    'PARADIGM-0202-ARIMA': ('NEW', 'arima_forecast.m (mid)'),
    'PARADIGM-0205-SVR': ('SHARED', 'svm_train.m (regression mode)'),
    'PARADIGM-0207-PROPHET': ('NEW', 'prophet_forecast.m (mid)'),
    'PARADIGM-0208-STATE-SPACE': ('NEW', 'state_space_model.m (mid)'),
    'PARADIGM-0209-GARCH': ('NEW', 'garch_model.m (mid)'),
    'PARADIGM-0301-AHP': ('NEW', 'ahp_evaluate.m (low)'),
    'PARADIGM-0303-EWM': ('NEW', 'ewm_weight.m (low)'),
    'PARADIGM-0306-RSR': ('EXISTS', 'rank_sum_ratio.m'),
    'PARADIGM-0309-SUBJECTIVE-WEIGHT': ('NEW', 'subjective_weight.m (low)'),
    'PARADIGM-0404-MST': ('SHARED', 'kruskal.m + dijkstra.m (prim mode)'),
    'PARADIGM-0406-CPM': ('EXISTS', 'critical_path.m'),
    'PARADIGM-0501-PREPROCESS': ('SHARED', 'normalize_data.m + fill_missing.m'),
    'PARADIGM-0502-OUTLIER': ('NEW', 'outlier_detect.m (low)'),
    'PARADIGM-0503-DISTRIBUTIONS': ('NEW', 'distribution_fit.m (low)'),
    'PARADIGM-0509-TTEST': ('SHARED', 'anova_oneway.m (ttest/ttest2 built-in)'),
    'PARADIGM-0513-MANOVA': ('NEW', 'manova_test.m (mid)'),
    'PARADIGM-0524-SURVIVAL-COX': ('NEW', 'survival_cox.m (mid)'),
    'PARADIGM-0525-DID': ('NEW', 'did_estimate.m (mid)'),
    'PARADIGM-0601-RF': ('SHARED', 'random_forest_train.m'),
    'PARADIGM-0602-ADABOOST': ('NEW', 'adaboost_train.m (mid)'),
    'PARADIGM-0604-DT': ('NEW', 'decision_tree.m (low)'),
    'PARADIGM-0614-MCMC': ('SHARED', 'metropolis_hastings.m + gibbs_sampler.m'),
    'PARADIGM-0617-FP-GROWTH': ('NEW', 'fp_growth.m (mid)'),
    'PARADIGM-0701-GAME-NASH': ('SHARED', 'lemke_howson.m'),
    'PARADIGM-0701-MCMC': ('SHARED', 'metropolis_hastings.m (mcmc mode)'),
    'PARADIGM-0702-MARKOV-CHAIN': ('NEW', 'markov_chain.m (low)'),
    'PARADIGM-0704-BOOKSTORE': ('SHARED', 'inventory_eoq.m (bookstore mode)'),
    'PARADIGM-0705-BOOTSTRAP': ('NEW', 'bootstrap_resample.m (low)'),
    'PARADIGM-0710-LOTKA-VOLTERRA': ('SHARED', 'ode_solver.m (lotka_volterra mode)'),
    'PARADIGM-0804-SEIR': ('NEW', 'seir_model.m (low)'),
    'PARADIGM-0805-SEIRS-VACCINE': ('NEW', 'seirs_vaccine.m (mid)'),
    'PARADIGM-0810-SIR-EXTENDED': ('NEW', 'sir_extended.m (mid)'),
    'PARADIGM-0812-HEAT-2D': ('NEW', 'heat_2d.m (mid)'),
    'PARADIGM-0814-CHEMICAL-KINETICS': ('NEW', 'chemical_kinetics.m (mid)'),
    'PARADIGM-0815-NEURODYNAMICS': ('NEW', 'neurodynamics.m (mid)'),
    'PARADIGM-1206-BWM': ('EXISTS', 'bwm.m (in mcdm/)'),
    'PARADIGM-1212-MABAC': ('NEW', 'mabac_rank.m (low)'),
}

missing = [a for a in m['algorithms'] if a['impl_type'] == 'standalone_m_missing']

print('Category | Diff | Status  | Paradigm ID')
print('-' * 75)
truly_new, shared, builtin = 0, 0, 0
for a in missing:
    aid = a['paradigm_id']
    cat = a.get('category', '??')
    map_info = paradigm_to_mfile.get(aid, ('CHECK', 'UNKNOWN'))
    status, note = map_info
    if 'NEW' in status: truly_new += 1
    elif status in ('SHARED','EXISTS'): shared += 1
    elif status == 'BUILTIN': builtin += 1

    diff = 'mid' if '(mid)' in note else ('low' if '(low)' in note else '?')
    print(f'{cat:<9} {diff:<5} {status:<8} {aid:<35}')

print(f'\nTruly new: {truly_new}')
print(f'Shared/Exists: {shared}')
print(f'Built-in: {builtin}')
print(f'Total: {truly_new + shared + builtin}')
# 
