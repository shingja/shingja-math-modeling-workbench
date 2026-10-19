# PARADIGM-1208-DEMATEL-ANP DEMATEL-ANP: 决策试验与网络分析法⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1208-DEMATEL-ANP |
| 类别/子类 | ⑫多目标决策进阶 / 网络赋权 |
| 难度 | 高 |
| 适用题型关键词[] | 准则依赖, 影响关系, 网络结构, 因果图, 反馈, 超矩阵 |
| confidence | medium |
| source | 论文1996_ANP / 题解反推_NetworkMCDM类 |

## 数学形式

**核心思想**: DEMATEL 确定准则间因果影响关系, ANP 在影响关系网络上计算考虑依赖和反馈的全局权重。

**DEMATEL 阶段**:
1. 直接影响矩阵 $\mathbf{D}$ ($n \times n$): 准则 $i$ 对 $j$ 的影响 (0-4 标度)
2. 归一化: $\mathbf{X} = s \cdot \mathbf{D}$, $s = 1 / \max_i \sum_{j} d_{ij}$
3. 总影响矩阵: $\mathbf{T} = \mathbf{X} + \mathbf{X}^2 + \cdots = \mathbf{X}(\mathbf{I} - \mathbf{X})^{-1}$
4. 中心度与原因度:
   $$r_i = \sum_j t_{ij} \quad \text{(影响度)}; \quad c_j = \sum_i t_{ij} \quad \text{(被影响度)}$$
   $$r_i + c_i \quad \text{(中心度—重要性)}; \quad r_i - c_i \quad \text{(原因度—正为因, 负为果)}$$
5. 设定阈值 $\alpha$ 过滤微弱关系, 获得影响关系图

**ANP 阶段**:
6. 构造未加权超矩阵 $\mathbf{W}$ (基于 DEMATEL 归一化 $T$)
7. 加权超矩阵 $\bar{\mathbf{W}}$ (乘以簇权重)
8. 极限超矩阵: $\mathbf{W}^{\infty} = \lim_{k \to \infty} \bar{\mathbf{W}}^k$
9. 极限矩阵的行即各准则的全局 ANP 权重

| 变量 | 含义 |
|------|------|
| $\mathbf{D}$ | 直接影响矩阵 |
| $\mathbf{T}$ | 总影响矩阵 (含直接 + 间接) |
| $\mathbf{W}$ | ANP 超矩阵 |
| $\alpha$ | DEMATEL 关系过滤阈值 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| DEMATEL 标度范围 | int | 0-4 | 0-3/0-5 | 低 |
| 阈值 $\alpha$ | float | 均值/中位数 | 取决于 $T$ | 高—决定网络结构 |
| ANP 一致性阈值 | float | 0.1 | 0.05-0.15 | 中 |

**时间复杂度**: $O(n^3)$ (矩阵求逆) + 幂迭代
**空间复杂度**: $O(n^2)$

## MATLAB 实现

```matlab
% 自写 DEMATEL-ANP 完整流程
% 自写-见S5:dematanp_analyze.m

% 实现步骤:
% 1. 输入直接影响矩阵 D (n×n)
% 2. DEMATEL: 归一化 → T = X*(I-X)^(-1) → r+c, r-c
% 3. 阈值过滤 → 影响关系图 (有向图)
% 4. ANP: 由 T 构造超矩阵 → 加权 → 幂迭代求极限
% 5. 输出全局权重 + 因果-重要性散点图
```

**锚点工具箱**: `graph`/`digraph` (构建影响关系图); `eigs` (幂迭代求极限超矩阵)

## Python 备选

```python
import numpy as np

def dematel_anp(D):
    # DEMATEL
    s = 1 / max(np.sum(D, axis=1))
    X = s * D
    T = X @ np.linalg.inv(np.eye(len(D)) - X)
    r = T.sum(axis=1)
    c = T.sum(axis=0)
    centrality = r + c   # 中心度
    causality = r - c    # 原因度
    
    # ANP: 极限超矩阵 (幂迭代)
    W = T / T.sum(axis=0, keepdims=True)
    W_inf = W
    for _ in range(100):
        W_new = W_inf @ W_inf
        if np.allclose(W_new, W_inf, atol=1e-8):
            break
        W_inf = W_new
    weights = W_inf[:, 0]
    return weights, centrality, causality
```

## 选型决策树

- **准则间存在明确的相互影响 (因果关系)** → DEMATEL-ANP (唯一捕获网络效应的客观赋权法)
- **准则独立 (AHP 假设)** → AHP/BWM (PARADIGM-1206) 即可, DEMATEL-ANP 过度复杂
- **仅需因果分析不赋权** → 单用 DEMATEL; 仅需赋权不管因果 → 单用 ANP (不常见)
- **数据驱动 + 无需专家判断** → CRITIC (PARADIGM-1205); DEMATEL-ANP 依赖专家判断影响关系
- **竞赛文献中少见** → 若评审可能不熟, 建议说明"基于因果网络分析的改进权重确定"

## 典型图型

- **raw**: 直接影响矩阵热力图
- **process**: 因果图 (有向网络, 节点大小=中心度, 边宽=影响强度), $r+c$ vs $r-c$ 四象限散点图
- **result**: 全局权重柱状图, 与 AHP 权重对比图 (验证网络效应的修正幅度)

## 常见坑

1. **直接影响矩阵一致性**: DEMATEL 不提供类似 AHP 的 CR 检验 → 缺乏一致性保证, 依赖专家判断质量
2. **阈值 $\alpha$ 主观决定网络密度**: 太高压制间接关系, 太低噪声过多 → 用均值 + 标准差策略
3. **极限超矩阵不收敛**: 非本原矩阵导致周期振荡 → 检查网络是否连通, 必要时加 damping factor
4. **高维时超矩阵过于稀疏**: 若网络未被识别则 ANP 权重退化为近等权 → 检查 DEMATEL 是否有意义

## 失效条件/反例 (强制小节)

- **条件1**: 准则数 $n < 5$ → DEMATEL 网络效应不明显, 投入产出比低; ANP 超矩阵维度过小, 与 AHP/BWM 无实质差异。**替代**: AHP 或 BWM (PARADIGM-1206)
- **条件2**: 缺乏专家判断直接影响矩阵 → DEMATEL-ANP 核心输入来自主观判断; 无法获专家意见时只能基于数据推因果关系 (Granger/相关系数), 但这不是标准 DEMATEL。**替代**: CRITIC (PARADIGM-1205) 或 PCA
- **条件3**: 准则间几乎无相互关系 (对角优势矩阵) → $T \approx I$, 网络效应可忽略, ANP 退化。用 ANP 是多此一举。**替代**: 单用 AHP/熵权法
- **条件4**: 准则数目 $n > 30$ → 直接影响矩阵需 $n(n-1)$ 次判断, 专家不可行。**替代**: 先聚类分组, 组内 ANP + 组间 AHP

## 文献

1. Saaty, T. L. (1996). *Decision Making with Dependence and Feedback: The Analytic Network Process*. RWS Publications. ISBN: 978-0-9620317-9-3.
2. Gabus, A., & Fontela, E. (1972). World problems, an invitation to further thought within the framework of DEMATEL. *Battelle Geneva Research Centre*.
3. Wu, W. W. (2008). Choosing knowledge management strategies by using a combined ANP and DEMATEL approach. *Expert Systems with Applications*, 35(3), 828-835. DOI: [10.1016/j.eswa.2007.07.025](https://doi.org/10.1016/j.eswa.2007.07.025)

## 来源溯源

- 论文三元组: Saaty 1996 ANP + Gabus 1972 DEMATEL + Wu 2008 二者组合
- 教学用例: 绿色供应链障碍因素分析, 风险因子互影响分析

## 关联范式卡

组合: PARADIGM-1204-VIKOR (ANP赋权 + VIKOR排序)
替代: PARADIGM-1206-BWM (独立准则赋权), PARADIGM-1205-CRITIC (数据驱动赋权)
前置: AHP (PARADIGM-0402) 建议先掌握, ANP 是其扩展
