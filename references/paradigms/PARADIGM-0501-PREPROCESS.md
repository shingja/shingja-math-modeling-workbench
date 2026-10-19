# PARADIGM-0501 数据预处理 (normalize/fillmissing)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0501 |
| 类别/子类 | ⑤统计 / 数据预处理 |
| 难度 | 低 |
| 适用题型关键词[] | 数据预处理, 缺失值, 标准化, 归一化, fillmissing, normalize, 异常处理, 清洗, 无量纲化, 特征缩放 |
| confidence | high |
| source | Han et al.(2012) Data Mining: Concepts and Techniques, 3rd Edition, Morgan Kaufmann |

## 数学形式

**Z-score 标准化 (Standardization)**:
$$z = \frac{x - \mu}{\sigma}$$

其中 $\mu$ 为样本均值, $\sigma$ 为样本标准差。标准化后数据均值为 0, 标准差为 1。

**Min-Max 归一化 (Normalization)**:
$$x' = \frac{x - x_{\min}}{x_{\max} - x_{\min}}$$

将数据线性映射到 $[0, 1]$ 区间。可扩展为 $[a, b]$: $x' = a + \frac{(x - x_{\min})(b - a)}{x_{\max} - x_{\min}}$。

**缺失值填补策略**:
- 均值填补: $\hat{x}_{\text{miss}} = \bar{x}_{\text{obs}}$
- 中位数填补: $\hat{x}_{\text{miss}} = \text{median}(x_{\text{obs}})$
- KNN 插值: 基于 $k$ 个最近邻的加权平均
- 线性插值: $\hat{x}_t = x_{t-1} + \frac{x_{t+k} - x_{t-1}}{k+1}$ (等间隔序列)
- 样条插值: cubic spline / pchip

**Robust Scaler**: $x' = \frac{x - Q_2}{Q_3 - Q_1}$, 用中位数和 IQR 替代均值和标准差, 对异常值鲁棒。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| method (normalize) | string | 'zscore' | zscore/range/scale/center/norm | 中 — 影响分布形态 |
| method (fillmissing) | string | 'linear' | linear/nearest/next/previous/spline/pchip/movmean/constant | 高 — 决定插值合理性 |
| dim | integer | 1 | 1/2 | 低 |
| DataVariables | string[] | all | 指定列名 | 中 |
| k (KNN) | integer | 5 | 1~sqrt(n) | 中 — 过小噪声大, 过大平滑 |

- 时间复杂度: normalize $O(n)$, fillmissing linear $O(n)$, KNN $O(n^2)$
- 空间复杂度: $O(n)$
- 量纲: 标准化后无量纲; Min-Max 后无量纲; 插值保持原量纲

## MATLAB 实现

```matlab
% ===== 标准化 =====
X_zscore = normalize(X);                     % 默认 Z-score, 按列
X_range  = normalize(X, 'range');            % Min-Max 到 [0,1]
X_center = normalize(X, 'center');           % 仅去均值
X_scale  = normalize(X, 'scale', 'first');   % 除以第一行

% ===== 缺失值处理 =====
% 先检测缺失
ismissing(X);                                % 返回逻辑矩阵
summary(X);                                  % 查看缺失统计

% 填补方法
X_filled = fillmissing(X, 'linear');         % 线性插值 (默认)
X_filled = fillmissing(X, 'movmean', 5);     % 5点移动平均
X_filled = fillmissing(X, 'nearest');        % 最近邻
X_filled = fillmissing(X, 'spline');         % 三次样条
X_filled = fillmissing(X, 'pchip');          % 保形分段三次
X_filled = fillmissing(X, 'constant', 0);    % 常数填补

% 按列不同策略
X_filled = fillmissing(X, 'linear', 'DataVariables', [1 3 5]);
X_filled = fillmissing(X, 'constant', 0, 'DataVariables', 2);

% ===== 异常值替换为缺失再填补 =====
[~, idx] = isoutlier(X, 'mean');
X_clean(idx) = NaN;
X_clean = fillmissing(X_clean, 'linear');
```

## Python 备选

```python
from sklearn.preprocessing import StandardScaler, MinMaxScaler, RobustScaler
from sklearn.impute import SimpleImputer, KNNImputer
import pandas as pd

# Z-score
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Min-Max
scaler = MinMaxScaler(feature_range=(0, 1))
X_norm = scaler.fit_transform(X)

# Robust Scaler
scaler = RobustScaler()
X_robust = scaler.fit_transform(X)

# 缺失值
imp = SimpleImputer(strategy='median')
X_filled = imp.fit_transform(X)

knn_imp = KNNImputer(n_neighbors=5)
X_filled = knn_imp.fit_transform(X)

# pandas
df.fillna(method='ffill')
df.interpolate(method='cubic')
```

## 选型决策树

```
数据有缺失?
  ├─ 是 → 缺失比例?
  │        ├─ <5%  → 直接删除 (rmmissing)
  │        ├─ 5-20% → fillmissing('linear'/'knn')
  │        └─ >20% → 考虑删除该特征或用模型预测填补
  └─ 否 → 需要缩放?
           ├─ 是 → 算法依赖距离?
           │        ├─ 是 (KNN/SVM/NN) → normalize('zscore') 或 RobustScaler
           │        └─ 否 (树模型) → 可不缩放
           └─ 否 → 仅去量纲 → normalize('range')
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 预处理前 | 箱线图 (boxplot) | 展示各特征原始分布, 含异常值 |
| 预处理前 | 缺失值热力图 | imagesc(ismissing(X)), 白色=缺失 |
| 预处理后 | 叠加密度图 / 直方图 | 验证标准化后均值≈0, 标准差≈1 |
| 预处理后 | QQ图 | 检验标准化后是否接近正态 |

## 常见坑

1. **数据泄漏 (Data Leakage)**: 在训练集上计算 $\mu$ 和 $\sigma$, 然后用同样的参数标准化测试集, 不可在全体数据上先标准化再划分。
2. **哑变量/One-Hot 列不应标准化**: 0/1 编码列标准化后失去可解释性。
3. **缺失值盲目填均值**: 当缺失机制为 MNAR (Not Missing At Random), 均值填补会引入系统偏差, 使回归系数向零收缩。
4. **Min-Max 对异常值敏感**: 若数据包含极端离群点, $x_{\max} - x_{\min}$ 被拉大, 99% 数据被压缩到极小区间。
5. **线性插值在边界处外推**: fillmissing('linear') 在首尾缺失时退化为 nearest, 可能不合理。

## 失效条件/反例 (强制小节)

- **条件1 — 测试集用训练集统计量做标准化 → 数据泄漏, 评估偏乐观**: 若先用全体数据做 Z-score 再划分训练/测试集, 则测试集信息已通过 $\mu$ 和 $\sigma$ 泄漏到训练中。正确做法: 仅在训练集上 `fit`, 再用同样的 `Scaler` 去 `transform` 测试集。使用 `normalize` 时需保存训练集统计参数。
- **条件2 — 缺失机制非随机 (MNAR) → 任何单值插补产生系统偏差**: 如果数据缺失的概率依赖于缺失值本身 (如高收入者更不愿报告收入), 用均值/中位数/众数填补会系统性地偏向低值, 导致下游回归/分类产生有偏推断。此时需用多重插补 (Multiple Imputation) 或 pattern-mixture 模型。
- **条件3 — Min-Max 对异常值极度敏感 → 一个极端值压扁整个分布**: 若特征中有一个值为其余值的 100 倍, Min-Max 归一化后, 除该异常点外所有数据被压缩到 [0, 0.01], 丧失区分度。此时应先用 isoutlier 处理或改用 RobustScaler。

## 文献

1. Han, J., Kamber, M., & Pei, J. (2012). *Data Mining: Concepts and Techniques* (3rd ed.). Morgan Kaufmann. Chapter 3: Data Preprocessing.
2. Little, R. J. A., & Rubin, D. B. (2019). *Statistical Analysis with Missing Data* (3rd ed.). Wiley.
3. van Buuren, S. (2018). *Flexible Imputation of Missing Data* (2nd ed.). Chapman & Hall/CRC.
4. MATLAB Documentation: `normalize`, `fillmissing`, `rmmissing`, `isoutlier`.

## 来源溯源

- 原始来源: 数据预处理方法论源自数据库与数据挖掘领域, Han et al. 的教材是标准参考
- MATLAB 实现: normalize/fillmissing 在 R2019b 中引入, 属基础函数无需额外工具箱
- 统计理论基础: 标准化源于 Fisher 的 Z-transformation; IQR 填补源于 Tukey 的探索性数据分析

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 — 异常值检测 | PARADIGM-0502 |
| 后置 — 特征降维 | PARADIGM-0507 (PCA) |
| 后置 — 缺失值场景下的分布拟合 | PARADIGM-0503 |
| 后置 — 所有需要输入缩放的模型 | PARADIGM-0401~0440 (机器学习类) |
