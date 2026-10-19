# PARADIGM-0502 异常值检测 (isoutlier/boxplot)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0502 |
| 类别/子类 | ⑤统计 / 异常检测 |
| 难度 | 低 |
| 适用题型关键词[] | 异常值, 箱线图, IQR, isoutlier, Tukey, 离群点, 四分位数, outlier detection, 数据审核, 异常检测 |
| confidence | high |
| source | Tukey, J.W. (1977) *Exploratory Data Analysis*, Addison-Wesley |

## 数学形式

**Tukey 箱线图法 (IQR 法)**:
$$\text{IQR} = Q_3 - Q_1$$
$$\text{下内限 (Lower Inner Fence)} = Q_1 - 1.5 \times \text{IQR}$$
$$\text{上内限 (Upper Inner Fence)} = Q_3 + 1.5 \times \text{IQR}$$
$$\text{下外限 (Lower Outer Fence)} = Q_1 - 3.0 \times \text{IQR}$$
$$\text{上外限 (Upper Outer Fence)} = Q_3 + 3.0 \times \text{IQR}$$

其中 $Q_1$ 为第 25 百分位数, $Q_3$ 为第 75 百分位数, IQR 为四分位距。落在内限与外限之间的点为**温和异常值** (mild outlier), 落在外限之外为**极端异常值** (extreme outlier)。

**均值-标准差法 (Mean-SD)**:
$$|x_i - \bar{x}| > k \cdot s$$

通常 $k=3$ (三倍标准差法则), 适用于数据近似正态分布的情形。对于正态分布, 约 99.73% 的数据落在 $\mu \pm 3\sigma$ 内。

**Grubbs 检验 (单异常值)**:
$$G = \frac{\max_i |x_i - \bar{x}|}{s}$$

检验统计量 $G$ 与临界值 $G_{\alpha,n}$ 比较。Grubbs 检验假设数据来自正态分布, 每次只能检测一个异常值。

**广义 ESD (GESD) 检验 (多异常值)**:
设检验异常值数上限为 $r$, 依次对 $k = 1, 2, \ldots, r$ 执行 Grubbs 型检验:
$$R_k = \frac{\max_i |x_i - \bar{x}^{(k-1)}|}{s^{(k-1)}}$$

其中 $\bar{x}^{(k-1)}$ 和 $s^{(k-1)}$ 为去除前 $k-1$ 个候选异常值后的均值和标准差。

**Madout (基于中位数绝对偏差)**:
$$\text{MAD} = \text{median}_i(|x_i - \text{median}(x)|)$$
异常值判定: $|x_i - \text{median}(x)| > k \cdot \text{MAD}$，其中 $k$ 通常取 3。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| method (isoutlier) | string | 'median' | median/mean/quartiles/grubbs/gesd/movmedian | 高 — 选定检测策略 |
| threshold | numeric | 自动 | method-dependent | 中 — 过高漏检, 过低误杀 |
| MaxNumOutliers (GESD) | integer | 10 | 1~n | 高 — 设定上限 |
| whisker (boxplot) | numeric | 1.5 | 0.5~3.0 | 中 — 1.5 为 Tukey 标准 |
| DataVariables | string[] | all | 列名 | 低 |

- 时间复杂度: IQR 法 $O(n \log n)$ (排序); Grubbs $O(n)$; GESD $O(rn)$
- 空间复杂度: $O(n)$
- 输入量纲: 任意; 输出为逻辑索引或异常分数

## MATLAB 实现

```matlab
% ===== isoutlier 基础用法 =====
% IQR 法 (默认 'median')
[out, idx] = isoutlier(X);                  % 逻辑向量 + 索引
X_clean = X(~out);                          % 直接去除

% 均值-标准差法
[out, ~] = isoutlier(X, 'mean');            % 超过3σ标记为异常

% Grubbs 检验
[out, ~] = isoutlier(X, 'grubbs');

% GESD — 需指定最大异常点数
[out, ~] = isoutlier(X, 'gesd', 'MaxNumOutliers', 5);

% 移动中位数法 (时序异常)
[out, ~] = isoutlier(X, 'movmedian', 10);   % 10点窗

% 分位数法
[out, ~] = isoutlier(X, 'quartiles');        % Q1-1.5IQR, Q3+1.5IQR

% ===== 按列操作 =====
[out, ~] = isoutlier(X, 'mean', 'DataVariables', {'x1', 'x3'});

% ===== boxplot 可视化 =====
boxplot(X);                                  % 默认 whisker=1.5
boxplot(X, 'Whisker', 1.5);                 % Tukey 标准
boxplot(X, 'Whisker', 3.0);                 % 更保守的阈值

% ===== 替代异常值 =====
X_filled = filloutliers(X, 'linear');        % 线性插值替代
X_filled = filloutliers(X, 'center', 'mean');% 用均值替代
X_filled = filloutliers(X, 'clip');          % 截断到阈值边界

% ===== MAD 自写 =====
med = median(X, 'omitnan');
mad = median(abs(X - med), 'omitnan');
is_out = abs(X - med) > 3 * mad;
```

## Python 备选

```python
from scipy import stats
import numpy as np

# Z-score
z = np.abs(stats.zscore(X))
outliers = z > 3

# IQR
Q1 = np.percentile(X, 25, axis=0)
Q3 = np.percentile(X, 75, axis=0)
IQR = Q3 - Q1
outliers = (X < Q1 - 1.5*IQR) | (X > Q3 + 1.5*IQR)

# Isolation Forest (多维)
from sklearn.ensemble import IsolationForest
iso = IsolationForest(contamination=0.05)
pred = iso.fit_predict(X)  # -1 = outlier
```

## 选型决策树

```
数据分布已知?
  ├─ 近似正态, n>30 → 'mean' (3σ法) 或 'grubbs'
  ├─ 非正态/未知 → 'median' (IQR法) 或 MAD
  └─ 需要多异常值检测:
       ├─ 已知异常点数上限 → 'gesd'
       └─ 未知 → 迭代 'median' 或使用 IsolationForest (Python)
时序数据? → 'movmedian' 或 'movmean'
多维数据? → 逐维 isoutlier + 逻辑或, 或 Mahalanobis 距离
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 检测前 | boxplot | 直观展示 Q1/Q2/Q3/IQR/须线/离群点分布 |
| 检测前 | 散点图 | 时序数据用 scatter 观察可疑跳跃点 |
| 检测后 | 标注箱线图 | 在 boxplot 上用不同颜色标注检测到的异常点 |
| 检测后 | 分布叠加图 | histogram + 异常值标记线, 展示异常值相对位置 |

## 常见坑

1. **正态假定误用**: 数据呈偏态或厚尾分布时, 'mean' 法 (3σ) 会将大量正常数据误判为异常 (假阳性率远大于 0.3%)。
2. **掩蔽效应 (Masking)**: 多个异常值同时存在会使样本均值向异常方向偏移, 标准差膨胀, 导致 Grubbs/mean 法无法检出每个异常值 — 这是 GESD 的设计动机。
3. **沼地效应 (Swamping)**: 阈值过严 (如 whisker=1.0) 导致大量正常点被误标为异常。
4. **异常值处理决策不明**: 检测后是删除、截断还是插值需要根据业务含义判断, 不应无脑删除。竞赛中可能正是"异常"反映了重要机制。
5. **多维异常检测的单变量局限**: 逐个维度检测会漏掉在每一维均正常但联合分布偏离的异常点 (如椭圆分布边缘)。

## 失效条件/反例 (强制小节)

- **条件1 — 数据非单峰对称 → 基于正态假定的方法误判大量正常点为异常**: 若数据呈指数分布或幂律分布, 'mean' (3σ) 法会将右尾大量正常长尾数据标记为异常, 假阳性率可超过 10%。此时应改用 'median' (IQR 法) 或 MAD 法 — 两者仅依赖分位数, 对分布无假定。对于偏态数据 Grubbs 检验同样失效, 因为其临界值以正态分布推导。
- **条件2 — 异常值比例 >5% → GESD 预设上限不足或过度**: GESD 要求预先指定异常点数上限 r。若实际异常数远超 r, 剩余异常值会留在数据中未被标记 (掩蔽效应持续); 若 r 设置过大, 过多正常点被误判为异常。当异常比例不可预知时, 建议先用 IQR 法做初步筛查, 再根据箱线图判断异常比例设定 r。
- **条件3 — 多维异常 → 单变量方法系统漏检**: 对于二元正态分布的椭圆形轮廓, 边缘点在 $X_1$ 维度上不异常、在 $X_2$ 维度上也不异常, 但联合来看偏离了整体椭圆。逐维 isoutlier 会返回空集, 而 Mahalanobis 距离 $D_M = \sqrt{(x-\mu)^T\Sigma^{-1}(x-\mu)}$ 可以捕获此类点。数学建模中若涉及多维特征相关性, 需补充多维方法。

## 文献

1. Tukey, J. W. (1977). *Exploratory Data Analysis*. Addison-Wesley. (箱线图和须线的原始定义)
2. Grubbs, F. E. (1969). Procedures for Detecting Outlying Observations in Samples. *Technometrics*, 11(1), 1-21.
3. Rosner, B. (1983). Percentage Points for a Generalized ESD Many-Outlier Procedure. *Technometrics*, 25(2), 165-172.
4. Rousseeuw, P. J., & Hubert, M. (2011). Robust Statistics for Outlier Detection. *WIREs Data Mining and Knowledge Discovery*, 1(1), 73-79.
5. MATLAB Documentation: `isoutlier`, `filloutliers`, `boxplot`.

## 来源溯源

- 原始来源: Tukey (1977) 提出的箱线图及其须线规则 (1.5*IQR) 至今仍是异常值检测的工业标准
- Grubbs 检验源于 Grubbs (1950, 1969) 对样本极值检验的推导, ESD 由 Rosner (1983) 推广
- MATLAB 实现: `isoutlier` 在 R2017a 中引入, 属 Statistics and Machine Learning Toolbox 基础函数
- MAD 法由 Hampel (1974) 提出, 崩溃点 (breakdown point) 高达 50%, 对异常值极其鲁棒

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 — 数据预处理标准化 | PARADIGM-0501 |
| 后置 — 缺失值处理 (将异常值设为 NaN 再填补) | PARADIGM-0501 |
| 后置 — 分布拟合 (去除异常后拟合) | PARADIGM-0503 |
| 互补 — 多维异常检测 (Mahalanobis/IsolationForest) | PARADIGM-0420 (Anomaly Detection) |
