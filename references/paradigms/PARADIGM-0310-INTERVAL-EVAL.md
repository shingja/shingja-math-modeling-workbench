# PARADIGM-0310 区间数评价⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0310 |
| 类别/子类 | ③评价 / 不确定性评价 |
| 难度 | 中 |
| 适用题型关键词[] | 区间数, 区间评价, 区间TOPSIS, 不确定性, 模糊区间, Moore区间分析 |
| confidence | medium |
| source | Moore (1966) Interval Analysis |

## 数学形式

**区间数表示 (不确定性指标值):**
$$[x_{ij}^L, x_{ij}^U], \quad i=1,\ldots,n \text{ (方案)}, j=1,\ldots,m \text{ (指标)}$$

**区间运算 (Moore 算术):**
$$[a,b] + [c,d] = [a+c, b+d]$$
$$[a,b] - [c,d] = [a-d, b-c]$$
$$[a,b] \times [c,d] = [\min(ac,ad,bc,bd), \max(ac,ad,bc,bd)]$$

**区间数比较 (可能度/优势度):**
$P(a > b)$ — 区间 $a$ 大于 $b$ 的可能度:
$$P(a > b) = \frac{\max(0, a^U - b^L) - \max(0, a^L - b^U)}{(a^U - a^L) + (b^U - b^L)}$$

**区间 TOPSIS:**
1. 确定区间正理想解 $A^+ = [a_j^{+L}, a_j^{+U}]$ 和负理想解 $A^-$
2. 计算到理想解的区间距离 (欧氏距离):
   $$d_i^+ = \sqrt{\sum_j \left(|x_{ij}^L - a_j^{+L}|^2 + |x_{ij}^U - a_j^{+U}|^2\right)/2}$$
3. 区间贴近度 $C_i$ (可能度排序)

**区间可能度矩阵排序:**
$$p_{ij} = P(C_i > C_j), \quad \text{排序向量 } \mathbf{v}_i = \frac{1}{n(n-1)}\left(\sum_{j} p_{ij} + \frac{n}{2} - 1\right)$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 指标区间矩阵 | double[,] | — | n×m×2 [L,U] | — |
| 区间宽度 | double | — | 由不确定性决定 | 极高 — 宽区间产生重叠排名 |
| 正负理想解定义 | — | 绝对值法 | 绝对值/可能度 | 中 |

## MATLAB 实现

函数签名 (自写):
```matlab
[scores, ranking, C_interval] = interval_topsis(X_L, X_U, weights, criteria_type)
% X_L, X_U: n×m 下界/上界矩阵
% scores: 可能度排序向量
% C_interval: n×2 贴近度区间
```

锚点: 自写-见S5:interval_topsis.m

```matlab
function [scores, C] = interval_topsis(X_L, X_U, w, is_benefit)
    [n, m] = size(X_L);
    
    % 归一化 (区间向量)
    norm_L = sqrt(sum((X_L.^2 + X_U.^2)/2, 1));
    R_L = X_L ./ norm_L; R_U = X_U ./ norm_L;
    
    % 加权
    V_L = R_L .* w; V_U = R_U .* w;
    
    % 正负理想解
    A_plus_L = max(V_L(:,is_benefit), [], 1);
    A_plus_U = max(V_U(:,is_benefit), [], 1);
    A_minus_L = min(V_L(:,is_benefit), [], 1);
    A_minus_U = min(V_U(:,is_benefit), [], 1);
    
    % 区间距离
    d_plus = sqrt(sum(((V_L-A_plus_L).^2 + (V_U-A_plus_U).^2)/2, 2));
    d_minus = sqrt(sum(((V_L-A_minus_L).^2 + (V_U-A_minus_U).^2)/2, 2));
    
    % 贴近度 (点值)
    c_point = d_minus ./ (d_plus + d_minus);
    [~, ranking] = sort(c_point, 'descend');
    scores = c_point;
end
```

## Python 备选

```python
import numpy as np
# 区间运算可用 pyinterval (需安装)
# from interval import interval
```

## 选型决策树

- **区间评价** — 指标值本身不确定 (如预测值、估计区间、专家给出区间)
- **模糊评价 (PARADIGM-0304)** — 不确定性用隶属度函数表达 (如"高/中/低")
- **TOPSIS CRISP (PARADIGM-0302)** — 指标值确定 (点估计)
- **随机评价 Monte Carlo** — 已知分布 → 抽样模拟 > 区间算术

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 各方案指标区间条图 (horizontal error bar) | 展示不确定性范围 |
| result | 贴近度区间排序 (垂直线段) | 重叠区间无法严格排序 |
| result | 可能度矩阵热力图 | $p_{ij}$ 方案比较 |

## 常见坑

1. **区间膨胀 (Dependency Problem)**: 同一变量多次出现在区间运算中 → 结果区间过度保守。用区间形式的适当重写
2. **宽区间 → 排名重叠**: 所有方案的区间贴近度重叠 → 无法严格区分 → 用可能度排序
3. **区间宽度不一致**: 某些方案数据充足 (窄区间)，某些不充足 (宽区间) → 窄区间方案在TOPSIS中占优

## 失效条件/反例 (强制小节)

- **条件1: 所有方案区间严重重叠 → 无法排序** → 表现: 可能度矩阵 $p_{ij} \approx 0.5$ 对所有 $i,j$ → 排序无信息 (随机顺序)。**应对**: 缩小不确定性 (收集更多数据)，或使用乐观/悲观准则 (Hurwicz) 给出两种情况下的排序
- **条件2: 指标数多 (m > 50) + 区间运算 → 区间膨胀** → 表现: TOPSIS 的距离求和 $\sqrt{\sum}$ 中每一维度贡献的区间累积 → 总距离区间被放大 $\sqrt{m}$ 倍 → 所有方案距离区间极度重叠。**应对**: 先用 PCA 降低维度 (见 PARADIGM-0504)，或改用区间 AHP

## 文献

1. Moore R.E. (1966). *Interval Analysis*. Prentice-Hall.
2. Yue Z. (2011). "An extended TOPSIS for determining weights of decision makers with interval numbers." *Knowledge-Based Systems*, 24(1):146-153.

## 来源溯源

自写 interval_topsis.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0302 (TOPSIS) |
| 替代 | PARADIGM-0304 (模糊评价) |
| 组合 | PARADIGM-0303 (熵权法) |
