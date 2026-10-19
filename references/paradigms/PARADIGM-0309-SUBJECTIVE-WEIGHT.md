# PARADIGM-0309 主观赋权法(德尔菲/专家打分)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0309 |
| 类别/子类 | ③评价 / 主观赋权 |
| 难度 | 低 |
| 适用题型关键词[] | 主观赋权, 德尔菲, 专家打分, Delphi, 专家调查, 赋权, 层次分析, Dalkey&Helmer |
| confidence | medium |
| source | Dalkey & Helmer (1963) Management Science |

## 数学形式

**德尔菲法 (Delphi Method) 流程:**

1. **匿名征询:** 专家独立给出权重 $w_j^{(r)}, \quad r = 1,\ldots, R$ (专家数), $j = 1,\ldots, M$ (指标数)

2. **统计反馈:**
   - 中位数/均值: $\bar{w}_j = \frac{1}{R}\sum_{r} w_j^{(r)}$
   - 四分位距 IQR: 测量专家一致性

3. **多轮收敛:** 分享上一轮的统计摘要 → 专家修改 → 重复直到 IQR < 阈值 或 轮数到上限

**专家打分法 (Direct Rating):**
$$w_j = \frac{s_j}{\sum_{k} s_k}, \quad s_j = \frac{1}{R}\sum_{r} s_j^{(r)}$$

其中 $s_j^{(r)}$ 为专家 $r$ 对指标 $j$ 的重要度评分 (如 1-10 级 Likert scale)。

**一致性检验 (Kendall W 系数):**
$$W = \frac{12 \sum_{j=1}^{M} (R_j - \bar{R})^2}{R^2(M^3 - M)}$$

其中 $R_j$ 为指标 $j$ 的秩和，$0 \leq W \leq 1$，$W > 0.7$ 表明较好一致性。

**G1 法 (序关系法):**
1. 专家排序指标按重要性: $x_1^* \succ x_2^* \succ \cdots \succ x_M^*$
2. 确定相邻重要度比值: $r_k = w_{k-1}^* / w_k^*$ (1.0 到 1.8)
3. $w_M^* = (1 + \sum_{k=2}^{M} \prod_{i=k}^{M} r_i)^{-1}$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| R (专家数) | int | 15 | [5, 50] | 高 — R<5 不可靠 |
| max_rounds | int | 3 | [2, 5] | 中 |
| consistency_threshold | double | 0.7 | [0.5, 0.9] | 中 |
| 评分标度 | — | Likert 1-10 | — | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[weights, consistency, round_data] = delphi_weight(expert_scores, ...
    max_rounds, consistency_threshold)
% expert_scores: R × M × max_rounds (逐步填充)
% weights: 1×M 最终权重
% consistency: Kendall W
```

锚点: 自写-见S5:delphi_weight.m

```matlab
function [weights, W] = delphi_weight(scores)
    % scores: R × M 矩阵
    % 计算均值
    weights = mean(scores, 1);
    weights = weights / sum(weights);
    
    % Kendall W 一致性
    R = size(scores, 1); M = size(scores, 2);
    ranks = tiedrank(scores')';  % 每行(专家)独立排序
    R_j = sum(ranks, 1);  % 列和
    R_bar = mean(R_j);
    W = 12 * sum((R_j - R_bar).^2) / (R^2 * (M^3 - M));
end

% G1 法
function weights = g1_method(importance_order, ratios)
    M = length(importance_order);
    % ratios: M-1 个相邻比值
    prod_cum = cumprod([1, ratios(end:-1:1)]);
    w_M = 1 / sum(prod_cum);
    weights(importance_order) = w_M * prod_cum(end:-1:1);
end
```

## Python 备选

```python
import numpy as np
from scipy.stats import kendalltau

def delphi(scores):
    weights = np.mean(scores, axis=0)
    return weights / np.sum(weights)

# Kendall W
def kendall_w(scores):
    R, M = scores.shape
    ranks = np.apply_along_axis(lambda r: np.argsort(np.argsort(r))+1, 1, scores)
    R_j = np.sum(ranks, axis=0)
    return 12 * np.sum((R_j - R_j.mean())**2) / (R**2 * (M**3 - M))
```

## 选型决策树

- **德尔菲** — 多位专家，匿名多轮，需要消除权威人物偏见
- **G1 法** — 仅序关系 (高/低)，简化专家认知负担
- **AHP (PARADIGM-0301)** — 配对比较 + 一致性检验，更结构化
- **BWM (PARADIGM-1206)** — 最优-最差对照，数据需求小于 AHP
- **熵权法 (PARADIGM-0303)** — 客观数据驱动 (不需专家)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | Kendall W 随轮次变化 | 收敛监控 |
| result | 各指标权重箱线图 (多专家) | 专家分布 |
| result | 权重排序柱状图 | 最终权重大小 |

## 常见坑

1. **权威锚定效应**: 某权威专家在首轮公开自己的评分 → 其他专家被"锚定" → 必须匿名
2. **专家数量不足**: R<5 时统计检验 (Kendall W) 无统计效力 → 至少 10-15 名专家
3. **多轮递增的认知疲劳**: R3-R5 轮专家可能随意打分应付 → 限制在 3 轮

## 失效条件/反例 (强制小节)

- **条件1: 专家背景同质 (同一机构/学派)** → 表现: 初始一致性很高 (W>0.8) 但集体偏见 → 德尔菲的"收敛"只是确认了群体偏见而非逼近真理。**应对**: 刻意邀请异质专家 (多机构/多学派)，用 cluster analysis 识别不同意见群
- **条件2: 问题本身不适合专家判断 (如全新领域无先验经验)** → 表现: 专家的信心和评分分布在随机猜测水平，Kendall W < 0.3 且不随轮次改善 → 主观赋权无价值。**应对**: 放弃主观赋权，改用完全客观赋权 (熵权法/CRITIC) 或数据驱动的组合赋权

## 文献

1. Dalkey N. & Helmer O. (1963). "An experimental application of the Delphi method to the use of experts." *Management Science*, 9(3):458-467. DOI: [10.1287/mnsc.9.3.458](https://doi.org/10.1287/mnsc.9.3.458)
2. Saaty T.L. (1980). *The Analytic Hierarchy Process*. McGraw-Hill. ISBN: 978-0070543713

## 来源溯源

自写 delphi_weight.m; 综合评价教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0301 (AHP) |
| 替代 | PARADIGM-1206 (BWM) |
| 组合 | PARADIGM-0303 (熵权法客观+主观) |
