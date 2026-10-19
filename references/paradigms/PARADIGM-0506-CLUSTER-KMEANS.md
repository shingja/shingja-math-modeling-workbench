# PARADIGM-0506 K-Means聚类⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0506 |
| 类别/子类 | ⑤统计与数据分析 / 聚类 |
| 难度 | 低 |
| 适用题型关键词[] | K-Means, 聚类, 无监督学习, 质心, 肘部法则, 轮廓系数, 数据分组 |
| confidence | high |
| source | matlab/cluster/kmeans_cluster.m |

## 数学形式

**优化目标**（簇内平方和最小化）：
$$J = \sum_{i=1}^{k} \sum_{x \in C_i} \|x - \mu_i\|^2$$

其中 $C_i$ 为第 $i$ 个簇（点集），$\mu_i$ 为第 $i$ 个簇的质心。

**Lloyd 算法**（标准 K-Means）：
1. **分配步 (Assignment)**：每个点分配给最近质心
   $$C_i^{(t)} = \left\{x_p : \|x_p - \mu_i^{(t)}\|^2 \leq \|x_p - \mu_j^{(t)}\|^2, \; \forall j \neq i\right\}$$

2. **更新步 (Update)**：重新计算质心
   $$\mu_i^{(t+1)} = \frac{1}{|C_i^{(t)}|} \sum_{x \in C_i^{(t)}} x$$

**收敛性**：$J^{(t+1)} \leq J^{(t)}$（单调递减），收敛到局部最优（有限个划分）。

**K-Means++ 初始化**（默认）：
- 随机选第一个质心
- 后续质心以 $D(x)^2$ 为概率抽样，$D(x)$ 为到最近已选质心的距离

**模型选择指标**：

肘部法则 (Elbow) — 检查 $J(k)$ 曲线弯曲点。

轮廓系数 (Silhouette)：
$$s(i) = \frac{b(i) - a(i)}{\max\{a(i), b(i)\}}$$

其中 $a(i)$ 为点 $i$ 到同簇其他点的平均距离（凝聚度），$b(i)$ 为点 $i$ 到最近邻簇所有点的平均距离（分离度）。整体轮廓系数 $\bar{s} = \frac{1}{n} \sum_i s(i)$。

Gap 统计量：
$$\text{Gap}(k) = \mathbb{E}[\log W_k^{\text{ref}}] - \log W_k$$

其中 $W_k$ 为簇内平方和，ref 为均匀分布参考数据。

**变量表**：
| 符号 | 含义 | 维度 |
|------|------|------|
| $X$ | 数据矩阵 | $n \times p$ |
| $k$ | 簇数 | 标量 |
| $C_i$ | 第 $i$ 个簇 | 点集 |
| $\mu_i$ | 第 $i$ 个簇的质心 | $1 \times p$ |
| $J(k)$ | 簇内平方和 (inertia) | 标量 |
| $s(i)$ | 轮廓系数 | $[-1, 1]$ |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| `X` | double matrix | — | $n \times p$, 连续变量最佳 | 高（须标准化） |
| `k` | int | — | $2 \leq k \leq n-1$ | **极高**（核心超参，错则废） |
| `Replicates` | int | 10 | $1 \sim 50$ | 中（影响全局最优概率） |
| `Distance` | string | `'sqeuclidean'` | sqeuclidean / cityblock / cosine | 高（决定簇形状假设） |
| `MaxIter` | int | 200 | $\geq 10$ | 低 |
| `Start` | string | `'plus'` | plus / sample / cluster / matrix | 中（k-means++ 通常最优） |

**时间复杂度**：$O(n \cdot k \cdot p \cdot t)$（$t$ 为迭代次数，通常 $t \ll n$）
**空间复杂度**：$O(np) + O(kp)$

## MATLAB 实现

函数签名：
```matlab
[idx, C, sumd, D] = kmeans_cluster(X, k, 'Replicates', 10, 'Distance', 'sqeuclidean', 'MaxIter', 200)
```

锚点工具箱函数：`kmeans` (Statistics and Machine Learning Toolbox)

实现位置：`matlab/cluster/kmeans_cluster.m`

```matlab
function [idx, C, sumd, D] = kmeans_cluster(X, k, varargin)
    % K-Means clustering wrapper with diagnostics
    % X: n×p data matrix
    % k: number of clusters
    % Returns: idx (cluster assignment), C (centroids),
    %          sumd (within-cluster sums), D (point-to-centroid distances)
    
    p = inputParser;
    addParameter(p, 'Replicates', 10);
    addParameter(p, 'Distance', 'sqeuclidean');
    addParameter(p, 'MaxIter', 200);
    parse(p, varargin{:});
    
    % Standardize
    X_std = zscore(X);
    
    % K-Means with k-means++ initialization
    [idx, C, sumd, D] = kmeans(X_std, k, ...
        'Replicates', p.Results.Replicates, ...
        'Distance', p.Results.Distance, ...
        'MaxIter', p.Results.MaxIter, ...
        'Start', 'plus', ...
        'Display', 'off');
end
```

**模型选择辅助**：
```matlab
% Elbow curve
K_range = 1:10;
inertia = zeros(size(K_range));
for i = 1:length(K_range)
    [~, ~, sumd] = kmeans(X_std, K_range(i), 'Replicates', 5);
    inertia(i) = sum(sumd);
end
plot(K_range, inertia, '-o');

% Silhouette
sil_eval = evalclusters(X_std, 'kmeans', 'silhouette', 'KList', 2:10);
```

## Python 备选

```python
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score
import numpy as np

# Standardize
X_std = StandardScaler().fit_transform(X)

# K-Means
km = KMeans(n_clusters=k, init='k-means++', n_init=10, max_iter=300,
            random_state=42)
labels = km.fit_predict(X_std)
centroids = km.cluster_centers_
inertia = km.inertia_

# Elbow method
inertias = []
K_range = range(1, 11)
for k_test in K_range:
    km = KMeans(n_clusters=k_test, init='k-means++', n_init=10, random_state=42)
    km.fit(X_std)
    inertias.append(km.inertia_)

# Silhouette scores
sil_scores = []
for k_test in range(2, 11):
    km = KMeans(n_clusters=k_test, init='k-means++', n_init=10, random_state=42)
    labels = km.fit_predict(X_std)
    sil_scores.append(silhouette_score(X_std, labels))
```

大规模数据备选：
```python
from sklearn.cluster import MiniBatchKMeans
mbk = MiniBatchKMeans(n_clusters=k, batch_size=100, random_state=42)
labels = mbk.fit_predict(X_std)
```

## 选型决策树

```
连续特征？球状簇？大小相近？
├── 是 → K-Means ✓
│   ├── k 未知 → 肘部法 + 轮廓系数 + Gap统计量
│   ├── k 已知 → 直接使用
│   └── 数据量大 (>100k) → MiniBatchKMeans
├── 否 (非球状) → DBSCAN / 谱聚类
├── 否 (密度不均匀) → DBSCAN / OPTICS / HDBSCAN
├── 否 (概率分配需求) → 高斯混合模型 (GMM)
└── 否 (分类特征) → K-Modes / K-Prototypes
```

**替代算法对比**：
| 算法 | 适用场景 | 与 K-Means 区别 |
|------|----------|----------------|
| DBSCAN | 任意形状簇、含噪声 | 不需预设 $k$，基于密度 |
| GMM | 椭圆簇、软分配 | 概率隶属，含协方差结构 |
| 层次聚类 | 小数据、需树状图 | 不需预设 $k$，计算量大 |
| K-Medoids (PAM) | 含异常值 | 用实际点作中心，更鲁棒 |
| 谱聚类 | 复杂拓扑 | 基于图 Laplacian，可处理非凸簇 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 散点图（按假设分组着色） | 若真实标签已知，初步观察分离度 |
| raw | 配对散点图矩阵 (pairplot) | 多变量两两关系概览 |
| process | 肘部曲线 (inertia vs k) | 标注肘部拐点 $k^*$ |
| process | 轮廓系数 vs k 曲线 | 标注最大值点 |
| process | Gap 统计量 vs k | 标注首个满足 $\text{Gap}(k) \geq \text{Gap}(k+1) - \text{SE}_{k+1}$ 的 $k$ |
| result | 聚类散点图（前2个PC） | 颜色标记簇，$\blacktriangle$ 标记质心 |
| result | 轮廓图 (silhouette plot) | 每个点的轮廓值按簇排列，标注平均轮廓线 |
| result | 2D 散点 + 凸包 (convhull) | 展示各簇几何范围 |

## 常见坑

1. **$k$ 值选定主观**：错误 $k$ 导致无意义的划分 → 必须结合肘部法 + 轮廓系数 + 业务知识三重验证；$k=2$ 几乎总会有明显下降，需检查 $k \geq 3$ 后的趋势
2. **初始质心敏感**：单次运行可能陷入坏局部最优 → 始终设置 `Replicates` 或 `n_init` $\geq 10$
3. **异常值拉偏质心**：一个远离簇中心的点可将质心显著偏离 → 先用孤立森林或 Mahalanobis 检测异常值，或换用 K-Medoids (PAM)
4. **欧氏距离假设各项同性簇**：特征未缩放时量纲差异等同于权重差异 → 始终标准化
5. **高维诅咒**：$p > 100$ 时欧氏距离判别力下降，所有点趋于等距 → 先 PCA 降维（保留 $\sim 95\%$ 方差）再聚类
6. **空簇**：初始化或迭代中某质心无点分配 → 算法通常自动处理（重新初始化），但可能是 $k$ 过大或数据分离度过高的信号

## 失效条件/反例 (强制小节)

- **条件1：非球状簇（同心环、缠绕螺旋）** → **表现**：K-Means 将环状结构切割为扇形或饼形片段，不同环上的点被错误地合并在同一簇中；轮廓系数可能仍然中等（0.4-0.5），造成虚假的满意结果 → 使用 DBSCAN（$\epsilon$-邻域可追踪环结构）或谱聚类（基于图割可分离非凸区域）
- **条件2：簇大小严重不均** → **表现**：大簇被 K-Means 拆分，小簇被吞并；例：簇 A (1000 点) vs 簇 B (20 点) → K-Means 倾向于将簇 A 的部分点分配给簇 B 的质心附近以降低 $J$，但实际簇 B 消失了 → 使用 GMM（用完整协方差矩阵容纳不同形状/大小）或 DBSCAN（密度阈值不依赖簇大小）
- **条件3：高维数据 $p \gg \log n$** → **表现**：欧氏距离趋于无效（各点距离中位数趋近于常数），K-Means 在随机噪声中划分出伪簇，肘部曲线无明显拐点 → 先 PCA 降维至 $\leq 10$ 维，或使用子空间聚类 (subspace clustering)

## 文献

1. MacQueen J. (1967) "Some methods for classification and analysis of multivariate observations", *Proceedings of the 5th Berkeley Symposium on Mathematical Statistics and Probability*, 1: 281–297. [https://projecteuclid.org/euclid.bsmsp/1200512992](https://projecteuclid.org/euclid.bsmsp/1200512992)
2. Jain A.K. (2010) "Data clustering: 50 years beyond K-means", *Pattern Recognition Letters*, 31(8): 651–666. DOI: [10.1016/j.patrec.2009.09.011](https://doi.org/10.1016/j.patrec.2009.09.011)
3. Arthur D. & Vassilvitskii S. (2007) "k-means++: The advantages of careful seeding", *Proceedings of SODA 2007*, pp. 1027–1035. DOI: [10.1145/1283383.1283494](https://doi.org/10.1145/1283383.1283494)

## 来源溯源

matlab/cluster/kmeans_cluster.m

## 关联范式卡

| 关系 | ID | 说明 |
|------|-----|------|
| 前置 | PARADIGM-0504 | 高维数据需 PCA 降维后再聚类 |
| 替代 | — | DBSCAN (密度聚类) / GMM (概率聚类) / 谱聚类 |
| 组合 | PARADIGM-0509 | 聚类后用 ANOVA 检验簇间差异是否显著 |
| 组合 | PARADIGM-0511 | 先因子分析提取潜变量，再对因子得分聚类 |
