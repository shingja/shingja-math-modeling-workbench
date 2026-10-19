# PARADIGM-0302 TOPSIS法⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0302 |
| 类别/子类 | ③评价 / 距离综合 |
| 难度 | 低 |
| 适用题型关键词[] | TOPSIS, 理想解, 负理想解, 相对贴近度, 多属性决策, MADM, 距离综合, 逼近理想解排序, 规范化, 加权距离, 优劣解距离法 |
| confidence | high |
| source | Hwang, C.L. & Yoon, K. (1981) *Multiple Attribute Decision Making: Methods and Applications*. Springer-Verlag, Berlin. |

## 数学形式

### 1. 构建决策矩阵与规范化

设有 m 个方案, n 个指标, 原始决策矩阵 $X = (x_{ij})_{m \times n}$.

**向量规范化** (推荐, 消除量纲且保持方向信息):

$$r_{ij} = \frac{x_{ij}}{\sqrt{\sum_{i=1}^m x_{ij}^2}}$$

### 2. 加权规范化矩阵

给定权重向量 $\boldsymbol{w} = (w_1, \ldots, w_n)$ (由 AHP、熵权法或主观给定):

$$v_{ij} = w_j \cdot r_{ij}$$

### 3. 确定正理想解和负理想解

$$\begin{aligned}
A^+ &= \left\{ \max_i v_{ij} \mid j \in J_+; \; \min_i v_{ij} \mid j \in J_- \right\} = \{v_1^+, \ldots, v_n^+\} \\
A^- &= \left\{ \min_i v_{ij} \mid j \in J_+; \; \max_i v_{ij} \mid j \in J_- \right\} = \{v_1^-, \ldots, v_n^-\}
\end{aligned}$$

其中 $J_+$ 为效益型指标 (越大越好), $J_-$ 为成本型指标 (越小越好).

### 4. 计算距离

$$D_i^+ = \sqrt{\sum_{j=1}^n (v_{ij} - v_j^+)^2}, \quad D_i^- = \sqrt{\sum_{j=1}^n (v_{ij} - v_j^-)^2}$$

### 5. 相对贴近度 (方案评分)

$$C_i = \frac{D_i^-}{D_i^+ + D_i^-} \in [0, 1]$$

$C_i$ 越大方案越优. 当 $C_i \to 1$ 时方案趋近正理想解; $C_i \to 0$ 时趋近负理想解.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 决策矩阵 X | matrix (m×n) | — | 实数 | 极高 — 原始数据质量决定评价质量 |
| 权重向量 w | vector (n) | 等权 | w_j>0, Σw_j=1 | 高 — 权重直接影响距离加权 |
| 指标方向 dir | vector (n) | 全效益型 | {"benefit", "cost"} | 中 — 方向反了会导致正负理想解颠倒 |
| 规范化方法 | string | "vector" | {"vector", "min-max", "sum"} | 低 — vector 规范化最为稳定 |

**复杂度**: 空间 O(mn), 时间 O(mn) — 全部为向量化矩阵运算, m,n 增大时仍极快.

## MATLAB 实现

```matlab
% ===== PARADIGM-0302-TOPSIS: 自写-见S5:topsis_eval.m =====
function [C, D_pos, D_neg, A_pos, A_neg] = topsis_eval(X, w, dirs)
    % X: m×n 决策矩阵, 方案×指标
    % w: 1×n 权重向量 (默认等权: w = ones(1,n)/n)
    % dirs: 1×n char array, 'b'=benefit (效益), 'c'=cost (成本)
    % C: m×1 相对贴近度 (得分)
    % D_pos, D_neg: 到正/负理想解的距离

    [m, n] = size(X);

    if nargin < 2 || isempty(w)
        w = ones(1, n) / n;   % 等权
    end
    if nargin < 3 || isempty(dirs)
        dirs = repmat('b', 1, n);  % 默认全为效益型
    end

    % --- Step 1: 向量规范化 ---
    R = X ./ sqrt(sum(X.^2, 1));

    % --- Step 2: 加权规范化 ---
    V = R .* w;

    % --- Step 3: 确定正负理想解 ---
    A_pos = zeros(1, n);
    A_neg = zeros(1, n);
    for j = 1:n
        if dirs(j) == 'b' || dirs(j) == 'B'
            A_pos(j) = max(V(:, j));
            A_neg(j) = min(V(:, j));
        else  % cost
            A_pos(j) = min(V(:, j));
            A_neg(j) = max(V(:, j));
        end
    end

    % --- Step 4: 计算欧式距离 ---
    D_pos = sqrt(sum((V - A_pos).^2, 2));
    D_neg = sqrt(sum((V - A_neg).^2, 2));

    % --- Step 5: 相对贴近度 ---
    C = D_neg ./ (D_pos + D_neg);
end
```

## Python 备选

```python
import numpy as np

def topsis_eval(X: np.ndarray, w: np.ndarray = None,
                dirs: np.ndarray = None) -> np.ndarray:
    """TOPSIS 综合评价 (纯 numpy)"""
    m, n = X.shape

    if w is None:
        w = np.ones(n) / n
    if dirs is None:
        dirs = np.full(n, 'b')  # 默认效益型

    # 向量规范化
    R = X / np.sqrt(np.sum(X**2, axis=0))

    # 加权规范化
    V = R * w

    # 正负理想解
    A_pos = np.zeros(n)
    A_neg = np.zeros(n)
    for j in range(n):
        if dirs[j] == 'b':
            A_pos[j] = np.max(V[:, j])
            A_neg[j] = np.min(V[:, j])
        else:
            A_pos[j] = np.min(V[:, j])
            A_neg[j] = np.max(V[:, j])

    # 距离与贴近度
    D_pos = np.sqrt(np.sum((V - A_pos)**2, axis=1))
    D_neg = np.sqrt(np.sum((V - A_neg)**2, axis=1))
    C = D_neg / (D_pos + D_neg)

    return C, D_pos, D_neg, A_pos, A_neg
```

## 选型决策树

```
有多方案多指标需要综合排序
│
├─ 已确定指标权重 (主观/客观均可) → TOPSIS ✓ (本范式)
│   ├─ 指标独立性好 → 直接用
│   └─ 指标高度相关 → 先 PCA 降维, 再用 PCA-TOPSIS
│
├─ 仅有数据, 无权重 → 组合使用
│   ├─ 先用 熵权法 (PARADIGM-0303) 或 变异系数法 (PARADIGM-0307) 求权重
│   └─ 再用 TOPSIS 计算贴近度排序
│
├─ 数据含有模糊性/不确定性 → 模糊综合评价 (PARADIGM-0304)
├─ 关注效率而非排序 → DEA (PARADIGM-0308)
└─ 有参考序列需要比较 → 灰色关联分析 (PARADIGM-0305)
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 贴近度展示 | 横向条形图 — 各方案 C_i 降序排列 | 值标注, 颜色渐变 (高→深色, 低→浅色) |
| 距离分解 | 分组条形图 — 每方案 D+, D- 并排 | 直观展示"距理想解多远, 距负理想解多远" |
| 二维投影 | 散点图 — 方案在 A+A- 连线上的投影 | 展示方案在优劣维度上的相对位置 |
| 灵敏度分析 | tornado 图 — 权重变动 ±20% 对 C_i 排名影响 | 识别对排名敏感的权重指标 |

## 常见坑

1. **规范化方法不当**: 极差规范化 (min-max) 对异常值敏感, 一个极端值会压缩所有其他值的间距. 向量规范化更稳健, 但要求指标值非负.
2. **正负理想解均为虚拟点**: 在实际可行域中可能不存在任何方案达到 A+ 或 A-, 导致贴近度在狭窄区间内聚集 (如全部 C_i∈[0.45, 0.55]), 区分度不足.
3. **权重主导效应**: 某一指标权重过大 (如 w_j>0.5) 时, TOPSIS 退化为单指标排序, 其他指标几乎不起作用. 建议单指标权重不超过 0.35.
4. **指标方向误判**: 将成本型指标错误标记为效益型, 会导致正负理想解颠倒, 贴近度完全错误. 这是一项必须在建模前与领域专家确认的设定.
5. **距离度量选择**: 欧氏距离默认指标间不相关. 若指标高度相关 (如 GDP 总量与人均 GDP), 用马氏距离可去除相关性, 但需要样本数 > 指标数.

## 失效条件/反例 (强制小节)

- **条件1 — 所有方案贴近度高度聚集**: 当所有方案 C_i 集中在极小区间 (如 0.48~0.52), 排名的统计显著性为零 — 随机扰动即可颠覆排序. 原因通常为正负理想解位于可行域远处, 所有方案"同等远离"理想解. 此时应改用排序方法 (如秩和比法 RSR, PARADIGM-0306) 或引入虚拟基准方案锚定.
- **条件2 — 指标间存在多重共线性 (VIF>10)**: 若 3 个指标高度相关 (如 GDP、工业产值、服务业产值), 且都被赋予正权重, 则同一方向的信息被重复计入距离公式, 导致这些指标的实际权重远大于预设 w_j. 必须在 TOPSIS 前做 PCA 降维, 或改用马氏距离 TOPSIS.
- **条件3 — 正负理想解在可行域外极远处**: 当某个指标的最优值属于"理论极限"而非"样本最佳" (如效率值理论上界 1.0, 但样本最佳仅 0.75), 则 A+ 和 A- 均远离实际数据云, D+ 和 D- 同步增大, 二者比值趋于 0.5 附近. 解决: 用样本边界定义理想解, 而非理论边界.

## 文献

1. Hwang, C. L., & Yoon, K. (1981). *Multiple Attribute Decision Making: Methods and Applications*. Springer-Verlag. (原始著作)
2. Yoon, K. (1987). A reconciliation among discrete compromise solutions. *Journal of the Operational Research Society*, 38(3), 277-286.
3. Opricovic, S., & Tzeng, G. H. (2004). Compromise solution by MCDM methods: A comparative analysis of VIKOR and TOPSIS. *European Journal of Operational Research*, 156(2), 445-455.
4. Behzadian, M., et al. (2012). A state-of-the-art survey of TOPSIS applications. *Expert Systems with Applications*, 39(17), 13051-13069. (综述, 涵盖 266 篇 TOPSIS 应用)
5. Chen, C. T. (2000). Extensions of the TOPSIS for group decision-making under fuzzy environment. *Fuzzy Sets and Systems*, 114(1), 1-9.

## 来源溯源

TOPSIS (Technique for Order Preference by Similarity to Ideal Solution) 由 Hwang 和 Yoon 于 1981 年提出, 收录于 Springer 多属性决策专著. 核心思想源自理想点法 (Ideal Point Method): 最优方案应同时满足"距正理想解最近"和"距负理想解最远"两个条件, 以相对贴近度统一二者. 该方法因其数学简洁、几何直观 (方案视为 n 维空间中点) 而广泛应用于工程评价、供应商选择、选址决策、环境质量评价等领域. 后续演化包括 Fuzzy TOPSIS、灰色 TOPSIS、区间 TOPSIS 等多个变体.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 上游 — 主观赋权供 TOPSIS 使用 | PARADIGM-0301 (AHP) |
| 上游 — 客观赋权供 TOPSIS 使用 | PARADIGM-0303 (熵权法) |
| 上游 — 客观赋权供 TOPSIS 使用 | PARADIGM-0307 (变异系数法) |
| 同级对比 — 距离综合评价 | PARADIGM-0305 (灰色关联分析) |
| 同级对比 — 非参数排序 | PARADIGM-0306 (秩和比法) |
| 补偿性对比 — VIKOR 提供折中解 | VIKOR (非本 Skill, 需自建) |
| 降维前处理 | 主成分分析 (PCA) |
