# PARADIGM-0525  因果推断 — 双重差分法 (DID)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0525 |
| 类别/子类 | ⑥机器学习 / 因果推断 |
| 难度 | 高 |
| 适用题型关键词[] | DID, 双重差分, 因果推断, 平行趋势, 处理效应, 政策评估, 准实验, 自然实验, 反事实, 面板数据, 政策效果, 干预评估 |
| confidence | medium |
| source | Angrist, J.D. & Pischke, J.S. (2009) *Mostly Harmless Econometrics: An Empiricist's Companion*, Princeton University Press; Ashenfelter, O. (1978) *Review of Economics and Statistics* |

## 数学形式

**双重差分 (Difference-in-Differences, DID) 基本形式**:

对于面板数据: 处理组 $T=1$ vs 对照组 $T=0$, 政策实施前 (Pre, $t=0$) vs 实施后 (Post, $t=1$):

$$\hat{\tau}_{DID} = (\bar{Y}_{T=1, t=1} - \bar{Y}_{T=1, t=0}) - (\bar{Y}_{T=0, t=1} - \bar{Y}_{T=0, t=0})$$

第一括号 = 处理组的前后变化 (含政策效应 + 时间趋势); 第二括号 = 对照组的前后变化 (仅含时间趋势); 两者之差 = 纯净的政策效应 (DID 估计量)。

**回归等价形式** (更灵活, 可加协变量):
$$Y_{it} = \alpha + \beta \cdot \text{Treat}_i + \gamma \cdot \text{Post}_t + \tau \cdot (\text{Treat}_i \times \text{Post}_t) + \varepsilon_{it}$$

其中:
- $\beta$: 处理组与对照组基线差异 (不随时间变化)
- $\gamma$: 两组共同的时间效应 (与分组无关)
- $\tau$: **DID 估计量 (处理效应 ATT) — 核心兴趣参数**

**含协变量的 DID**:
$$Y_{it} = \alpha + \beta \cdot \text{Treat}_i + \gamma \cdot \text{Post}_t + \tau \cdot (\text{Treat}_i \times \text{Post}_t) + \mathbf{X}_{it} \boldsymbol{\theta} + \varepsilon_{it}$$

加入协变量 $\mathbf{X}_{it}$ 可提高估计精度, 控制潜在混杂。

**含个体固定效应 + 时间固定效应的推广形式** (多期 DID):
$$Y_{it} = \alpha_i + \lambda_t + \tau \cdot D_{it} + \varepsilon_{it}$$

其中 $\alpha_i$ 为个体固定效应 (吸收 Treat), $\lambda_t$ 为时间固定效应 (吸收 Post), $D_{it}$ 为处理状态指示符 ($D_{it} = \text{Treat}_i \times \text{Post}_t$)。

**平行趋势假设 (Parallel Trends)** — DID 的核心识别条件:
$$E[Y_{it}(0) \mid \text{Treat}=1] - E[Y_{it}(0) \mid \text{Treat}=0] = \text{constant}, \quad \forall t$$

即: 在无干预的反事实世界中, 处理组和对照组的结果差异不随时间变化。等价表述: 如果处理组没有被处理, 其时间趋势与对照组相同。

**事件研究法 (Event Study) — 检验平行趋势**:
$$Y_{it} = \alpha_i + \lambda_t + \sum_{k=-m, k\neq -1}^{q} \mu_k \cdot \mathbf{1}\{t - t_i^* = k\} + \varepsilon_{it}$$

其中 $t_i^*$ 为个体 $i$ 的处理时间, $\mu_k$ 捕捉处理前 ($k<0$) 和处理后 ($k \geq 0$) 的每期效应。平行趋势要求: $\mu_k = 0$ for all $k < 0$ (处理前无差异)。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 时间窗 (pre/post) | integer | 2 periods | 2+ | 高 — 越长越须检验平行趋势先验 |
| 聚类标准误 | string | 'cluster' | cluster/robust/wild bootstrap | 高 — 不聚类则 p 值严重偏低 |
| 固定效应 | logical | true | true/false | 中 — 控制不随时间变化的混杂 |
| 协变量控制 | string[] | [] | 前定变量 | 中 — 改善精度但不宜加时变中介 |
| 处理前平行检验期数 | integer | 所有可用期 | 2+ | 高 — 共同支持平行趋势论证 |

- 复杂度: $O(n \cdot T \cdot p)$ (面板回归, 固定效应差分后 OLS)
- 数据要求: 每处理组 > 20 个单元 (聚类标准误最低要求), 总数 > 100 推荐
- 输入: 面板数据 (个体 $\times$ 时间), Treat (0/1), Post (0/1), Y (连续结果)
- 输出: $\hat{\tau}$ (ATT) + 聚类稳健 SE + p + 95% CI

## MATLAB 实现

```matlab
function [tau, se, p, ci] = did_estimate(Y, Treat, Post, varargin)
% DID_ESTIMATE  双重差分估计 (含平行趋势检验)
%   自写-见S5:did_estimate.m
%   Y: n×1 结果变量
%   Treat: n×1 处理组指示 (0/1)
%   Post: n×1 政策后指示 (0/1)
%   可选: 'covariates', X, 'cluster', id, 'fixed_effects', true
%   输出: tau (DID估计量), se (聚类稳健标准误), p, CI
%
%   Reference: Angrist & Pischke (2009) + Callaway & Sant'Anna (2021)
%   ID: PARADIGM-0525

    p_ = inputParser;
    addRequired(p_, 'Y', @isnumeric);
    addRequired(p_, 'Treat', @isnumeric);
    addRequired(p_, 'Post', @isnumeric);
    addParameter(p_, 'covariates', [], @isnumeric);
    addParameter(p_, 'cluster', [], @isnumeric);
    addParameter(p_, 'fixed_effects', false, @islogical);
    addParameter(p_, 'alpha', 0.05, @(v) v>0 && v<1);
    parse(p_, Y, Treat, Post, varargin{:});
    
    Y = Y(:); Treat = Treat(:); Post = Post(:);
    n = length(Y);
    
    % 交互项
    Treat_Post = Treat .* Post;
    
    % 设计矩阵
    if ~isempty(p_.Results.covariates)
        X_cov = p_.Results.covariates;
    else
        X_cov = [];
    end
    X = [ones(n,1), Treat, Post, Treat_Post, X_cov];
    
    % OLS 估计
    b = X \ Y;
    tau = b(4);  % Treat*Post 交互项系数 = DID 估计量
    
    % 残差
    residuals = Y - X * b;
    
    % 聚类稳健标准误
    if ~isempty(p_.Results.cluster)
        cluster_id = p_.Results.cluster;
        unique_clusters = unique(cluster_id);
        G = length(unique_clusters);
        
        % 聚类稳健协方差矩阵 (Arellano / Liang-Zeger)
        bread = (X' * X) / n;
        meat = zeros(size(X, 2));
        for g = 1:G
            idx = (cluster_id == unique_clusters(g));
            X_g = X(idx, :);
            e_g = residuals(idx);
            meat = meat + (X_g' * e_g) * (e_g' * X_g);
        end
        meat = meat * (G / (G-1)) / n;  % 小样本校正
        V_robust = (bread \ meat) / bread / n;
        se = sqrt(V_robust(4, 4));
    else
        % 默认异方差稳健标准误 (HC1)
        V = inv(X' * X) * (X' * diag(residuals.^2) * X) * inv(X' * X);
        V_hc1 = V * n / (n - size(X, 2));
        se = sqrt(V_hc1(4, 4));
    end
    
    % t 检验
    t_stat = tau / se;
    alpha = p_.Results.alpha;
    
    switch 2  % 默认双尾
        case 2
            p = 2 * (1 - tcdf(abs(t_stat), n - size(X, 2)));
            t_crit = tinv(1 - alpha/2, n - size(X, 2));
        case 1  % 单尾
            p = 1 - tcdf(t_stat, n - size(X, 2));
            t_crit = tinv(1 - alpha, n - size(X, 2));
    end
    ci = [tau - t_crit * se, tau + t_crit * se];
    
    % 输出
    fprintf('\n===== 双重差分 (DID) 估计 =====\n');
    fprintf('DID 估计量 (ATT) = %.6f\n', tau);
    fprintf('稳健标准误       = %.6f\n', se);
    fprintf('t 统计量         = %.4f\n', t_stat);
    fprintf('p 值             = %.6f\n', p);
    fprintf('95%% CI: [%.6f, %.6f]\n', ci(1), ci(2));
    if p < alpha
        fprintf('结论: 政策效应在 α=%.2f 水平下显著\n', alpha);
    else
        fprintf('结论: 政策效应在 α=%.2f 水平下不显著\n', alpha);
    end
end

% ===== 配套: 平行趋势事件研究 =====
% 假设有面板数据 panel_data (unit x time) 和处理时间点 policy_time
% 需手工构造 leads/lags 并做回归检验
% 
% 自写-见S5:event_study_parallel.m
% 核心: 回归 Y ~ unit_FE + time_FE + sum(mu_k * 1{t - t* = k})
%       检验 mu_{-1}, mu_{-2}, ... 是否联合为零
```

## Python 备选

```python
import pandas as pd
import statsmodels.api as sm
from linearmodels import PanelOLS

# 面板 DID (含固定效应)
data = data.set_index(['unit_id', 'time'])
did_model = PanelOLS.from_formula(
    'Y ~ Treat + Post + Treat*Post + EntityEffects + TimeEffects',
    data=data
)
results = did_model.fit(cov_type='clustered', cluster_entity=True)
print(results.summary)

# 简化回归 (无固定效应)
X = sm.add_constant(data[['Treat', 'Post', 'Treat_Post']])
model = sm.OLS(data['Y'], X).fit(
    cov_type='cluster', cov_kwds={'groups': data['unit_id']}
)
tau = model.params['Treat_Post']

# 交错DID (Callaway-Sant'Anna) - 推荐
# from did import DID  # csdid 包
# result = DID(data, 'Y', 'unit_id', 'time', 'treat_time')
# result.aggte()  # 汇总处理效应
```

备选: `csdid` (Callaway-Sant'Anna 交错 DID), `did` 包, `causaldata` (含 DID 示例数据集), `DoWhy` (统一因果框架)

## 选型决策树

```
政策/干预效果评估?
  ├─ 有处理组+对照组 + 前后时间数据 → DID
  │    ├─ 单一政策时间点 → 经典 DID (2×2)
  │    ├─ 多个政策时间点 (交错Staggered) → Callaway-Sant'Anna / Sun-Abraham 估计器
  │    └─ 加协变量 → DID + 回归调整 (改善精度)
  ├─ 横截面 (无前后对比) → PSM (倾向评分匹配) 或 工具变量 (IV)
  ├─ 仅一个处理单元 (无对照组) → 合成控制法 (SCM) 或 ITS (中断时间序列)
  ├─ 处理分配在阈值处 → 断点回归 (RDD)
  └─ 随机实验 (RCT) → 直接均值比较, DID 不必要
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 原始 | 均值时序图 (两组) | 处理组与对照组 Y 均值随时间变化的双线图, 政策时点虚线 |
| 核心 | 事件研究图 (Event Study) | 各期 $\mu_k$ 系数 + 95%CI 的森林图; 处理前 $\mu_k \approx 0$ |
| 检验 | 安慰剂时间点图 | 将政策时点前移, 重新做 DID; 若"假政策"时 $\tau$ 显著→平行趋势怀疑 |
| 检验 | 安慰剂处理组图 | 随机重分配 Treat, 观察 $\tau$ 的置换分布; 真实 $\tau$ 应落尾端 |
| 结果 | DID 估计表 (系数+SE+p+CI) | 表格形式报告基准模型、含协变量模型、稳健性检验 |
| 敏感性 | 不同时间窗的 $\hat{\tau}$ 图 | 展示结果对不同时间窗选择的稳健性 |

## 常见坑

1. **平行趋势假设不可检验 (只能检验处理前)**: 事件研究图仅能在处理前检验平行趋势; 处理后是否平行是反事实的, 永远不可观测。因此必须论证: (a) 处理前趋势确实平行; (b) 没有理由认为趋势在处理后会突然改变。
2. **交错政策时 TWFE DID 有偏 (负权重问题)**: 多个个体在不同时间点接受处理, 标准双向固定效应 (TWFE) 估计器对处理效应的加权平均包含负权重 — 即某些组的处理效应贡献为负, 可导致符号反转。新文献 (Callaway & Sant'Anna 2021, de Chaisemartin & D'Haultfoeuille 2020) 强烈建议使用新估计器。
3. **仅 2 个单元 (1 处理 + 1 控制)**: 聚类标准误的最小群组数 G=2, 此时聚类稳健 SE 的渐近理论不成立, 且估计对个别异常值极其敏感。合成控制法 (SCM) 更适合此场景。
4. **处理组选择内生**: 如果分组与潜在结果相关 (如政策选择性地在问题严重的地区实施), 平行趋势假设从根本上不成立。需考虑 PSM-DID (先用 Propensity Score 匹配再 DID), 或寻找工具变量。
5. **聚类层级错误**: 政策通常在群组级 (如省份) 实施, 但分析在个体级做回归 — 此时标准误必须聚类在政策实施层级 (province), 否则 SE 严重低估 (Moulton 问题)。聚类层级应等于处理分配层级。

## 失效条件/反例 (强制小节)

- **条件1 — 平行趋势假设不成立 → 处理组和控制组事前趋势已分歧, DID 估计有偏**: 事件研究图显示处理前 $\mu_{-2}, \mu_{-3}, \ldots$ 显著非零且呈趋势 — 处理组在政策前已经与对照组拉开了差距。若无政策, 这个差距会继续扩大, DID 将差异全部归因于政策, 导致有偏估计。例如: 若处理组的 Y 在政策前已经以每年 +2% 的速度高于对照组, 而政策实施后差值跃升为 +8%, 简单 DID 给出 ATT=6%, 但 +2% 是预先存在的趋势, 实际 ATT 仅为 4% (如果趋势线性延续)。解决方案: (1) 合成控制法 (SCM): 通过加权多个对照组构造与处理组政策前趋势最接近的合成对照; (2) 控制事前趋势: 在回归中加入组别特定的线性时间趋势项; (3) 若趋势仅弱偏离, 报告带趋势调整的 DID 作为稳健性检验。
- **条件2 — 存在同期其他政策干扰 → 处理效应混杂, 无法归因**: DID 假设除所研究政策外, 没有其他同期政策/冲击在处理组和对照组之间产生差异化影响。如果研究最低工资提升对就业的影响 (处理组: 州 A, 提升最低工资), 但同期州 A 还实施了税收优惠, 对照组州 B 无此政策 — 则 DID 估计量混杂了最低工资效应和税收优惠效应。类似地, 若有整体经济冲击对两组影响不同 (Ashenfelter's dip — 政策实施前处理组的结果出现暂时性下降, 均值回归而非政策效应), DID 同样偏倚。解决方案: (1) 详细梳理政策时间线, 确认无混杂; (2) 安慰剂检验: 在已知无政策的时间段做假 DID, 若仍显著则表明有未观察到的混杂; (3) 三重差分 (DDD): 加入另一个不受影响的维度做差分的差分。
- **条件3 — 样本选择偏差 → 处理组非随机分配, 处理效应不等于因果效应**: 如果是否接受处理 (Treat=1) 本身与潜在结果相关, 处理组和对照组的差异不仅仅是平行趋势问题 — 它们是根本不可比的。例如: 评估职业培训项目对收入的影响, 但参与者是自愿报名的 (高度自选择), 他们的动机和能力本身就与非参与者不同。即使事件研究图显示政策前收入趋势平行, 参与者的潜在收入增长路径仍然可能不同 (Ashenfelter's dip 现象: 参与者可能在项目前经历了收入下降, 培训后的回升是均值回归)。解决方案: (1) PSM-DID: 先基于可观测特征做倾向评分匹配, 匹配合适的控制组, 再对匹配样本做 DID; (2) IV-DID: 寻找工具变量 (如政策出台的地理/制度外生变异) 处理选择内生性; (3) RDD: 若有清晰的处理分配阈值, 用断点回归。

## 文献

1. Angrist, J. D., & Pischke, J. S. (2009). *Mostly Harmless Econometrics: An Empiricist's Companion*. Princeton University Press. (Chapter 5: Parallel Worlds — Fixed Effects, Differences-in-Differences, and Panel Data)
2. Ashenfelter, O. (1978). Estimating the effect of training programs on earnings. *Review of Economics and Statistics*, 60(1), 47-57. (最早的 DID 应用之一)
3. Card, D., & Krueger, A. B. (1994). Minimum wages and employment: A case study of the fast-food industry in New Jersey and Pennsylvania. *American Economic Review*, 84(4), 772-793. (DID 的经典案例: 最低工资)
4. Callaway, B., & Sant'Anna, P. H. C. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*, 225(2), 200-230. (交错 DID 新标准)
5. de Chaisemartin, C., & D'Haultfoeuille, X. (2020). Two-way fixed effects estimators with heterogeneous treatment effects. *American Economic Review*, 110(9), 2964-2996. (TWFE 负权重问题)
6. Bertrand, M., Duflo, E., & Mullainathan, S. (2004). How much should we trust differences-in-differences estimates? *Quarterly Journal of Economics*, 119(1), 249-275. (序列相关导致 SE 低估, 聚类标准误的必要性)

## 来源溯源

- 原始来源: DID 的思想可追溯到 John Snow (1855) 的霍乱调查, 但正式化归功于 Ashenfelter (1978) 和 Card & Krueger (1994)
- 教材标准化: Angrist & Pischke (2009) 的 *Mostly Harmless Econometrics* 将 DID 确立为准实验因果推断的核心工具
- 最新发展: Callaway & Sant'Anna (2021) 解决了交错 DID 中 TWFE 的负权重问题, 已成为新标准
- MATLAB 实现: `fitlm` (OLS 回归) + 自写 `did_estimate.m` 封装聚类标准误; 无原生 DID 函数
- 竞赛应用: 政策评估题 (如"禁塑令对塑料垃圾量的影响"), 干预效果评估 (如"某治疗方案的疗效")

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 — 数据预处理 + 面板数据整理 | PARADIGM-0501 |
| 前置 — 描述性统计 (分组均值表) | PARADIGM-0509 (ttest) |
| 互补 — 合成控制法 (单处理单元替代 DID) | PARADIGM-0526 |
| 互补 — PSM倾向评分匹配 (处理组选择内生) | PARADIGM-0615 |
| 互补 — 断点回归 RDD (阈值因果) | 见准实验方法文献 |
| 关联 — 生存分析 (事件-时间 DID 设计) | PARADIGM-0524 |
| 后置 — 稳健性检验 (安慰剂, 不同时间窗) | 本卡事件研究部分 |
