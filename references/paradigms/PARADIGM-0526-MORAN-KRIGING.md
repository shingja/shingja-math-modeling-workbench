# PARADIGM-0526-MORAN-KRIGING Moran's I空间自相关/克里金插值⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0526-MORAN-KRIGING |
| 类别/子类 | ⑤统计 / 空间分析 |
| 难度 | 中 |
| 适用题型关键词[] | 空间自相关, 空间插值, 地统计, 克里金, 空间聚类, 空间分布 |
| confidence | high |
| source | 文献1950_Moran / 题解反推_Spatial类 |

## 数学形式

**Moran's $I$ (全局空间自相关)**:
$$I = \frac{n}{S_0} \frac{\sum_{i=1}^{n} \sum_{j=1}^{n} w_{ij} (y_i - \bar{y})(y_j - \bar{y})}{\sum_{i=1}^{n} (y_i - \bar{y})^2}$$
其中 $S_0 = \sum_i \sum_j w_{ij}$, $w_{ij}$ 为空间权重矩阵元素

**解释**: $I \in [-1, 1]$; $I > 0$ 正空间自相关 (聚集), $I \approx 0$ 随机, $I < 0$ 分散

**局部 Moran's $I$ (LISA)**:
$$I_i = \frac{(y_i - \bar{y})}{m_2} \sum_{j} w_{ij} (y_j - \bar{y}), \quad m_2 = \frac{1}{n}\sum (y_i - \bar{y})^2$$
识别 HH (高-高)/LL (低-低)/HL/LH 四类空间聚类

**普通克里金 (Ordinary Kriging)**:
$$\hat{Z}(\mathbf{s}_0) = \sum_{i=1}^{n} \lambda_i Z(\mathbf{s}_i)$$
$$\text{s.t.} \quad \sum \lambda_i = 1$$
权重 $\lambda_i$ 通过变差函数 (variogram) $\gamma(h)$ 和最小化估计方差求解:
$$\gamma(h) = \frac{1}{2|N(h)|} \sum_{N(h)} (Z(\mathbf{s}_i) - Z(\mathbf{s}_j))^2$$
理论模型: Spherical, Exponential, Gaussian, Matern

| 变量 | 含义 |
|------|------|
| $w_{ij}$ | 空间权重 ($i$ 与 $j$ 邻接 = 1) |
| $\gamma(h)$ | 变差函数 (半方差随距离变化) |
| $Z(\mathbf{s})$ | 空间位置 $\mathbf{s}$ 上的变量值 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 空间权重矩阵类型 | enum | 反距离 | KNN/距离阈值/Queen邻接 | 高 |
| KNN 近邻数 $k$ | int | 8 | 3-20 | 高 |
| 变差函数模型 | enum | Spherical | Sph/Exp/Gauss/Matern | 中 |
| 块金值 (nugget) | float | 估计 | 0-1 | 中 |
| 距离阈值 | float | 自动 | — | 高—控制连接密度 |
| 显著性检验 | — | 999 次蒙特卡洛置换 | — | 中—决定p值可信度 |

**Moran's I 复杂度**: $O(n^2)$ (权重矩阵密集)
**克里金复杂度**: $O(n^3)$ (普通克里金求逆每预测点) → 局部克里金降至 $O(m^3)$ ($m$ 为最近邻数)

## MATLAB 实现

```matlab
% 空间分析 (Mapping Toolbox 可辅助)
% geopredict + 自写Moran-见S5:moran_kriging.m

% Moran's I 自写:
% 1. 构造空间权重矩阵 W (基于坐标距离/KNN)
% 2. 标准化 (行和为1)
% 3. 计算 I = n/sum(W(:)) * (z'*W*z)/(z'*z), z = y - mean(y)
% 4. 蒙特卡洛置换检验 (999次) 得 p 值

% 克里金 (半自写):
% 1. 经验半方差: 计算各距离带的 emp. semivariance
% 2. 拟合理论变差函数模型 (最小二乘/WLS)
% 3. 求解克里金方程: [Gamma, 1; 1', 0] * [lambda; mu] = [gamma_0; 1]
% 4. 预测: z_hat = lambda' * z_obs
% 5. 预测方差: kriging variance

% Mapping Toolbox 辅助:
% geoscatter 可视化空间点
% geoplot 绘制插值结果
% geopredict (自 v2021b) 简化克里金 (Experimental, 需验证)
```

**锚点工具箱**: `geoplot`, `geoscatter`, `geobasemap`, `geopredict` (Mapping Toolbox, 有限)
**推荐**: 自写-见S5:moran_kriging.m (Moran's I + 克里金 全自实现)

## Python 备选

```python
import numpy as np
from scipy.spatial.distance import cdist
from scipy.spatial import KDTree

# Moran's I (自写或 pysal)
import esda
import libpysal

w = libpysal.weights.KNN.from_array(coords, k=8)
moran = esda.Moran(y, w)
# moran.I, moran.p_sim (置换p值), LISA 可用 esda.Moran_Local

# 克里金
from pykrige.ok import OrdinaryKriging

OK = OrdinaryKriging(x, y, z, variogram_model='spherical')
z_pred, sigma = OK.execute('grid', gridx, gridy)
```

备选: `geopandas` + `pysal` (空间权重 + Moran), `GSTools` (地统计), `scikit-gstat` (变差函数)

## 选型决策树

- **空间数据 + 检验是否存在空间聚集** → Moran's I 全局检验, 再用 LISA 定位热点
- **空间插值 (基于点估计面)** → Kriging (提供最优线性无偏预测 BLUP + 估计方差)
- **简单插值 + 无空间结构建模** → IDW (反距离权重) 更简单
- **大量样本插值 (>5000)** → 局部克里金 (子集) 或用机器学习替代 (随机森林空间预测)
- **空间回归 (空间依赖性进入模型)** → 空间滞后模型 (SAR)/空间误差模型 (SEM)

## 典型图型

- **raw**: 空间点分布散点图 (colormap by value), 直方图 (值分布)
- **process**: 经验半方差函数散点图 + 拟合理论模型曲线, Moran 散点图 ($y$ vs $Wy$)
- **result**: LISA 聚类地图 (HH/LL/HL/LH 颜色编码 + 显著性), 克里金插值面 (contour/surface), 预测方差面

## 常见坑

1. **空间权重 $W$ 选择主观 + 影响大**: KNN/k 距离阈值 改变直接改变 Moran's I → 敏感性分析 (k=4, 8, 12), 报告 I 的变化
2. **边界效应 (Edge Effect)**: 边界点邻域数少, 局部 I 和 LISA 有偏 → 边界修正或给出 caveat
3. **克里金要求平稳性 (二阶平稳)**: 若区域内有明显趋势 (非平稳), 普通克里金低估预测方差 → 通用克里金 (包含趋势项)
4. **变差函数拟合在近原点关键**: 块金值 (nugget) 过大表明存在短距离变异或测量误差 → 核查数据质量

## 失效条件/反例 (强制小节)

- **条件1**: 样本点数 $n < 30$ → Moran's I 检验功效太低, 且变差函数拟合不可靠 (每个距离带 < 30 对), Kriging 权重由不可靠的变差函数决定。**替代**: IDW 简单插值, 仅描述不推断
- **条件2**: 无空间结构 (变差函数纯 nugget 效应, $\gamma(h) \approx$ 常数) → 无空间自相关, Kriging 退化为算术平均, Moran's I $\approx 0$。插值无优于 IDW 的保证。**替代**: 接受纯 nugget, 或用额外协变量 (Cokriging/环境变量)
- **条件3**: 空间各向异性强 (不同方向半方差不同) → 各向同性模型极大弱化插值精度, Kriging 预测方差在各方向不一致。**替代**: 各向异性 Kriging (directional variogram), 分方向拟合
- **条件4**: 数据高度偏态 + 含极端值 → 变差函数估算被个别大差异控制, Kriging 得出不切实际的大权重。**替代**: 正态变换 (log/Box-Cox) + 克里金, 或指示克里金 (Indicator Kriging), 或秩克里金

## 文献

1. Moran, P. A. P. (1950). Notes on continuous stochastic phenomena. *Biometrika*, 37(1/2), 17-23. DOI: [10.2307/2332142](https://doi.org/10.2307/2332142)
2. Cressie, N. (1993). *Statistics for Spatial Data* (Revised ed.). Wiley. ISBN: 978-0-471-00255-0.
3. Anselin, L. (1995). Local indicators of spatial association—LISA. *Geographical Analysis*, 27(2), 93-115. DOI: [10.1111/j.1538-4632.1995.tb00338.x](https://doi.org/10.1111/j.1538-4632.1995.tb00338.x)

## 来源溯源

- 论文三元组: Moran 1950 spatial autocorrelation; Krige 1951 + Matheron 1963 geostatistics
- 教学用例: 环境污染分布, 疾病聚集分析, 土质空间预测

## 关联范式卡

组合: PARADIGM-1001-GPR (Kriging = GPR 特例)
替代: IDW (简单插值), 空间回归 (SAR/SEM)
前置: PARADIGM-0501-REGRESSION
