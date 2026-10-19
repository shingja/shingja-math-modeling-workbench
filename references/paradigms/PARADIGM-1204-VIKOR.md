# PARADIGM-1204-VIKOR VIKOR: 多准则妥协解排序法⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1204-VIKOR |
| 类别/子类 | ⑫多目标决策进阶 / 多属性决策 |
| 难度 | 中 |
| 适用题型关键词[] | 方案排序, 冲突准则, 妥协解, 群决策, 供应商选择, 选址评价 |
| confidence | high |
| source | 教材第12章 / 论文2004_VIKOR / 题解反推_MCDM类 |

## 数学形式

**核心思想**: 折衷规划, 最大化群体效用, 最小化个体遗憾。

对于 $m$ 个方案, $n$ 个准则:
1. 确定最佳 $f_j^*$ 和最劣 $f_j^-$:
   $$f_j^* = \max_i x_{ij}, \quad f_j^- = \min_i x_{ij} \quad \text{(效益型)}$$
   $$f_j^* = \min_i x_{ij}, \quad f_j^- = \max_i x_{ij} \quad \text{(成本型)}$$

2. 计算 $S_i$ (群体效用) 和 $R_i$ (个体遗憾):
   $$S_i = \sum_{j=1}^{n} w_j \frac{f_j^* - x_{ij}}{f_j^* - f_j^-}$$
   $$R_i = \max_j \left[ w_j \frac{f_j^* - x_{ij}}{f_j^* - f_j^-} \right]$$

3. 计算 $Q_i$ (综合指标):
   $$Q_i = v \frac{S_i - S^*}{S^- - S^*} + (1-v) \frac{R_i - R^*}{R^- - R^*}$$
   其中 $S^* = \min_i S_i, \; S^- = \max_i S_i, \; R^* = \min_i R_i, \; R^- = \max_i R_i$
   $v \in [0,1]$: 群体效用权重 ($v>0.5$"大多数", $v=0.5$"共识", $v<0.5$"否决权")

4. 按 $Q_i$ 升序排列; 若满足可接受优势 ($Q(a'')-Q(a') \geq DQ$) 和可接受稳定性 则最小 $Q$ 为妥协解

| 变量 | 含义 |
|------|------|
| $w_j$ | 准则 $j$ 的权重 |
| $v$ | 决策机制系数 (多数/共识/否决) |
| $DQ$ | 可接受优势阈值 $= 1/(m-1)$ |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| $v$ (策略权重) | float | 0.5 | 0-1 | 高—决定排序倾斜方向 |
| 准则权重 $w_j$ | float[] | 等权 | — | 高—排序结果的主要驱动 |
| $DQ$ | float | $1/(m-1)$ | — | 低—仅影响妥协解判定 |

**时间复杂度**: $O(m n)$ (简单线性)
**空间复杂度**: $O(m)$

## MATLAB 实现

```matlab
% 自写 VIKOR 主函数
% 自写-见S5:vikor_evaluate.m

% 输入: decision_matrix (m×n), weights (1×n), v (标量), criteria_type ('benefit'/'cost')
% 输出: Q_scores, ranking, compromise_solution
% 实现逻辑: 归一化 → S/R计算 → Q聚合 → 可接受条件检验
```

**锚点工具箱**: 无内置 VIKOR, 需自写

## Python 备选

```python
import numpy as np

def vikor(matrix, weights, v=0.5, criterion_type=None):
    # 归一化
    f_star = np.max(matrix, axis=0)  # benefit
    f_minus = np.min(matrix, axis=0)
    # S, R, Q 计算
    S = np.sum(weights * (f_star - matrix) / (f_star - f_minus), axis=1)
    R = np.max(weights * (f_star - matrix) / (f_star - f_minus), axis=1)
    Q = v * (S - S.min()) / (S.max() - S.min()) + \
        (1-v) * (R - R.min()) / (R.max() - R.min())
    return Q, np.argsort(Q)
```

备选: `scikit-criteria` 库含 VIKOR 实现

## 选型决策树

- **多方案 + 冲突准则 + 需要妥协解** → VIKOR (直接给出"最折衷方案")
- **仅需全排序 + 无妥协概念** → TOPSIS 或 PROMETHEE (PARADIGM-1207)
- **准则间有强相关性** → 先用 CRITIC (PARADIGM-1205) 去相关赋权 再用 VIKOR
- **层级结构 + 准则依赖** → DEMATEL-ANP (PARADIGM-1208) 确定权重后 VIKOR
- **主观赋权** → AHP/BWM (PARADIGM-1206) 确定权重后 VIKOR
- **客观赋权** → 熵权法/CRITIC (PARADIGM-1205) 确定权重后 VIKOR
- **TOPSIS vs VIKOR**: TOPSIS 选距理想解最近的方案; VIKOR 额外考虑"最坏准则"的最小化—更保守, 适用于风险厌恶决策

## 典型图型

- **raw**: 决策矩阵热力图
- **process**: S-R-Q 三维散点图/S-R 散点图 + Q 等值线
- **result**: 排名柱状图 (降序标记), 各方案对各准则的雷达图 (前3名叠层)

## 常见坑

1. **$v$ 选择主观**: 需解释取 $v=0.5$ 的原因 (共识策略) — 敏感性分析 ($v=0,0.25,0.5,0.75,1$) 验证稳健性
2. **准则方向误判**: 成本型 vs 效益型搞混 → 排序颠倒。显式声明 `criteria_type`
3. **权重来源不透明**: 权重对结果影响极大 → 必须声明权重来源 (AHP/熵权/CRITIC/专家)
4. **方案数过少**: $m \leq 2$ 时 $DQ = 1$, 优势条件过于严格 → 仅适用于 $m \geq 4$

## 失效条件/反例 (强制小节)

- **条件1**: 方案数 $m \leq 3$ → $DQ=1/(m-1)$ 过大, 可接受优势条件几乎永远不满足, 无法唯一确定妥协解。**替代**: TOPSIS 或简单加权和
- **条件2**: 准则完全独立且决策者明确偏好"激进方案 (只关注综合)" → VIKOR 的个体遗憾 $R_i$ 项引入了保守偏好 (关注最差准则), 会低估某些"偏科"的优秀方案。**替代**: TOPSIS 或 SAW
- **条件3**: 准则数目极大 ($>30$) 且多数准则无关 → $R_i$ 取 max 在大量无关准则中选一个最差, 信噪比极低, 个体遗憾指标失意义。**替代**: 先 PCA/因子分析降维, 后 TOPSIS
- **条件4**: 所有方案在某准则上完全一致 → 该准则 $f_j^* = f_j^-$, 分母为 0。需删除该准则或添加微小扰动

## 文献

1. Opricovic, S., & Tzeng, G. H. (2004). Compromise solution by MCDM methods: A comparative analysis of VIKOR and TOPSIS. *European Journal of Operational Research*, 156(2), 445-455. DOI: [10.1016/S0377-2217(03)00020-1](https://doi.org/10.1016/S0377-2217(03)00020-1)
2. Opricovic, S. (1998). *Multicriteria Optimization of Civil Engineering Systems*. Faculty of Civil Engineering, Belgrade. ISBN: 978-86-80249-05-6.

## 来源溯源

- 论文三元组: Opricovic 2004, VIKOR vs TOPSIS, compromise ranking
- 教学用例: 供应商选择/工厂选址/桥梁设计方案

## 关联范式卡

组合: PARADIGM-1205-CRITIC (客观权重), PARADIGM-1206-BWM (主观权重), PARADIGM-0401-TOPSIS (备选排序)
替代: PARADIGM-0401-TOPSIS (理想解距离), PARADIGM-1207-PROMETHEE (偏好函数)
前置: 任意赋权法 (AHP/熵权/CRITIC/BWM)
