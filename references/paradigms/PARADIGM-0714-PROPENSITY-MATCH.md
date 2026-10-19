# PARADIGM-0714 倾向得分匹配PSM⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0714 |
| 类别/子类 | ⑦综合 / 因果推断 |
| 难度 | 中 |
| 适用题型关键词[] | PSM, 倾向得分匹配, 因果推断, 处理效应, 反事实, fitglm, 政策评估, 选择偏差 |
| confidence | high |
| source | Rosenbaum & Rubin (1983) Biometrika |

## 数学形式

**倾向得分 (Propensity Score):**
$$e(\mathbf{x}) = P(T=1 \mid \mathbf{x})$$

其中 $T \in \{0,1\}$ 为处理指示符。

**核心定理 (Rosenbaum & Rubin, 1983):**
若强可忽略性 (Strong Ignorability) 成立:
$$(Y(0), Y(1)) \perp T \mid \mathbf{x} \implies (Y(0), Y(1)) \perp T \mid e(\mathbf{x})$$

即给定倾向得分，处理分配与潜在结果独立。

**ATT (平均处理效应 on the Treated):**
$$ATT = E[Y(1) - Y(0) \mid T=1]$$
$$= E_{e(\mathbf{x})}\left[E[Y \mid T=1, e(\mathbf{x})] - E[Y \mid T=0, e(\mathbf{x})] \mid T=1\right]$$

**步骤:**
1. **估计倾向得分:** 逻辑回归 $e(\mathbf{x}) = \sigma(\beta_0 + \beta^T\mathbf{x})$
2. **匹配:** Nearest Neighbor / Caliper / Kernel / Stratification
3. **平衡诊断:** 标准化差异 (Standardized Difference)
   $$d = \frac{\bar{x}_{\text{treat}} - \bar{x}_{\text{control}}}{\sqrt{(s_{\text{treat}}^2 + s_{\text{control}}^2)/2}}$$
   若 $|d| < 0.1$ 对所有协变量 → 平衡好

4. **估计 ATT:** $\widehat{ATT} = \frac{1}{N_1}\sum_{i:T_i=1} (Y_i - \hat{Y}_i(0))$

**Caliper 匹配 (避免差匹配):**
$$|e(\mathbf{x}_i) - e(\mathbf{x}_j)| \leq 0.2 \cdot \hat{\sigma}_e$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| caliper | double | 0.2 | [0.01, 0.5] | 高 — 太宽差匹配，太窄样本丢失 |
| n_matches | int | 1 | [1, 5] | 中 — 方差-偏差权衡 |
| matching_method | str | 'nn' | 'nn','caliper','kernel','stratification' | 中 |
| 倾向得分模型 | — | 逻辑回归 | 可用 GBM/RF | 高 — 模型错误指定导致偏差 |

## MATLAB 实现

函数签名 (自写):
```matlab
[att, matched_data, balance_table, att_se] = psm(X, T, Y, ...
    caliper, n_matches, method)
% X: n×p 协变量
% T: n×1 处理指示符 (0/1)
% Y: n×1 结果变量
```

锚点: `fitglm` + 自写匹配-见S5:psm.m

```matlab
% 步骤1: 估计倾向得分
ps_model = fitglm(X, T, 'Distribution', 'binomial', 'Link', 'logit');
e = predict(ps_model, X);  % 倾向得分

% 步骤2: Nearest Neighbor Matching (有放回)
idx_treat = find(T == 1);
idx_control = find(T == 0);
matched_control = zeros(size(idx_treat));
for i = 1:length(idx_treat)
    diff = abs(e(idx_control) - e(idx_treat(i)));
    within_caliper = diff <= caliper * std(e);
    if any(within_caliper)
        [~, best] = min(diff);
        matched_control(i) = idx_control(best);
        idx_control(best) = [];  % 无放回 (optional)
    end
end

% 步骤3: ATT
att = mean(Y(idx_treat)) - mean(Y(matched_control));

% 步骤4: Bootstrap SE
boot_att = bootstrp(1000, @(x) psm_att(X(x,:),T(x,:),Y(x,:),caliper), 1:n);
att_se = std(boot_att);
```

## Python 备选

```python
# psmpy
from psmpy import PsmPy
psm = PsmPy(df, treatment='T', indx='id', exclude=[])
psm.logistic_ps(balance=True)
psm.knn_matched(matcher='propensity_logit', caliper=0.2, replacement=False)
psm.effect_size_plot()

# causalinference
from causalinference import CausalModel
cm = CausalModel(Y, T, X)
cm.est_propensity_s()
cm.stratify_s()
cm.est_via_matching(weights='maha')
print(cm.estimates)
```

## 选型决策树

- **PSM** — 观测研究(非实验)，需要控制选择偏差，T 是二值处理
- **DID (PARADIGM-0525)** — 有前后两期的面板数据，利用时间差异消除固定效应
- **IV (工具变量)** — 存在未观测混杂因素 (unobserved confounders)，需要用工具变量
- **RDD (断点回归)** — 处理基于连续变量的阈值 (如分数>=60 录取)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | 匹配前后协变量标准化差异图 (Love Plot) | 展示平衡改善 |
| process | 倾向得分分布 (处理组 vs 对照组直方图) | 检查共支撑区域 |
| result | ATT + 95% CI 森林图 | 处理效应估计 |

## 常见坑

1. **共支撑区域 (Common Support) 不足**: 处理组倾向得分区间与对照组无重叠 → 很多样本无法匹配 → 报告匹配率
2. **隐藏混杂 (Unobserved Confounding)**: PSM 只能消除可观测的混杂，未观测的混杂导致 ATT 仍有偏 (偏差量不可知)
3. **匹配后不检查平衡**: 很多论文只做 PSM 不检查标准化差异 → 必须展示 Love Plot

## 失效条件/反例 (强制小节)

- **条件1: 未观测混杂因素 (Hidden Confounders) 存在** → 表现: 即使匹配后协变量平衡完美 (|d|<0.1)，ATT 仍可能严重有偏 — PSM 假设强可忽略性 (所有混杂因素可观测)，违反时 ATT 毫无保证。**应对**: 做 Rosenbaum Bounds 敏感性分析评估隐藏偏差的影响；或改用 IV/RDD 等不依赖此假设的方法
- **条件2: 样本量极小 (处理组 n_treat < 30)** → 表现: 逻辑回归估计倾向得分在小样本下不稳定 (完全分离/准分离)，匹配质量差，caliper 内经常找不到匹配 — 大量样本丢弃，ATT 估计方差极大且 CI 宽到无推断价值。**应对**: 使用精确匹配 (Exact Matching) 或粗化精确匹配 (CEM)，不依赖倾向得分模型

## 文献

1. Rosenbaum P.R. & Rubin D.B. (1983). "The central role of the propensity score in observational studies for causal effects." *Biometrika*, 70(1):41-55. DOI: [10.1093/biomet/70.1.41](https://doi.org/10.1093/biomet/70.1.41)
2. Imbens G.W. & Rubin D.B. (2015). *Causal Inference for Statistics, Social, and Biomedical Sciences*. Cambridge University Press. ISBN: 978-0521885881

## 来源溯源

fitglm + 自写匹配 psm.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0525 (DID, 双重差分) |
| 前置 | PARADIGM-0609 (逻辑回归) |
| 组合 | PARADIGM-0705 (Bootstrap) |
