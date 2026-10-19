# PARADIGM-0621 EM 算法与高斯混合模型⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0621 |
| 类别/子类 | ⑥机器学习 / 概率模型参数估计 |
| 难度 | 高 |
| 适用题型关键词[] | EM算法, 期望最大化, 高斯混合模型, GMM, 隐变量, 缺失数据, 参数估计, 极大似然, 软聚类, 三硬币模型, 混合分布, 概率图模型 |
| confidence | high |
| source | Dempster et al. (1977) JRSS-B; 李航《统计学习方法》§9; 教材 19、数理统计-参数估计/em.m; 自写-见S6:matlab/stats/em_algorithm.m |

## 数学形式

**问题设定**: 观测数据 $Y$ (不完全数据), 隐变量 $Z$ (如样本所属分量), 模型参数 $\theta$。直接最大化对数似然 $\log P(Y|\theta)$ 因隐变量积分/求和困难, EM 转而迭代最大化 Q 函数。

**Q 函数** (给定当前参数 $\theta^{(t)}$):

$$Q(\theta, \theta^{(t)}) = E_{Z|Y,\theta^{(t)}}\left[\log P(Y, Z | \theta)\right] = \sum_Z P(Z|Y, \theta^{(t)}) \log P(Y, Z|\theta)$$

**E 步**: 计算隐变量后验分布 (责任度)
$$\gamma_{ik}^{(t)} = P(z_i = k | x_i, \theta^{(t)})$$

**M 步**: 最大化 Q 函数更新参数
$$\theta^{(t+1)} = \arg\max_\theta Q(\theta, \theta^{(t)})$$

**收敛性质**: 每轮迭代对数似然单调不减 $\log P(Y|\theta^{(t+1)}) \geq \log P(Y|\theta^{(t)})$, 但只能收敛到局部极大, 结果依赖初值。

**GMM 具体更新公式** (K 个高斯分量, 对角协方差):

- 责任度: $\gamma_{ik} = \dfrac{\pi_k \, \mathcal{N}(x_i | \mu_k, \Sigma_k)}{\sum_{j=1}^{K} \pi_j \, \mathcal{N}(x_i | \mu_j, \Sigma_j)}$
- 权重: $\pi_k^{(t+1)} = \dfrac{1}{n}\sum_{i=1}^n \gamma_{ik} = \dfrac{N_k}{n}$
- 均值: $\mu_k^{(t+1)} = \dfrac{\sum_{i=1}^n \gamma_{ik} x_i}{N_k}$
- 方差: $\sigma_k^{2\,(t+1)} = \dfrac{\sum_{i=1}^n \gamma_{ik} (x_i - \mu_k^{(t+1)})^2}{N_k}$

**三硬币模型** (李航例 9.1, 伯努利混合): 掷硬币 B 选 $\pi$, 正面掷 A ($p$), 反面掷 C ($q$):
$$\mu_i^{(t+1)} = \frac{\pi^{(t)} (p^{(t)})^{y_i} (1-p^{(t)})^{1-y_i}}{\pi^{(t)} (p^{(t)})^{y_i} (1-p^{(t)})^{1-y_i} + (1-\pi^{(t)}) (q^{(t)})^{y_i} (1-q^{(t)})^{1-y_i}}$$
$$\pi^{(t+1)} = \frac{1}{n}\sum_i \mu_i,\quad p^{(t+1)} = \frac{\sum_i \mu_i y_i}{\sum_i \mu_i},\quad q^{(t+1)} = \frac{\sum_i (1-\mu_i) y_i}{\sum_i (1-\mu_i)}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| X (观测数据) | n×d double | — | 实数 | 中 — 含离群点时拟合被拉偏 |
| K (分量数) | int | — | [1, n] | 极高 — K 过小欠拟合, K 过大分量坍缩/过拟合, 需 BIC/AIC 选 |
| MaxIter | int | 200 | [1, ∞) | 低 — 一般 20~100 次即收敛 |
| Tol (似然收敛阈值) | float | 1e-6 | (0, 1) | 低 — 判据应基于对数似然差而非参数差 |
| RegVar (方差下界) | float | 1e-8 | (0, ∞) | 中 — 防止奇异协方差似然爆炸 |
| Seed | int | 42 | ≥0 | 高 — EM 局部极大, 多种子重启对比 |

| 输出 | 量纲 |
|------|------|
| mu / sigma / pi_k | 各分量均值/标准差/混合权重 (K×d, K×d, K×1) |
| loglik | 每次迭代对数似然 1×T (应单调不减) |
| exitflag | 1 收敛; 0 达最大迭代; -1 似然下降异常 |

**计算复杂度**: 每轮 $O(n \cdot K \cdot d)$ (E 步密度计算占主导), 总 $O(T \cdot n \cdot K \cdot d)$, $T$ 为迭代轮数 (通常 < 100)。

## MATLAB 实现

**自写-见S6:matlab/stats/em_algorithm.m** (对角协方差 GMM, 手写高斯密度免 Statistics Toolbox):

```matlab
function [mu, sigma, pi_k, loglik, exitflag] = em_algorithm(X, K, varargin)
% 可选: 'MaxIter'(200) 'Tol'(1e-6) 'Seed'(42) 'RegVar'(1e-8) 'InitMu' 'Display'
% 示例:
X = [randn(150,1)*0.5 + 2; randn(150,1) + 5];
[mu, sigma, pi_k, loglik, exitflag] = em_algorithm(X, 2, 'Display', 'iter');
```

**锚点工具箱函数**: `fitgmdist` (Statistics Toolbox, 全协方差+BIC 正则) / `fitdist`+`mle` 自定义负对数似然。

## Python 备选

```python
from sklearn.mixture import GaussianMixture
gmm = GaussianMixture(n_components=2, covariance_type='full',
                      random_state=42, reg_covar=1e-6)
gmm.fit(X)                      # X: (n, d) ndarray
print(gmm.means_, gmm.covariances_, gmm.weights_)
labels = gmm.predict(X)         # 软分配: gmm.predict_proba(X)
# BIC 选 K: gmm.bic(X); 三硬币等自定义 EM 可手写或参考教材 em.py
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 数据来自混合分布, 需参数+软归属 | EM/GMM | 标准做法, 输出概率归属而非硬标签 |
| 只需硬聚类结果, n 很大 | K-Means (0506) | EM 每轮 O(nKd) 且收敛慢, K-Means 更快 |
| 文本主题建模 | PLSA (0612) / LDA (0613) | 同为 EM/Gibbs 框架, 面向文档-词矩阵 |
| 数据量大 (n > 10^6) | 变分推断/随机 EM | 全量 E 步每次扫描全库, 可小批量化 |
| 全协方差高维建模 | fitgmdist / sklearn | 对角协方差假设独立性, 高维相关数据不适用 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 数据直方图/散点 | 目测分量个数 (峰数) |
| process | loglik-迭代曲线 | 验证单调不减与收敛 (必画) |
| process | 分量均值轨迹 | 各分量中心随迭代移动路径 |
| result | 拟合密度曲线叠加直方图 | 各分量密度×权重与总体密度 |
| result | 责任度热图/着色散点 | 软归属概率可视化 |

## 常见坑

1. **局部极大依赖初值**: 初值差 (如两分量初始均值重合) 会收敛到差解。应对: 多次随机初始化取对数似然最大者; 或用 K-Means 结果作初值。
2. **分量坍缩**: 某分量只"捕获"1~2 个样本时 $\sigma \to 0$, 似然趋于无穷, 数值爆炸。应对: RegVar 方差下界 (1e-6~1e-8) 或先验正则。
3. **收敛判据错误**: 用参数变化量做判据会在参数缓慢漂移时误判; 应判对数似然差 $|\Delta \log L| < \text{Tol}$。
4. **K 选择凭感觉**: K 每增加一个参数个数增加 $O(d^2)$ 量级, 用 BIC = $-2\log L + m\log n$ 权衡 (fitgmdist 内置)。
5. **标签可交换性**: 第 t 轮的分量 k 与 t+1 轮不保证对应, 比较迭代轨迹前需按均值/权重对齐排序。
6. **似然下降容忍**: 数值误差可致微小下降; 若显著下降说明实现有误或方差坍缩未处理。

## 失效条件/反例 (强制小节)

- **条件1: 初始均值重合或近重合 (多分量初值落在同一区域)** → **表现**: E 步责任度均分, M 步各分量更新方向一致, 迭代后分量合并或锁定在同一局部极大, 无法恢复真实混合结构。**应对**: (1) 用 `randperm` 抽不同样本作初值; (2) 先 K-Means 得中心; (3) 多 Seed 重启取 loglik 最大者。

- **条件2: 高维数据 (d 大) 且方差未设下界** → **表现**: 密度计算中 $\exp(-0.5 z^2)$ 下溢为 0, 责任度全 0, 似然为 $-\infty$; 或某分量 $\sigma \to 0$ 使密度趋于无穷, 似然爆炸, 迭代发散。**应对**: 正则化方差下界; 用对数域计算 log-sum-exp 密度; 维度很高 (d>100) 时先 PCA 降维。

- **条件3: K 大于真实分量数** → **表现**: 多余分量坍缩到单点/重复真实分量, 权重 $\pi_k \to 0$ 或方差 $\to 0$, 虽似然继续上升但模型过拟合, 无解释意义。**应对**: 用 BIC/AIC 扫描 K=1..Kmax; 观察权重接近 0 的分量并删除。

- **条件4: 数据含明显离群点** → **表现**: 高斯似然对离群点极敏感 (二次惩罚), 某一分量被拉向离群点, 真实分量估计失真。**应对**: 改用 t 分布混合 (稳健 EM) 或先做离群检测 (0502); 至少对比剔除离群点前后的估计结果。

## 文献

1. Dempster AP, Laird NM, Rubin DB (1977). "Maximum likelihood from incomplete data via the EM algorithm." *Journal of the Royal Statistical Society: Series B*, 39(1), 1-38. DOI: [10.1111/j.2517-6161.1977.tb01600.x](https://doi.org/10.1111/j.2517-6161.1977.tb01600.x)
2. 李航 (2019). 《统计学习方法》第2版, 第9章 EM算法及其推广. 清华大学出版社. ISBN: 978-7302517276
3. Bishop CM (2006). *Pattern Recognition and Machine Learning*, §9.2-9.3. Springer. ISBN: 978-0387310732

## 来源溯源

教材 `算法资料/19、数理统计-参数估计/matlab/em.m` (1-D 双分量 GMM) + `算法资料新1/22种机器学习常用算法Python实现全套代码/EM算法及其推广/9.Expectation_Maximization.ipynb` (三硬币模型+习题); 自写 S6:matlab/stats/em_algorithm.m。

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0503 (概率分布与 MLE 基础) |
| 组合 | PARADIGM-0506 (K-Means 结果作 EM 初始化) |
| 替代 | PARADIGM-0506 (仅需硬聚类时) |
| 组合 | PARADIGM-0612 (PLSA 为 EM 在文本上的实例) / PARADIGM-0613 (LDA 变分 EM) |
| 组合 | PARADIGM-0906 (对 K、初值的灵敏度分析) |
