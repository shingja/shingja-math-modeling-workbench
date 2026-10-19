# PARADIGM-1003-RSM 多项式响应面⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1003-RSM |
| 类别/子类 | ⑩代理模型 / 参数化代理 |
| 难度 | 低 |
| 适用题型关键词[] | 响应面, 多项式回归, 设计实验, 参数敏感性, 因子筛选 |
| confidence | high |
| source | 教材第10章 / 文献2007_RSM / 题解反推_DoE类 |

## 数学形式

**二阶多项式响应面模型**:
$$\hat{y}(\mathbf{x}) = \beta_0 + \sum_{i=1}^{d} \beta_i x_i + \sum_{i=1}^{d} \beta_{ii} x_i^2 + \sum_{i<j} \beta_{ij} x_i x_j + \varepsilon$$

**矩阵形式**:
$$\hat{\mathbf{y}} = \mathbf{X}\boldsymbol{\beta}, \quad \boldsymbol{\hat{\beta}} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{y}$$

**设计矩阵 $\mathbf{X}$** 包含: 1 (截距), $x_i$ (主效应), $x_i^2$ (二次), $x_i x_j$ (交互)

**DoE (实验设计) 方法**:
- Central Composite Design (CCD): $2^d$ 阶乘 + $2d$ 轴点 + $n_c$ 中心点
- Box-Behnken Design (BBD): 适合 $3 \leq d \leq 7$, 无角点, 更经济
- Latin Hypercube Sampling (LHS): 空间填充, 适用计算机实验

| 变量 | 含义 | 典型值 |
|------|------|--------|
| $d$ | 输入维数 | 2-10 |
| $p$ | 多项式项数 | $1 + 2d + \binom{d}{2}$ (二阶) |
| $\boldsymbol{\beta}$ | 回归系数 | — |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 多项式阶数 | int | 2 | 1/2/3 | 高—3阶项数爆炸 (交互项) |
| DoE 设计 | enum | CCD | CCD/BBD/LHS | 中—BBD 无边界点, 外推差 |
| 逐步回归 | bool | true | — | 高—消除不显著项 |
| 交互项包含 | bool | true | — | 中 |
| $p$ 值阈值 (保留项) | float | 0.05 | 0.01-0.15 | 中 |

**时间复杂度**: $O(p^3)$ (OLS) + DoE 生成
**空间复杂度**: $O(p^2)$

## MATLAB 实现

```matlab
% 使用 fitlm + 多项式特征扩展
% 二阶 RSM (含交互项)
mdl = fitlm(X, y, 'quadratic');  % 自动包含主效应+二次+交互

% 或手动构造设计矩阵
X_design = [ones(n,1), X, X.^2];  % 仅含主效应+二次 (无交互)
for i = 1:d-1
    for j = i+1:d
        X_design = [X_design, X(:,i).*X(:,j)];  % 交互项
    end
end
mdl = fitlm(X_design, y);

% 响应面可视化
% 固定其余变量为中位数, 网格化两个变量, predict + surf
```

**锚点工具箱**: `fitlm` (Statistics and Machine Learning Toolbox)
**DoE 生成**: `bbdesign`/`ccdesign` (Statistics Toolbox) 或 `lhsdesign` (Statistics Toolbox)

## Python 备选

```python
import numpy as np
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
import statsmodels.api as sm

poly = PolynomialFeatures(degree=2, include_bias=False)
X_poly = poly.fit_transform(X)
model = sm.OLS(y, sm.add_constant(X_poly)).fit()
# model.summary()  # 完整统计报告 (p值, R², AIC等)
```

DoE: `pyDOE2` (CCD/BBD/LHS)

## 选型决策树

- **$d \leq 6$ + 函数假设为平滑多项式** → RSM (最简单, 可解释)
- **$d > 10$ + 大量交互** → RSM 项数爆炸 ($p \approx 100+$), 需大量样本或降维 → 换 RBF 代理 (PARADIGM-1004) 或 GPR (PARADIGM-1001)
- **因子筛选 (识别重要因子)** → RSM 一阶模型 + 方差分析 (ANOVA), 快速识别关键因子
- **对光滑性没把握** → RSM 外推风险大 (多项式发散) → 换 GPR (带不确定性量化)
- **非线性强 + 局部突变** → RSM 多项式拟合不足 → 换 RBF 或 GPR

## 典型图型

- **raw**: DoE 设计点分布 (散点矩阵)
- **process**: 响应面 3D 图 (两变量变动, 其余固定), 等高线图; 残差 vs 预测值 (诊断)
- **result**: Pareto 效应图 (各因子的标准化效应排序), 预测 vs 实际

## 常见坑

1. **项数爆炸**: 二阶含交互 $p = 1 + d + d + d(d-1)/2 = 1 + 2d + \binom{d}{2}$; $d=10 \rightarrow p=66$, 需要至少 $p$ 个样本 → 用逐步回归或 LASSO 缩减
2. **外推灾难**: 多项式在训练域外导致 $y \rightarrow \pm \infty$ 快速发散 → RSM 仅用于插值
3. **高次项对数据过拟合**: 三阶及以上 $R^2$ 极高但预测差 → 用 $R^2_{\text{adj}}$ 或 $Q^2$ (留一交叉验证)
4. **DoE 设计不适应约束域**: CCS 角点可能落在不可行区域 → 用 LHS + 约束筛选

## ⚠️ 数值卫生必查

1. **RSM 系数在标准化空间时不可物理解释**。若输入做过 StandardScaler，系数 $\beta_i$ 的单位与原始物理量纲脱钩，论文输出表必须加 NOTE 列说明"系数为标准化空间取值"，或另附原始空间换算结果。
2. **R² 必须报 train/test 双列 + LOOCV**。训练集 R² 禁止写进论文当泛化性能；报告格式: $R^2_{\text{train}}$ / $R^2_{\text{test}}$ / $Q^2$ (LOOCV) 三值并列，模型选择与结论只依据 test/LOOCV。
3. **高次 RSM 外推风险: 训练域空白组合禁止外推**。离散变量零样本区域（如 DoE 中未覆盖的等级组合）、训练凸包外的高次项区域，多项式会快速发散；必须物理耦合约束（如守恒律、单调性）裁剪预测域，并在论文中声明外推边界。

## 失效条件/反例 (强制小节)

- **条件1**: $d > 10$ (高维) → 二阶 RSM 项数超过 66, 需 >66 个训练点, 且多项式无法捕获高维非线性; 相互作用项过多, 多重共线性严重。**替代**: RBF 代理 (PARADIGM-1004) 或稀疏 GP, 或先降维后 RSM
- **条件2**: 目标函数有阶跃/不连续性 → 全局多项式模型在间断点附近 Gibbs 振荡, 残差极大。**替代**: 分段 RSM (样条) 或树模型
- **条件3**: 训练点在输入空间集中 (单簇) → RSM 内插好但稍有外推即发散; 且中心点附近拟合好, 边界点差。**替代**: 均匀采样 (LHS) + 保守用 RSM, 或换 RBF
- **条件4**: 响应含大量噪声 ($R^2 < 0.5$) → RSM 固有偏差大, 代理价值低, 预测极不可靠。**替代**: GPR (含噪声建模), 或增加重复实验降噪

## 文献

1. Box, G. E. P., & Draper, N. R. (2007). *Response Surfaces, Mixtures, and Ridge Analyses* (2nd ed.). Wiley. ISBN: 978-0-470-05357-7.
2. Myers, R. H., Montgomery, D. C., & Anderson-Cook, C. M. (2016). *Response Surface Methodology: Process and Product Optimization Using Designed Experiments* (4th ed.). Wiley. ISBN: 978-1-118-91601-8.

## 来源溯源

- 教材源路径: 实验设计与响应面方法
- 论文三元组: Box 1951, RSM, experimental design + polynomial approximation
- 教学用例: 工艺参数优化, 配方法优化

## 关联范式卡

组合: ANOVA (因子显著性检验, 内置在 `fitlm`), DoE (实验设计)
替代: PARADIGM-1001-GPR (非线性+不确定性), PARADIGM-1004-RBF-SURROGATE (高维非线性)
