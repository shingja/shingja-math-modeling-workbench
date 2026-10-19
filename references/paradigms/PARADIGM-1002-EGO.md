# PARADIGM-1002-EGO EGO/贝叶斯优化: Expected Improvement⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1002-EGO |
| 类别/子类 | ⑩代理模型 / 序贯优化 |
| 难度 | 高 |
| 适用题型关键词[] | 黑箱优化, 昂贵评估, 自适应采样, 全局优化, 超参数调优 |
| confidence | high |
| source | 论文1998_EGO / 题解反推_BlackboxOpt类 |

## 数学形式

**EGO (Efficient Global Optimization)** = GPR 代理 + Expected Improvement 采集函数 + 序贯采样。

**Expected Improvement (EI)**:
$$EI(\mathbf{x}) = \mathbb{E}[\max(0, f_{\min} - f(\mathbf{x}))]$$
$$= (f_{\min} - \mu(\mathbf{x})) \Phi\left(\frac{f_{\min} - \mu(\mathbf{x})}{\sigma(\mathbf{x})}\right) + \sigma(\mathbf{x}) \phi\left(\frac{f_{\min} - \mu(\mathbf{x})}{\sigma(\mathbf{x})}\right)$$
其中 $f_{\min} = \min_{i} f(\mathbf{x}_i)$ 为当前最佳值, $\mu(\mathbf{x}), \sigma(\mathbf{x})$ 为 GPR 预测均值和标准差, $\Phi$/$\phi$ 为标准正态 CDF/PDF

**EGO 算法循环**:
1. 生成初始 DOE (Latin Hypercube 采样)
2. 评估初始样本 $\rightarrow$ 构建 GPR 代理
3. 最大化 EI 采集函数 $\rightarrow$ 获得下一采样点 $\mathbf{x}_{\text{next}}$
4. 评估 $f(\mathbf{x}_{\text{next}})$, 更新代理和 $f_{\min}$
5. 重复直到预算耗尽 或 EI $\max < \epsilon$

| 变量 | 含义 |
|------|------|
| $\mu(\mathbf{x})$ | GPR 预测均值 |
| $\sigma(\mathbf{x})$ | GPR 预测标准差 |
| $f_{\min}$ | 当前已观测最优值 |
| $EI(\mathbf{x})$ | 期望改进—平衡探索 ($\sigma$ 大) 和利用 ($\mu$ 小) |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 初始 DOE 样本数 | int | $10d$ | $5d-20d$ | 高—太少不足以建模, 太多浪费预算 |
| 总评估预算 | int | $100d$ | $50d-500d$ | 高—EGO 的效用上限 |
| GPR 核函数 | enum | Matern52 | SE/M32/M52 | 中 |
| 采集函数 | enum | EI | EI/LCB/PI | 中—EI 最优默认 |
| EI 最大化方法 | enum | 多起点 L-BFGS | GA/DIRECT/L-BFGS | 中—多起点防止局部最优 |

**每迭代复杂度**: $O(n_{\text{eval}}^3)$ (GPR更新) + 最大化 EI 的 $O(K \cdot n_{\text{eval}} \cdot d)$

## MATLAB 实现

```matlab
% 内置贝叶斯优化 (Statistics and Machine Learning Toolbox)
X_initial = lhsdesign(n_init, d);
y_initial = arrayfun(@(i) objective_func(X_initial(i,:)), 1:n_init)';

results = bayesopt(@(x) objective_func(x), d, ...
    'XConstraintFcn', [], ...
    'MaxObjectiveEvaluations', budget, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'PlotFcn', {@plotMinObjective, @plotAcquisitionFunction});

% 自写 EI 采集函数 (用于与研究对比或定制)
% 自写EI-见S5:ego_optimize.m
```

**锚点工具箱**: `bayesopt` (Statistics and Machine Learning Toolbox, v2016b+)
**备选**: 自写 EGO 主循环 (需结合 `fitrgp` + `fmincon` 最大化 EI)

## Python 备选

```python
from skopt import gp_minimize
from skopt.space import Real
import numpy as np

space = [Real(lb, ub) for lb, ub in zip(lower_bounds, upper_bounds)]
result = gp_minimize(
    objective_func, space, n_calls=100,
    acq_func="EI", n_random_starts=10, random_state=42
)
# result.x: 最优解, result.fun: 最优值
```

备选: `BoTorch` (PyTorch, 并行/多目标/约束), `Hyperopt`, `Optuna`

## 选型决策树

- **黑箱 + 评估昂贵 (单次 > 1min) + 预算有限** → EGO (最优采样策略)
- **评估便宜 (毫秒级) + 多局部最优** → 直接全局优化 (GA/PSO/SA), 代理模型开销无意义
- **离散/组合域** → BayesOpt 需要自定义核函数, 或换 SMAC/TPE
- **多目标** → ParEGO (标量化) 或 EGO + 多个采集函数
- **约束黑箱** → CEGO (约束 EI), `bayesopt` 内置 `XConstraintFcn`
- **并行评估** → q-EI (批量 EI)

## 典型图型

- **raw**: 初始 DOE 样本分布 + 目标值
- **process**: GPR 均值 + 置信带 + EI 采集函数 (1D多帧迭代), $f_{\min}$ 收敛曲线
- **result**: 最优解所在位置 (全变量散点图), 各变量对目标的主效应图 (扰动分析)

## 常见坑

1. **初始 DOE 不足**: GPR 超参数无法可靠估计, 代理不可信, EI 被误导 → $10d$ 起步
2. **EI 采集函数多局部模态**: L-BFGS 单起点陷入 EI 局部最优 → 多起点 + GA/PSO 最大化 EI
3. **EI Plus 过度探索 (MATLAB 默认)**: 加噪声探索项使收敛变慢 → 先关掉试 `expected-improvement`
4. **收敛过早停止**: EI 在真实最优附近趋于 0, 但并未到达 → 设置足够预算, 监控 \|f_min 变化\|
5. **核函数光滑性假设不成立**: 阶跃函数导致 GPR 无限震荡, EI 随机采样 → 换随机森林代理 (SMAC) 或 分段 GP

## 失效条件/反例 (强制小节)

- **条件1**: 目标函数评估极便宜 ($< 0.01$s/次) → GPR 建模 + EI 最大化开销 > 直接全局优化, EGO 反而拖慢。**替代**: GA/PSO/直接多起点 fmincon (PARADIGM-0301)
- **条件2**: 输入维数 $d > 20$ → GPR 在高维失效 (见 PARADIGM-1001 失效条件), EI 优化也在高维困难。**替代**: TuRBO (Trust Region BO), 或降维到 $d \leq 10$ 后用 EGO
- **条件3**: 目标函数有大量平台/多局部最优同等好 → EI 在平台区域近乎 0 (无改进空间), 探索停止, 但可能错失略微更好的区域。**替代**: 增加 exploration weight (LCB with large $\kappa$) 或用信息增益 (Entropy Search)
- **条件4**: 噪声水平 $\sigma_n$ 未知且大 → GPR 的 $\mu$ 和 $\sigma$ 均受噪声污染, EI 高估不确定性, 过度探索。**替代**: 用含噪声模型的 EGO (Noisy EI), 或复制测量降噪

## 文献

1. Jones, D. R., Schonlau, M., & Welch, W. J. (1998). Efficient global optimization of expensive black-box functions. *Journal of Global Optimization*, 13(4), 455-492. DOI: [10.1023/A:1008306431147](https://doi.org/10.1023/A:1008306431147)
2. Shahriari, B., Swersky, K., Wang, Z., Adams, R. P., & de Freitas, N. (2016). Taking the human out of the loop: A review of Bayesian optimization. *Proceedings of the IEEE*, 104(1), 148-175. DOI: [10.1109/JPROC.2015.2494218](https://doi.org/10.1109/JPROC.2015.2494218)

## 来源溯源

- 论文三元组: Jones 1998, EGO, expected improvement + DACE
- 开源仓库: [BoTorch](https://github.com/pytorch/botorch), [scikit-optimize](https://github.com/scikit-optimize/scikit-optimize)

## 关联范式卡

组合: PARADIGM-1001-GPR (核心代理)
替代: PARADIGM-0301-GA (便宜评估), PARADIGM-1004-RBF-SURROGATE + 直接搜索 (中等维度)
前置: PARADIGM-1001-GPR (理解 GPR)
