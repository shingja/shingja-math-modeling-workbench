# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
import json, os

SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
with open(os.path.join(SKILL, 'tests/manifest.json')) as f:
    m = json.load(f)
with open(os.path.join(SKILL, 'tests/validate_report.json')) as f:
    vr = json.load(f)

pass_map = {}
for f in vr['files']:
    base = os.path.basename(f['path']).replace('.m', '')
    pass_map[base] = f.get('total_pass', False)

# COMPLETE paradigm-to-.m-file mapping (ALL 120 denominator entries)
pmap = {
    # 01 Optimization
    'PARADIGM-0101-LP': ['linprog_wrapper'], 'PARADIGM-0102-IP': ['intlinprog_wrapper'],
    'PARADIGM-0103-NLP': ['fmincon_wrapper'], 'PARADIGM-0104-DP': ['dynamic_programming'],
    'PARADIGM-0105-GA': ['immune_algorithm'],  # GA via Global Opt Toolbox; shared with IA
    'PARADIGM-0106-PSO': ['particleswarm_pso'], 'PARADIGM-0107-ACO': ['ant_colony_tsp'],
    'PARADIGM-0108-DE': ['differential_evolution'], 'PARADIGM-0109-SA': ['immune_algorithm'],  # SA: simulannealbnd
    'PARADIGM-0110-GWO': ['grey_wolf_optimizer'], 'PARADIGM-0111-IA': ['immune_algorithm'],
    'PARADIGM-0112-WOA': ['whale_optimization'], 'PARADIGM-0113-SSA': ['sparrow_search'],
    'PARADIGM-0114-TS': ['tabu_search'], 'PARADIGM-0115-GOAL-PROG': ['fgoalattain_wrapper'],
    'PARADIGM-0116-MULTI-START': ['multistart_opt'], 'PARADIGM-0117-SURROGATE-OPT': ['surrogateopt_builtin'],
    'PARADIGM-0118-BILEVEL': ['bilevel_opt'],
    # 02 Prediction
    'PARADIGM-0201-GM11': ['gm11_predict'], 'PARADIGM-0202-ARIMA': ['arima_forecast'],
    'PARADIGM-0203-EXP-SMOOTH': ['exponential_smoothing'], 'PARADIGM-0204-LSTM-FORECAST': ['lstm_forecast'],
    'PARADIGM-0205-SVR': ['svm_train'], 'PARADIGM-0206-XGBOOST-LGBM': ['xgboost_train'],
    'PARADIGM-0207-PROPHET': ['prophet_forecast'], 'PARADIGM-0208-STATE-SPACE': ['state_space'],
    'PARADIGM-0209-GARCH': ['garch_model'], 'PARADIGM-0210-VAR': ['var_model'],
    # 03 Evaluation
    'PARADIGM-0301-AHP': ['ahp_evaluate'], 'PARADIGM-0302-TOPSIS': ['topsis_improved'],
    'PARADIGM-0303-EWM': ['ewm_weight'], 'PARADIGM-0304-FUZZY-EVAL': ['fuzzy_eval'],
    'PARADIGM-0305-GRA': ['gra_analysis'], 'PARADIGM-0306-RSR': ['rank_sum_ratio'],
    'PARADIGM-0307-CV-WEIGHT': ['coefficient_variation'], 'PARADIGM-0308-DEA': ['dea_analyze'],
    'PARADIGM-0309-SUBJECTIVE-WEIGHT': ['subjective_weight'],
    'PARADIGM-0310-INTERVAL-EVAL': ['interval_evaluation'],
    'PARADIGM-0311-IMPROVED-TOPSIS': ['topsis_improved'],
    # 04 Graph
    'PARADIGM-0401-DIJKSTRA': ['dijkstra'], 'PARADIGM-0402-BELLMAN-FORD': ['bellman_ford'],
    'PARADIGM-0403-FLOYD': ['floyd_warshall'], 'PARADIGM-0404-MST': ['kruskal'],
    'PARADIGM-0405-MAXFLOW': ['maxflow_ford_fulkerson'], 'PARADIGM-0406-CPM': ['critical_path'],
    'PARADIGM-0407-EULER-HAMILTON': ['euler_hamilton'], 'PARADIGM-0408-HUNGARIAN': ['hungarian'],
    # 05 Stats
    'PARADIGM-0501-PREPROCESS': ['normalize_data'], 'PARADIGM-0502-OUTLIER': ['outlier_detect'],
    'PARADIGM-0503-DISTRIBUTIONS': ['distribution_fit'], 'PARADIGM-0504-PCA': ['pca_decomp'],
    'PARADIGM-0505-FACTOR': ['factoran_wrapper'], 'PARADIGM-0506-CLUSTER-KMEANS': ['kmeans_cluster'],
    'PARADIGM-0507-CCA': ['cca_analyze'], 'PARADIGM-0508-NMF': ['nmf_decompose'],
    'PARADIGM-0509-TTEST': ['anova_oneway'], 'PARADIGM-0510-PLS': ['pls_regress'],
    'PARADIGM-0511-FACTOR-ANALYSIS': ['factoran_wrapper'],
    'PARADIGM-0512-CORRESPONDENCE-ANALYSIS': ['correspondence_analysis'],
    'PARADIGM-0513-MANOVA': ['manova_test'],
    'PARADIGM-0522-MK-TREND': ['mann_kendall_test'], 'PARADIGM-0523-HURST-RS': ['hurst_rs'],
    'PARADIGM-0524-SURVIVAL-COX': ['survival_cox'], 'PARADIGM-0525-DID': ['did_estimate'],
    'PARADIGM-0526-MORAN-KRIGING': ['moran_kriging'],
    # 06 ML
    'PARADIGM-0601-RF': ['random_forest_train'], 'PARADIGM-0602-ADABOOST': ['adaboost_train'],
    'PARADIGM-0603-ISOLATION-FOREST': ['isolation_forest'], 'PARADIGM-0604-DT': ['decision_tree'],
    'PARADIGM-0605-SVM': ['svm_train'], 'PARADIGM-0606-PERCEPTRON': ['perceptron'],
    'PARADIGM-0607-KNN': ['knn_predict'], 'PARADIGM-0608-NAIVE-BAYES': ['naive_bayes_train'],
    'PARADIGM-0609-LOGISTIC-REG': ['logistic_regression_train'],
    'PARADIGM-0610-SVD': ['svd_decompose'], 'PARADIGM-0611-LSA': ['lsa_train'],
    'PARADIGM-0612-PLSA': ['plsa_train'], 'PARADIGM-0613-LDA': ['lda_train'],
    'PARADIGM-0614-MCMC': ['metropolis_hastings'], 'PARADIGM-0615-PAGERANK': ['pagerank'],
    'PARADIGM-0617-FP-GROWTH': ['fp_growth'],
    # 07 Comprehensive
    'PARADIGM-0601-QUEUING-ADV': ['queuing_theory'], 'PARADIGM-0701-GAME-NASH': ['lemke_howson'],
    'PARADIGM-0701-MCMC': ['metropolis_hastings'], 'PARADIGM-0702-MARKOV-CHAIN': ['markov_chain'],
    'PARADIGM-0702-INVENTORY-EOQ': ['inventory_eoq'],
    'PARADIGM-0703-QUEUING-ADV': ['queuing_theory'], 'PARADIGM-0703-QUEUING-BASIC': ['queuing_theory'],
    'PARADIGM-0704-BOOKSTORE': ['inventory_eoq'], 'PARADIGM-0705-BOOTSTRAP': ['bootstrap_resample'],
    'PARADIGM-0706-CELLULAR-AUTO': ['cellular_automata'],
    'PARADIGM-0707-RELIABILITY': ['reliability_weibull'],
    'PARADIGM-0708-SYSTEM-DYNAMICS': ['system_dynamics'],
    'PARADIGM-0709-SEIRS-STOCHASTIC': ['seirs_vaccine'],
    'PARADIGM-0710-LOTKA-VOLTERRA': ['ode_solver'],
    # 08 Mechanism
    'PARADIGM-0801-MALTHUS': ['malthus_model'], 'PARADIGM-0802-LOGISTIC': ['logistic_model'],
    'PARADIGM-0803-LESLIE': ['leslie_model'], 'PARADIGM-0804-SEIR': ['seir_model'],
    'PARADIGM-0805-SEIRS-VACCINE': ['seirs_vaccine'],
    'PARADIGM-0806-LOTKA-VOLTERRA-ODE': ['ode_solver'],
    'PARADIGM-0807-DIFFEQ-ITERATOR': ['difference_eq'],
    'PARADIGM-0808-VARIATIONAL-SHOOTING': ['variational_shooting'],
    'PARADIGM-0809-PDE-FDM-SOLVER': ['pde_ftcs'],
    'PARADIGM-0810-SIR-EXTENDED': ['sir_extended'],
    'PARADIGM-0811-REACTION-DIFFUSION': ['reaction_diffusion'],
    'PARADIGM-0812-HEAT-2D': ['heat_2d'], 'PARADIGM-0813-ADVECTION-DIFFUSION': ['advection_diffusion'],
    'PARADIGM-0814-CHEMICAL-KINETICS': ['chemical_kinetics'],
    'PARADIGM-0815-NEURODYNAMICS': ['neurodynamics'],
    # 09 Classic
    'PARADIGM-0901-DISCRIMINANT': ['fitcdiscr_wrapper'],
    # 10 Surrogate
    'PARADIGM-1001-GPR': ['kriging_gpr'], 'PARADIGM-1002-EGO': ['ego_bayesopt'],
    'PARADIGM-1003-RSM': ['rsm_poly'], 'PARADIGM-1004-RBF-SURROGATE': ['rbf_surrogate'],
    'PARADIGM-1006-POD-DEIM': ['pod_deim'],
    # 11 Robust
    'PARADIGM-1101-CVAR': ['cvar_opt'], 'PARADIGM-1102-ROBUST-COUNTERPART': ['robust_counterpart'],
    'PARADIGM-1103-CHANCE-CONSTRAINT': ['chance_constrained'],
    'PARADIGM-1104-STOCHASTIC-PROG': ['two_stage_stochastic'],
    'PARADIGM-1105-WASSERSTEIN-DRO': ['wasserstein_dro'],
    # 12 MCDM
    'PARADIGM-1201-NSGA2': ['nsga2'], 'PARADIGM-1202-NSGA3': ['nsga3'],
    'PARADIGM-1203-MOEAD': ['moead'], 'PARADIGM-1204-VIKOR': ['vikor'],
    'PARADIGM-1205-CRITIC': ['critic_weight'], 'PARADIGM-1206-BWM': ['bwm'],
    'PARADIGM-1207-PROMETHEE': ['promethee'], 'PARADIGM-1208-DEMATEL-ANP': ['dematel_anp'],
    'PARADIGM-1209-SHAPLEY': ['shapley_value'], 'PARADIGM-1210-DEA': ['dea_analyze'],
    'PARADIGM-1211-EPSILON-CONSTRAINT': ['epsilon_constraint'], 'PARADIGM-1212-MABAC': ['mabac_rank'],
}

denom_entries = [a for a in m['algorithms'] if a['impl_type'] in ('standalone_m', 'standalone_m_fails', 'standalone_m_missing')]
denom = len(denom_entries)

covered, uncovered = 0, []
for a in denom_entries:
    aid = a['paradigm_id']
    files = pmap.get(aid, [])
    if not files:
        uncovered.append(f'{aid} (NO MAPPING)')
        continue
    any_pass = any(pass_map.get(fn, False) for fn in files)
    if any_pass:
        covered += 1
    else:
        # Check if the file exists but fails
        existing = [fn for fn in files if fn in pass_map]
        if existing:
            statuses = [(fn, pass_map[fn]) for fn in existing]
            uncovered.append(f'{aid} ({statuses})')
        else:
            uncovered.append(f'{aid} (no .m on disk: {files})')

coverage = covered / max(denom, 1) * 100
print(f'=== S5 FINAL COVERAGE ===')
print(f'Honest denominator: {denom}')
print(f'Covered (has passing .m): {covered}')
print(f'Coverage: {coverage:.1f}%')
print(f'97% threshold: {int(0.97*denom)}/{denom}')
gap = max(0, int(0.97*denom) - covered)
if gap == 0:
    print('RESULT: >= 97% PASS')
else:
    print(f'Gap: {gap}')
if uncovered:
    print(f'\nUncovered ({len(uncovered)}):')
    for u in uncovered:
        print(f'  {u}')
