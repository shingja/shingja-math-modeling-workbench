# PARADIGM-0512 对应分析⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0512 |
| 类别/子类 | ⑤统计 / 多元探索 |
| 难度 | 中 |
| 适用题型关键词[] | 对应分析, Correspondence Analysis, 列联表, 双标图, 类别关联, chi-square距离, Greenacre |
| confidence | medium |
| source | Greenacre (2017) CRC |

## 数学形式

**输入:** 列联表 $\mathbf{N}_{I\times J}$ (如品牌 × 属性、物种 × 地点)

**对应矩阵:**
$$\mathbf{P} = \frac{\mathbf{N}}{n}, \quad n = \sum_{i,j} N_{ij}$$

**行轮廓 (Row Profile) 和列轮廓 (Column Profile):**
$$\mathbf{r} = \mathbf{P}\mathbf{1}, \quad \mathbf{c} = \mathbf{P}^T\mathbf{1}$$

**Chi-square 距离:**
$$d^2(i, i') = \sum_{j} \frac{1}{c_j}\left(\frac{P_{ij}}{r_i} - \frac{P_{i'j}}{r_{i'}}\right)^2$$

**标准化残差:**
$$\mathbf{S} = \mathbf{D}_r^{-1/2}(\mathbf{P} - \mathbf{r}\mathbf{c}^T)\mathbf{D}_c^{-1/2}$$

**SVD:**
$$\mathbf{S} = \mathbf{U}\mathbf{\Sigma}\mathbf{V}^T$$

**行坐标 (Principal Coordinates):**
$$\mathbf{F} = \mathbf{D}_r^{-1/2}\mathbf{U}\mathbf{\Sigma}$$

**列坐标:**
$$\mathbf{G} = \mathbf{D}_c^{-1/2}\mathbf{V}\mathbf{\Sigma}$$

**惯量 (Inertia = Chi-square 统计量 / n):**
$$\text{Total Inertia} = \frac{\chi^2}{n} = \sum_{k=1}^{K} \sigma_k^2, \quad K = \min(I-1, J-1)$$

**贡献率:** $\sigma_k^2 / \sum \sigma_k^2$ (类似 PCA 的方差解释比例)。

**双标图 (Biplot) 解读规则:**
- 接近原点的类别 → 接近平均轮廓 (无特殊)
- 同一方向上远离原点的行/列类别 → 关联
- 夹角锐角 → 正关联；钝角 → 负关联

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 列联表 N | int[,] | — | I×J 非负整数 | — 原始数据 |
| dims (输出维度) | int | 2 | [1, min(I,J)-1] | 低 — 通常2用于可视化 |
| 惯量阈值 | — | — | — | — |
| 复杂度 | — | — | O(n + I·J·K) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[row_coords, col_coords, inertia, contrib, chi2_pval] = correspondence_analysis(N)
% N: I×J 列联表
% row_coords, col_coords: 主坐标 (默认前2维)
% inertia: 惯量&占比
```

锚点: 自写-见S5:correspondence_analysis.m

```matlab
function [F, G, inertia, contrib] = ca(N)
    n = sum(N(:));
    P = N / n;
    r = sum(P, 2);  % 行质量
    c = sum(P, 1)'; % 列质量
    
    % 标准化残差
    Dr_invsqrt = diag(1./sqrt(r));
    Dc_invsqrt = diag(1./sqrt(c));
    S = Dr_invsqrt * (P - r*c') * Dc_invsqrt;
    
    % SVD
    [U, Sigma, V] = svd(S, 'econ');
    sigma = diag(Sigma);
    
    % 主坐标
    K = min(size(N,1)-1, size(N,2)-1);
    F = diag(1./sqrt(r)) * U(:,1:K) * diag(sigma(1:K));
    G = diag(1./sqrt(c)) * V(:,1:K) * diag(sigma(1:K));
    
    % 惯量
    total_inertia = sum(sigma.^2);
    pct = sigma.^2 / total_inertia * 100;
    inertia = table(sigma(1:K), pct(1:K), cumsum(pct(1:K)), ...
        'VariableNames', {'SingularValue','Percent','Cumulative'});
    
    % 贡献率 (行/列对维度)
    row_contrib = (r .* F.^2) ./ sigma(1:K)'.^2 * 100;
    col_contrib = (c .* G.^2) ./ sigma(1:K)'.^2 * 100;
end
```

## Python 备选

```python
# prince 库
import prince
ca = prince.CA(n_components=2)
ca = ca.fit(N)  # N: pd.DataFrame contingency table
row_coords = ca.row_coordinates(N)
col_coords = ca.column_coordinates(N)
ca.plot_coordinates(N)
```

## 选型决策树

- **对应分析 CA** — 探索两个分类变量 (行×列) 的关联结构
- **多重对应分析 MCA** — 多于两个分类变量
- **PCA (PARADIGM-0504)** — 连续变量
- **Chi-square test** — 仅检验独立性 (不探索结构)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | 双标图 (行+列坐标散点 overlay) | 解读关联模式 |
| result | 惯量碎石图 + 维度贡献 | 选维度 |

## 常见坑

1. **双标图距离解读错误**: 仅同类型点 (行-行, 列-列) 的距离有意义 → 行-列的距离是 Chi-square 距离不是欧氏距离
2. **稀疏列联表零单元格**: 零频率导致轮廓不稳定 → 添加平滑 (如 +0.5) 或合并稀疏类别
3. **CA 对行/列顺序敏感**: 依赖否 — 不，但只要不改变类别分组顺序就一致

## 失效条件/反例 (强制小节)

- **条件1: 列联表过于稀疏 (> 50% 单元格为零) + 小样本** → 表现: Chi-square 近似不可靠 ($\chi^2$ 检验失效)，对应分析的惯量被稀疏单元格主导 (每个零单元格贡献大 chi-square 残差) → 双标图中孤立点支配整个分析。**应对**: 合并稀疏类别使每格期望频率 > 1 或 > 5，或使用 Bayesian CA (Dirichlet 先验)
- **条件2: 类别数 I 或 J 极大 (> 50) + 仅用 2D** → 表现: 前两维的惯量占比 < 30% → 双标图仅展示总关联的小部分，遗漏的关键结构在更高维度。**应对**: 检查累积惯量占比，若 < 70% 则需探索 3D 图或多重对应分析 (MCA)

## 文献

1. Greenacre M. (2017). *Correspondence Analysis in Practice*, 3rd ed. CRC Press. ISBN: 978-1498731775
2. Benzecri J.P. (1973). *L'Analyse des Donnees*. Dunod. (对应分析的创始)

## 来源溯源

自写 correspondence_analysis.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0504 (PCA) |
| 组合 | PARADIGM-0513 (MANOVA) |
| 组合 | PARADIGM-0501 (预处理) |
