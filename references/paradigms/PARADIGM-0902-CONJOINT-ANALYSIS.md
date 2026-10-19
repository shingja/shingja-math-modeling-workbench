# PARADIGM-0902 联合分析Conjoint Analysis⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0902 |
| 类别/子类 | ⑨经典与杂项 / 市场研究 |
| 难度 | 中 |
| 适用题型关键词[] | 联合分析, Conjoint Analysis, 偏好测量, 效用, 部分值, 属性重要性, Green&Srinivasan |
| confidence | medium |
| source | Green & Srinivasan (1978) J Consumer Research |

## 数学形式

**模型 (加法效用模型):**
$$U_i = \sum_{j=1}^{J} \sum_{k=1}^{L_j} \beta_{jk} x_{ijk} + \varepsilon_i$$

- $U_i$ — 消费者对第 $i$ 个产品轮廓 (Profile) 的效用
- $j$ — 属性 (如价格、品牌、尺寸)
- $k$ — 属性 $j$ 的水平 (Level)
- $\beta_{jk}$ — 部分值 (Part-Worth)，即水平 $k$ 对效用的贡献
- $x_{ijk} = 1$ 若轮廓 $i$ 在属性 $j$ 上取水平 $k$，否则 0

**估计 (Ordinary Least Squares, 从评分/排序):**
$$\hat{\boldsymbol{\beta}} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{U}$$

**属性重要性 (Importance Weight):**
$$I_j = \frac{\max_k \beta_{jk} - \min_k \beta_{jk}}{\sum_{j=1}^{J} (\max_k \beta_{jk} - \min_k \beta_{jk})} \times 100\%$$

**Logit 选择模型 (MNL, 从选择数据):**
$$P(\text{选轮廓 } i) = \frac{e^{U_i}}{\sum_{m} e^{U_m}}$$

**三种数据收集类型:**
1. **全轮廓法 (Full Profile):** 消费者对完整轮廓评分/排序
2. **选择型联合分析 (CBC):** 二选一或多选
3. **自适应联合分析 (ACA):** 计算机逐轮调整

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 属性数 J | int | 5 | [3, 10] | 高 — J>10认知负担大 |
| 水平数 L_j | int | 3 | [2, 10] | 高 — 参数随L_j增长 |
| 轮廓数 N | int | 16 | [8, 30] | 高 — N太小不能估计 |
| 估计方法 | — | OLS | OLS / MNL / HB | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[partworths, importance, model_fit] = conjoint_analysis(profiles, ratings, att_levels)
% profiles: N×sum(L_j) 设计矩阵 (0/1 编码)
% ratings: N×1 偏好评分
% partworths: 各水平的效用贡献
```

锚点: 自写-见S5:conjoint_analysis.m

```matlab
function [beta, importance, R2] = conjoint_analysis(X, ratings, n_levels)
    % X: N × sum(n_levels) 的设计矩阵
    % 使用 effects coding 或 dummy coding
    
    % OLS 估计
    beta = X \ ratings;
    
    % 属性重要性
    n_att = length(n_levels);
    ranges = zeros(n_att, 1);
    cum_idx = 0;
    for j = 1:n_att
        idx = cum_idx + (1:n_levels(j));
        ranges(j) = max(beta(idx)) - min(beta(idx));
        cum_idx = cum_idx + n_levels(j);
    end
    importance = ranges / sum(ranges) * 100;
    
    % 模型拟合
    pred = X * beta;
    R2 = 1 - sum((ratings - pred).^2) / sum((ratings - mean(ratings)).^2);
end
```

## Python 备选

```python
# statsmodels / 自写 OLS
import numpy as np
beta = np.linalg.lstsq(X, ratings, rcond=None)[0]
```

## 选型决策树

- **联合分析** — 测量消费者对产品多属性的偏好，评估属性重要性
- **AHP (PARADIGM-0301)** — 更通用的多准则决策 (不限于产品属性)
- **离散选择实验 DCE** — 基于选择而非评分，更接近真实决策行为
- **MaxDiff (BWS)** — 仅关心最/最不偏好水平 (简化版)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | 部分值柱状图 (每属性一组) | 展示各水平贡献 |
| result | 属性重要性饼图/条形图 | 各属性相对重要度 |

## 常见坑

1. **设计矩阵不满秩**: 使用 dummy coding 时 $\mathbf{X}^T\mathbf{X}$ 奇异 → 使用 effects coding (和为0约束)
2. **受访者疲劳**: 轮廓数 > 20 → 评分质量下降 → 使用自适应或部分因子设计
3. **忽略交互效应**: 加法模型 $U = \sum$ 假设属性独立 → 若存在强交互 (如品牌×价格)，需加入交互项

## 失效条件/反例 (强制小节)

- **条件1: 属性太多 (J > 15) → 全轮廓法认知超载** → 表现: 受访者无法同时评估 15+ 个属性 → 评分变随机，模型 R² < 0.3, 部分值不具有可解释的模式。**应对**: 使用 ACA (自适应联合分析) 或降属性 (先做定性研究筛选关键属性至 J≤7)
- **条件2: 受访者群体高度异质 (如不同年龄段偏好完全不同)** → 表现: 聚合 OLS 模型将不同偏好的子群体混合 → 部分值是"平均值"不代表任何单个群体的真实偏好。**应对**: 使用潜类联合分析 (Latent Class) 或分层贝叶斯 (HB, Hierarchical Bayes) 估计个体级部分值

## 文献

1. Green P.E. & Srinivasan V. (1978). "Conjoint analysis in consumer research: Issues and outlook." *Journal of Consumer Research*, 5(2):103-123. DOI: [10.1086/208721](https://doi.org/10.1086/208721)
2. Louviere J.J., Hensher D.A. & Swait J.D. (2000). *Stated Choice Methods: Analysis and Applications*. Cambridge University Press. ISBN: 978-0521788304

## 来源溯源

自写 conjoint_analysis.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0301 (AHP) |
| 替代 | PARADIGM-1206 (BWM) |
| 组合 | PARADIGM-0609 (逻辑回归, MNL) |
