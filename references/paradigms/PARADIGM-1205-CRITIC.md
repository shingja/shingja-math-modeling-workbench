# PARADIGM-1205-CRITIC CRITIC: 准则间相关性赋权法⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1205-CRITIC |
| 类别/子类 | ⑫多目标决策进阶 / 客观赋权 |
| 难度 | 低 |
| 适用题型关键词[] | 客观赋权, 准则相关性, 对比强度, 冲突性, 信息量权重 |
| confidence | high |
| source | 论文1995_CRITIC / 题解反推_Weight类 |

## 数学形式

**核心思想**: 准则权重由两个因素决定——准则内的对比强度 (标准差) 和准则间的冲突性 (1 - 相关系数)。

1. **数据归一化** (Min-Max):
   $$r_{ij} = \frac{x_{ij} - x_j^{\min}}{x_j^{\max} - x_j^{\min}}$$

2. **准则 $j$ 的信息量**:
   $$C_j = \sigma_j \sum_{k=1}^{n} (1 - \rho_{jk})$$
   其中 $\sigma_j$ = 准则 $j$ 的标准差 (对比强度), $\rho_{jk}$ = 准则 $j$ 与 $k$ 的 Pearson 相关系数

3. **归一化权重**:
   $$w_j = \frac{C_j}{\sum_{k=1}^{n} C_k}$$

| 变量 | 含义 |
|------|------|
| $\sigma_j$ | 准则 $j$ 的标准差 |
| $\rho_{jk}$ | 准则 $j$ 与 $k$ 的相关系数 |
| $C_j$ | 准则 $j$ 的综合信息量 |
| $1-\rho_{jk}$ | 冲突性—与其它准则越不相关, 信息量越大 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 归一化方式 | enum | min-max | min-max/z-score | 低—CRITIC 用标准差衡量对比强度, z-score 会消除 |
| 相关系数类型 | enum | Pearson | Pearson/Spearman | 中—非线性关系用 Spearman |

**时间复杂度**: $O(m n^2)$ (计算 $n \times n$ 相关系数矩阵)
**空间复杂度**: $O(n^2)$

## MATLAB 实现

```matlab
% 自写 CRITIC 权重计算
% 自写-见S5:critic_weight.m

% 实现步骤:
% 1. 归一化决策矩阵 (min-max)
% 2. 计算各列标准差
% 3. 计算 Pearson 相关系数矩阵
% 4. 计算冲突性: 每列 sum(1 - abs(R))
% 5. 信息量: std .* conflict
% 6. 归一化权重
```

**锚点工具箱**: `corr` (Statistics Toolbox) 用于相关系数计算; `std` (内置)

## Python 备选

```python
import numpy as np

def critic_weight(matrix):
    m, n = matrix.shape
    # min-max 归一化
    r = (matrix - matrix.min(axis=0)) / (matrix.max(axis=0) - matrix.min(axis=0))
    # 标准差
    sigma = np.std(r, axis=0, ddof=1)
    # 相关系数矩阵
    R = np.corrcoef(r, rowvar=False)
    # 冲突性
    conflict = np.sum(1 - np.abs(R), axis=1)
    # 信息量
    C = sigma * conflict
    return C / C.sum()
```

## 选型决策树

- **完全客观数据驱动 + 准则间可能存在相关性** → CRITIC (首选)
- **准则间完全独立** → 熵权法 (更简单, CRITIC 退化为标准差加权)
- **需要主观偏好 + 少量准则** → AHP 或 BWM (PARADIGM-1206)
- **样本量有限 (方案数少)** → 相关系数不稳定, 换熵权法 (仅用标准差信息)
- **准则同时含效益/成本型** → CRITIC 归一化时需区分方向

## 典型图型

- **raw**: 相关系数矩阵热力图 (带显著性标记)
- **process**: 各准则 $\sigma_j$, 冲突性, 信息量 $C_j$ 的三列对比柱状图
- **result**: 权重降序柱状图 + 累积权重曲线 (Pareto 图)

## 常见坑

1. **Pearson 相关仅捕捉线性关系**: 非线性关系 $\rho \approx 0$ 但实际强相关 → 换 Spearman 或用距离相关系数
2. **小样本导致不稳定 $\rho$**: 方案数 $m < 10$ 时相关系数 $p$ 值均不显著 → 不适用 CRITIC, 换熵权法
3. **标准差受量纲影响**: 未归一化直接算 $\sigma$ → 必先 min-max 归一化
4. **绝对值被忽略**: $\rho \approx -0.9$ (强负相关) 冲突性应为 $1 - |\rho| = 0.1$, 若误用 $1-\rho=1.9$ 则赋权过高

## 失效条件/反例 (强制小节)

- **条件1**: 方案数 $m < 10$ (小样本) → Pearson 相关系数极不稳定, $p$ 值不显著, $C_j$ 沦为噪声。**替代**: 熵权法 (不需要相关系数) 或直接等权
- **条件2**: 各准则标准差近乎相等 (方差齐性) → $\sigma_j$ 无区分度, 权重差异仅来自冲突性。若冲突性也相近 → 权重退化为等权, CRITIC 无价值。**替代**: 主观赋权 (AHP/BWM) 或直接等权
- **条件3**: 准则数目 $n \gg m$ ($n > 3m$) → 相关系数矩阵秩亏, 伪相关严重, 冲突性指标被稀释。**替代**: 先用 PCA 降维, 再对主成分用熵权/CRITIC
- **条件4**: 数据含大量离群值 → min-max 归一化被离群值压缩, 大部分数据集中在小区间, $\sigma_j$ 失真。**替代**: 先用 robust z-score (MAD) 处理离群值

## 文献

1. Diakoulaki, D., Mavrotas, G., & Papayannakis, L. (1995). Determining objective weights in multiple criteria problems: The CRITIC method. *Computers & Operations Research*, 22(7), 763-770. DOI: [10.1016/0305-0548(94)00059-H](https://doi.org/10.1016/0305-0548(94)00059-H)
2. Zeleny, M. (1982). *Multiple Criteria Decision Making*. McGraw-Hill. ISBN: 978-0-07-072795-8.

## 来源溯源

- 论文三元组: Diakoulaki 1995, CRITIC, objective weights + correlation
- 教学用例: 经济指标赋权/城市竞争力评价指标

## 关联范式卡

组合: PARADIGM-1204-VIKOR (CRITIC赋权 + VIKOR排序), PARADIGM-1207-PROMETHEE (赋权+排序)
替代: 熵权法 (独立准则), PARADIGM-1206-BWM (主观赋权), PARADIGM-1208-DEMATEL-ANP (网络依赖)
