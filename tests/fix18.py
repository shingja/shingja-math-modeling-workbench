# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
import json, os

SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
with open(os.path.join(SKILL, 'tests/validate_report.json')) as f:
    vr = json.load(f)

targets = ['rank_sum_ratio', 'dea_analyze', 'interval_evaluation', 'maxflow_ford_fulkerson',
          'euler_hamilton', 'distribution_fit', 'cca_analyze', 'pls_regress',
          'factoran_wrapper', 'isolation_forest', 'perceptron', 'knn_predict',
          'naive_bayes_train', 'cellular_automata', 'bwm', 'coefficient_variation',
          'outlier_detect', 'ahp_evaluate']

for fn in targets:
    found = False
    for f in vr['files']:
        if fn in f['file'].lower():
            fail = f.get('failed_checks', [])
            logic = f.get('v4_logic_lines', 0)
            print(f'{f["file"]:35s} fail={fail} logic={logic}')
            found = True
            break
    if not found:
        print(f'{fn:35s} NOT FOUND')
# 
