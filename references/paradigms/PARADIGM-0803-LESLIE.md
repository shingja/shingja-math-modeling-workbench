# PARADIGM-0803 Leslie 矩阵 (年龄结构种群投影)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0803 |
| 类别/子类 | ⑧机理建模 / 种群动力学 |
| 难度 | 中 |
| 适用题型关键词[] | Leslie矩阵, 年龄结构, 种群投影, 生育率, 存活率, 稳定年龄分布, 优势特征值, 种群动态, 年龄别, 人口预测 |
| confidence | high |
| source | Leslie (1945) Biometrika; 已有 matlab/mechanism/leslie_model.m |

## 数学形式

**Leslie 矩阵模型 (年龄结构化种群投影模型)**

**基本形式**: 将种群按年龄分为 $m+1$ 个年龄级 (class): $0, 1, 2, \ldots, m$, 其中 $m$ 为最大生育年龄。第 $t$ 时刻各年龄级数量构成向量 $\mathbf{n}(t) = [n_0(t), n_1(t), \ldots, n_m(t)]^\top$。

**投影方程**:
$$\mathbf{n}(t+1) = \mathbf{L} \cdot \mathbf{n}(t)$$

其中 $\mathbf{L} \in \mathbb{R}^{(m+1) \times (m+1)}$ 为 Leslie 矩阵:

$$\mathbf{L} = \begin{bmatrix}
f_0 & f_1 & f_2 & \cdots & f_{m-1} & f_m \\
s_0 & 0 & 0 & \cdots & 0 & 0 \\
0 & s_1 & 0 & \cdots & 0 & 0 \\
0 & 0 & s_2 & \cdots & 0 & 0 \\
\vdots & \vdots & \vdots & \ddots & \vdots & \vdots \\
0 & 0 & 0 & \cdots & s_{m-1} & 0
\end{bmatrix}$$

参数含义:
- $f_i$ = 年龄级 $i$ 的个体在单位时间内产生的后代 (生育率, fecundity), 仅第一行非零
- $s_i$ = 年龄级 $i$ 的个体存活至年龄级 $i+1$ 的概率 (存活率, survival rate), 次对角线上非零, $0 < s_i < 1$

**幂迭代性质**:
$$\mathbf{n}(t) = \mathbf{L}^t \cdot \mathbf{n}(0)$$

**Perron-Frobenius 定理的应用**:

Leslie 矩阵 $\mathbf{L}$ 是非负不可约 (若存在连续两个非零 $f_i$) 或可约矩阵, 具有唯一正优势特征值 $\lambda_1$ (dominant eigenvalue)。长期动力学由 $\lambda_1$ 主导。

**长期渐近行为**:
$$\mathbf{n}(t) \propto \lambda_1^t \cdot \mathbf{w}_1 \quad \text{当 } t \to \infty$$

其中:
- $\lambda_1$: 优势特征值, 即 $\det(\mathbf{L} - \lambda \mathbf{I}) = 0$ 的最大实根
  - $\lambda_1 > 1$: 种群指数增长 (每个个体生命周期内产生 > 1 个后代)
  - $\lambda_1 = 1$: 种群稳定 (恰好替代)
  - $\lambda_1 < 1$: 种群衰减 (走向灭绝)
- $\mathbf{w}_1$: $\lambda_1$ 对应的右特征向量 (稳定年龄分布, stable age distribution)

**特征方程** (Euler-Lotka 方程):
$$\sum_{i=0}^{m} l_i f_i \lambda^{-(i+1)} = 1$$

其中 $l_i = s_0 s_1 \cdots s_{i-1}$ 为从出生存活至年龄级 $i$ 的概率 ($l_0 \equiv 1$)。

**净繁殖率 (Net Reproductive Rate)**:
$$R_0 = \sum_{i=0}^{m} l_i f_i$$

$R_0$ 为每个个体生命周期内平均产生的雌性后代数。$\lambda_1 > 1 \iff R_0 > 1$ (对于大多数年龄结构)。

**平均世代时间 (Mean Generation Time)**:
$$T = \frac{\sum_{i=0}^{m} (i+1) l_i f_i \lambda_1^{-(i+1)}}{\sum_{i=0}^{m} l_i f_i \lambda_1^{-(i+1)}}$$

近似公式: $T \approx \ln(R_0) / \ln(\lambda_1)$。

**繁殖价值 (Reproductive Value, 左特征向量)**:

$\mathbf{v}_1^\top \mathbf{L} = \lambda_1 \mathbf{v}_1^\top$ 定义的左特征向量 $\mathbf{v}_1$ 给出各年龄级的繁殖价值——年龄级 $i$ 的个体对未来种群增长的相对贡献。

**灵敏度 (Sensitivity) 和弹性 (Elasticity)**:

灵敏度: $S_{ij} = \frac{\partial \lambda_1}{\partial L_{ij}} = \frac{v_{1i} w_{1j}}{\mathbf{v}_1^\top \mathbf{w}_1}$

弹性: $E_{ij} = \frac{L_{ij}}{\lambda_1} \cdot S_{ij}$ (比例敏感性, 各元素弹性之和为 1)

$E_{ij}$ 表示 Leslie 矩阵元素 $L_{ij}$ 的 1% 变化导致 $\lambda_1$ 的百分比变化, 用于确定生命周期中最关键的阶段 (如保护生物学中的关键保护期)。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| $f_i$ (生育率, i=0,...,m) | vector | — | [0, $\infty$) | 极高 — 直接影响 $R_0$ 和 $\lambda_1$ |
| $s_i$ (存活率, i=0,...,m-1) | vector | — | (0, 1) | 极高 — $s_0$ (幼体存活) 通常弹性最大 |
| m (年龄级数) | int | 10 | [2, 100] | 中 — 级数太少 $\to$ 级内不均匀; 太多 $\to$ 参数估计困难 |
| $\mathbf{n}(0)$ (初始年龄分布) | vector | — | $\geq 0$ | 低 — 不影响长期增长率 $\lambda_1$, 仅影响 transient dynamics |
| T (投影时域) | int | 50 | [1, 500] | 低 — 仅控制输出长度 |

| 输出 | 量纲 |
|------|------|
| $\mathbf{n}(t)$ | 各年龄级数量 (与初值同量纲) |
| $\lambda_1$ (优势特征值) | 无量纲, 有限增长率 (finite rate of increase) |
| $\mathbf{w}_1$ (稳定年龄分布) | 比例 (归一化: $\sum w_{1i} = 1$) |
| $R_0$ (净繁殖率) | 后代数/个体 |
| $T$ (平均世代时间) | 与时间级同量纲 |
| 弹性矩阵 $\mathbf{E}$ | (0, 1), 比例 |

**计算复杂度**: 矩阵幂迭代 $O(T \cdot m^2)$ 或直接特征值分解 $O(m^3)$。$m \leq 100$ 时 trivial (< 0.01s)。

## MATLAB 实现

**方法1: 矩阵投影 + 特征值分析 (已有 matlab/mechanism/leslie_model.m)**

```matlab
% Leslie 矩阵构建
% 参数: 10 个年龄级 (0-1, 1-2, ..., 9+ 岁)
f = [0, 0, 0.5, 1.5, 2.0, 1.8, 1.2, 0.5, 0.1, 0];  % 生育率
s = [0.85, 0.95, 0.92, 0.90, 0.85, 0.75, 0.60, 0.40, 0.15];  % 存活率 (m-1 个)

% 构建 Leslie 矩阵
m = length(f);
L = zeros(m, m);
L(1, :) = f;                    % 第一行 = 生育率
for i = 1:(m-1)
    L(i+1, i) = s(i);          % 次对角线 = 存活率
end

% 初始种群
n0 = [100; 80; 60; 50; 40; 30; 20; 15; 10; 5];

% 投影 T 步
T = 50;
n = zeros(m, T+1);
n(:, 1) = n0;
for t = 1:T
    n(:, t+1) = L * n(:, t);
end

% 总种群随时间变化
N_total = sum(n, 1);

% === 特征值分析 ===
[V, D] = eig(L);
[lambda_sorted, idx] = sort(abs(diag(D)), 'descend');
lambda1 = D(idx(1), idx(1));           % 优势特征值 (可能为复数, 但 Leslie 矩阵优势特征值为正实数)
lambda1 = real(lambda1);
w1 = V(:, idx(1));                      % 稳定年龄分布
w1 = w1 / sum(w1);                      % 归一化

fprintf('优势特征值 lambda1 = %.4f\n', lambda1);
if lambda1 > 1
    fprintf('种群增长 (每个个体产生 > 1 个后代)\n');
elseif lambda1 < 1
    fprintf('种群衰减 (走向灭绝)\n');
else
    fprintf('种群稳定 (恰好替代)\n');
end

% 净繁殖率 R0
l = cumprod([1, s(1:end-1)]);           % 存活至各年龄级的概率
R0 = sum(l .* f);
fprintf('净繁殖率 R0 = %.4f\n', R0);

% 弹性分析
[v1_left, ~] = eigs(L', 1);             % 左特征向量 (对应 lambda1)
v1 = v1_left(:, 1);
S = (v1 * w1') / (v1' * w1);            % 灵敏度矩阵
E = (L / lambda1) .* S;                 % 弹性矩阵
fprintf('弹性总和 (应 = 1): %.6f\n', sum(E(:)));

% === 可视化 ===
figure;
subplot(2,2,1);
plot(0:T, N_total, 'b-', 'LineWidth', 2);
xlabel('时间步'); ylabel('总种群 N(t)');
title(sprintf('总种群动态 (\\lambda_1=%.3f)', lambda1));
grid on;

subplot(2,2,2);
bar(0:m-1, w1);
xlabel('年龄级'); ylabel('比例');
title('稳定年龄分布 w_1');
grid on;

subplot(2,2,3);
area(0:T, n');
xlabel('时间步'); ylabel('各年龄级数量');
title('年龄结构随时间的演变');
legend(string(0:m-1), 'Location', 'bestoutside');

subplot(2,2,4);
imagesc(E); colorbar;
xlabel('年龄级'); ylabel('年龄级');
title(sprintf('弹性矩阵 (\\Sigma E_{ij}=%.3f)', sum(E(:))));
```

**锚点工具箱函数**: `eig` (特征值分解), `eigs` (稀疏特征值, 大矩阵时).

**方法2: 参数敏感性扫描**

```matlab
% 对 f_3 (生育率峰值) 进行敏感性扫描
f_values = linspace(0.5, 3.0, 50);
lambda_values = zeros(size(f_values));

for i = 1:length(f_values)
    f_perturbed = f;
    f_perturbed(4) = f_values(i);  % 扰动词龄级 3 (索引从 1 开始)
    L_pert = L;
    L_pert(1, :) = f_perturbed;
    lambda_values(i) = max(real(eig(L_pert)));
end

figure;
plot(f_values, lambda_values, 'b-', 'LineWidth', 2);
xlabel('f_3 (生育率)'); ylabel('\lambda_1');
yline(1, 'r--', '替代水平');
grid on;
title('\lambda_1 对生育率 f_3 的敏感性');
```

## Python 备选

```python
import numpy as np
import matplotlib.pyplot as plt

# 参数
f = np.array([0, 0, 0.5, 1.5, 2.0, 1.8, 1.2, 0.5, 0.1, 0])
s = np.array([0.85, 0.95, 0.92, 0.90, 0.85, 0.75, 0.60, 0.40, 0.15])

# 构建 Leslie 矩阵
m = len(f)
L = np.zeros((m, m))
L[0, :] = f
for i in range(m-1):
    L[i+1, i] = s[i]

# 投影
n0 = np.array([100, 80, 60, 50, 40, 30, 20, 15, 10, 5])
T = 50
n = np.zeros((m, T+1))
n[:, 0] = n0
for t in range(T):
    n[:, t+1] = L @ n[:, t]

# 特征值分析
eigvals, eigvecs = np.linalg.eig(L)
idx = np.argsort(np.abs(eigvals))[::-1]
lambda1 = np.real(eigvals[idx[0]])
w1 = np.real(eigvecs[:, idx[0]])
w1 = w1 / np.sum(w1)

# 净繁殖率
l = np.cumprod(np.insert(s[:-1], 0, 1))
R0 = np.sum(l * f)

print(f"lambda1 = {lambda1:.4f}, R0 = {R0:.4f}")

# 弹性分析
_, left_eigvecs = np.linalg.eig(L.T)
v1 = np.real(left_eigvecs[:, idx[0]])
S = np.outer(v1, w1) / np.dot(v1, w1)
E = (L / lambda1) * S
print(f"弹性总和: {np.sum(E):.6f}")
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 有年龄/阶段结构的数据 | Leslie / Lefkovitch | 比同质种群模型 (Malthus/Logistic) 精确得多 |
| 仅需要总种群趋势 | Malthus 或 Logistic | 若年龄结构不重要, 少参数模型更易拟合 |
| 年龄别参数时变 | 时变 Leslie (每年更新 L) | 环境和政策变化时 f_i 和 s_i 可能改变 |
| 年龄级内生育/存活不均匀 | 增加年龄级数 | 1 年一级 (如人口学中的单岁组) 最精确 |
| 阶段结构 (非严格年龄) | Lefkovitch 矩阵 | 按发育阶段 (卵/幼虫/蛹/成虫) 而非年龄划分 |
| 密度制约 | 密度制约 Leslie (非线性) | 加入 $s_i(N_{total})$ 或 $f_i(N_{total})$ 函数 |
| 两性种群 (性比重要) | 两性 Leslie 扩展 | 标准 Leslie 假设所有个体为雌性 (或忽略性比) |
| 空间结构化 (集合种群) | 多区域 Leslie | 各区域独立 Leslie + 迁移矩阵 |
| 随机环境 (s_i, f_i 随机) | 随机 Leslie (Monte Carlo) | 投影多组随机参数取分位点, 评估灭绝概率 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 年龄金字塔 (初始) | barh(年龄级, n0) 分雌雄 |
| process | 总种群 N(t) 时序 | 叠加指数拟合线, 标注 lambda1 |
| process | 年龄级面积图 | area(t, n') 展示年龄结构随时间演变 |
| result | 稳定年龄分布 $\mathbf{w}_1$ | bar + 比较初始分布, 展示收敛趋势 |
| result | 弹性矩阵 heatmap | imagesc(E), 标注最敏感生命阶段 |
| result | $\lambda_1$ 对关键参数的敏感性 | 单因素扫描图, tornado diagram |
| result | 投影不确定性 (随机 Leslie) | ribbon plot 展示 95% CI 的种群轨迹带 |

## 常见坑

1. **时间步长与年龄级宽度必须一致**: 若年龄级宽度为 5 年, 则投影时间步长也必须是 5 年 (即 $\mathbf{n}(t+5) = \mathbf{L} \cdot \mathbf{n}(t)$)。若步长不一致, 存活率和生育率含义错误。
2. **生育率定义混淆**: 有些文献将 $f_i$ 定义为年龄级 $i$ 个体在 $\Delta t$ 内产生的后代数; 有些需乘以存活率。务必明确是"出生时的数量" (需乘 $s_0$) 还是"进入下一时间步时的存活后代" (已乘 $s_0$)。两种定义导致不同的 Leslie 矩阵第一行。
3. **年龄级数的选择**: 级数太少 (如 3 级: 幼体/成体/老年) $\to$ 级内生育/存活严重不均匀, $\lambda_1$ 的估计视级内分布假设可能导致系统偏差。建议 $\geq 10$ 个年龄级。若数据不足无法估计 10 组参数, 用参数函数 (如 Gompertz 或 Siler 模型) 平滑年龄别生育率和存活率曲线。
4. **$\lambda_1$ 不是复数的假设**: Leslie 矩阵的优势特征值理论上必须是正实数 ($\mathbf{L}$ irreducible 时)。但若某两个年龄级系数设置不恰当 (如 $f_0$ 极大但所有 $s_i=0$), 矩阵退化为可约, 可能出现复数 $\lambda_1$ 或负实数。建议用 `max(real(eig(L)))` 取最大实部。
5. **瞬态动力学 (transient dynamics)**: $\mathbf{n}(t) \propto \lambda_1^t \mathbf{w}_1$ 是长期渐近行为。短期 (前几个时间步) 种群可能因初始年龄分布偏离 $\mathbf{w}_1$ 而产生瞬时下降/上涨 (如初始老年居多 $\to$ 第一代后总数骤降)。务必区分"长期增长率 $\lambda_1$"和"短期/中期观测增长率"。
6. **密度制约缺失**: 标准 Leslie 是线性的——资源无限假设。长期预测 $\mathbf{n}(t)$ 发散, 需讨论"在环境容量内投影可接受, 超 K 后需密度制约修正"。

## 失效条件/反例 (强制小节)

- **条件1: 年龄别参数时不变假设被违反** $\to$ **表现**: Leslie 矩阵 $\mathbf{L}$ 恒定的前提是生育率和存活率不随时间改变。当环境发生趋势性变化 (如气候变暖使某龄级存活率单调递增, 或计划生育政策使生育率骤降) 时, 用恒定 $\mathbf{L}$ 拟合历史数据并外推, 系统性地错估 $\lambda_1$。具体: 若 $s_0$ 在历史上从 0.6 升至 0.85, 恒定模型使用 0.75 相当于对早期高估、对后期低估, 中期预测有偏。**应对**: (1) 使用时变 Leslie $\mathbf{n}(t+1) = \mathbf{L}(t) \cdot \mathbf{n}(t)$; (2) 分段拟合不同时期的 Leslie 矩阵, 讨论参数趋势; (3) 在预测中做多情景分析 (乐观/基准/悲观年龄别参数)。

- **条件2: 年龄级划分过粗 (如 10 年一级) 使得级内生育/存活不均匀** $\to$ **表现**: 若年龄级跨度为 10 年, 则将 0-9 岁视为同一级, 假设该级内所有个体的生育率和存活率一致。实际上 0 岁和 9 岁的存活率天壤之别, 特别是幼年阶段。这产生两类偏差: (a) $s_0$ 代表 0 岁存活至 10 岁的概率, 但级内第 1 年的高死亡率和后续 9 年的相对稳定被压缩为一个过低值—低估了进入下级的个体数; (b) $f_0$ 实际对应 0-9 岁的平均生育率, 但 0-4 岁可能生育率为 0, 5-9 岁达到峰值—平均生育率掩盖了年龄模式。**应对**: (1) 将年龄级细化至 1 年或 5 年; (2) 若数据不支撑细粒级, 使用参数化年龄别曲线 (如 gamma 函数拟合生育率, Siler 模型拟合存活率) 而非粗粒级经验平均。

- **条件3: 密度制约效应显著但被忽略 (线性 Leslie 的无限增长假设)** $\to$ **表现**: 线性 Leslie 预测种群以每年 $(\lambda_1 - 1) \times 100\%$ 的速率无限指数增长。当预测时长超过 $\sim 5$ 个世代, 预测值达到物理上不可能的水平 (如后代数超过可承载个体数)。若系统接近或超过环境容量, 密度制约开始起作用—存活率 $s_i$ 或生育率 $f_i$ 随总密度递减。标准 Leslie 此时的预测不仅是量级错误, 更会歪曲年龄结构 (密度制约往往对幼年阶段影响最大, 但模型无法体现)。**应对**: (1) 在 Leslie 框架内引入密度制约: $s_i(N_{total}) = s_i^{(0)} \cdot g(N_{total}/K)$, 其中 $g$ 为递减函数 (如 $g(x) = \max(0, 1-x)$); (2) 设置合理投影时域 (如 20-50 年), 并声明"本模型在远离承载能力时有效"; (3) 在预测中加入 Logistic 型的全局约束, Leslie 定义的是年龄结构相对分布, 总规模由 Logistic 限制。

## 文献

1. Leslie PH (1945). "On the use of matrices in certain population mathematics." *Biometrika*, 33(3):183-212. DOI: [10.1093/biomet/33.3.183](https://doi.org/10.1093/biomet/33.3.183)
2. Caswell H (2001). *Matrix Population Models: Construction, Analysis, and Interpretation*, 2nd ed. Sinauer Associates. ISBN: 978-0878930968 (矩阵种群模型的权威参考书)
3. Keyfitz N, Caswell H (2005). *Applied Mathematical Demography*, 3rd ed. Springer. ISBN: 978-0387225371
4. de Kroon H, Plaisier A, van Groenendael J, Caswell H (1986). "Elasticity: The relative contribution of demographic parameters to population growth rate." *Ecology*, 67(5):1427-1431. DOI: [10.2307/1938700](https://doi.org/10.2307/1938700)

## 来源溯源

Leslie (1945) Biometrika 33(3); 已有 matlab/mechanism/leslie_model.m; 培训模块 mechanism-population.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置/扩展 | PARADIGM-0801 (Malthus模型, Leslie 是年龄结构化的指数增长) |
| 扩展 | PARADIGM-0802 (Logistic增长, 在 Leslie 中加入密度制约 $s_i(N)$ 或 $f_i(N)$) |
| 组合 | PARADIGM-0804 (SEIR, 年龄结构 SEIR 将 Leslie 的年龄接触矩阵嵌入传染病传播) |
| 组合 | PARADIGM-0708 (系统动力学, 将 Leslie 年龄级视作 stock, 存活/生育视作 flow) |
