# PARADIGM-0712 GWO优化SVR混合模型⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0712 |
| 类别/子类 | ⑦综合 / 混合优化预测 |
| 难度 | 中 |
| 适用题型关键词[] | GWO-SVR, 灰狼优化, 支持向量回归, 混合模型, 参数优化, fitrsvm, 超参数调优 |
| confidence | medium |
| source | Mirjalili (2014) Adv Eng Software + Smola & Scholkopf (2004) |

## 数学形式

**阶段 1: 灰狼优化器 GWO**

社会层级: α (最优), β (次优), δ (第三优), ω (其余)

**包围猎物:**
$$\mathbf{D} = |\mathbf{C} \cdot \mathbf{X}_p(t) - \mathbf{X}(t)|$$
$$\mathbf{X}(t+1) = \mathbf{X}_p(t) - \mathbf{A} \cdot \mathbf{D}$$

其中 $\mathbf{A} = 2a \cdot \mathbf{r}_1 - a$, $\mathbf{C} = 2\mathbf{r}_2$, $a$ 从 2 线性递减到 0。

**位置更新 (三狼引导):**
$$\mathbf{X}_1 = \mathbf{X}_\alpha - A_1 \cdot D_\alpha$$
$$\mathbf{X}_2 = \mathbf{X}_\beta - A_2 \cdot D_\beta$$
$$\mathbf{X}_3 = \mathbf{X}_\delta - A_3 \cdot D_\delta$$
$$\mathbf{X}(t+1) = \frac{\mathbf{X}_1 + \mathbf{X}_2 + \mathbf{X}_3}{3}$$

**阶段 2: SVR (ε-SVR)**

GWO 优化 SVR 的超参数 $(C, \gamma, \varepsilon)$:
$$\min_{\mathbf{w},b,\xi,\xi^*} \frac{1}{2}\|\mathbf{w}\|^2 + C\sum(\xi_i + \xi_i^*)$$
$$\text{s.t. } y_i - \mathbf{w}^T\phi(\mathbf{x}_i) - b \leq \varepsilon + \xi_i$$

RBF 核: $K(\mathbf{x}_i, \mathbf{x}_j) = e^{-\gamma\|\mathbf{x}_i - \mathbf{x}_j\|^2}$

**适应度函数:** 5-fold CV 的 MSE

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| n_wolves | int | 30 | [10, 100] | 中 |
| n_iter | int | 100 | [50, 300] | 高 |
| C 搜索范围 | [low,high] | [0.1, 1000] | — | 极高 |
| gamma 搜索范围 | [low,high] | [1e-4, 10] | — | 极高 |
| 每匹狼评估 | — | — | CV MSE O(n·p·k) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[best_params, best_mse, model] = gwo_svr(X, y, n_wolves, n_iter, ...
    C_range, gamma_range, epsilon_range, kfold)
% best_params = [C, gamma, epsilon]
```

锚点: 自写 GWO + `fitrsvm` (Statistics and Machine Learning Toolbox)-见S5:gwo_svr.m

```matlab
% GWO 核心
lb = [C_range(1), gamma_range(1), epsilon_range(1)];
ub = [C_range(2), gamma_range(2), epsilon_range(2)];
dim = 3;  % C, gamma, epsilon

% 初始化狼群
wolves = lb + rand(n_wolves, dim) .* (ub - lb);
alpha_score = Inf; beta_score = Inf; delta_score = Inf;

for iter = 1:n_iter
    % 评估每匹狼 (CV MSE)
    for i = 1:n_wolves
        C = wolves(i,1); gamma = wolves(i,2); eps = wolves(i,3);
        fitness = cv_svr_mse(X, y, C, gamma, eps, kfold);
        
        % 更新 α, β, δ
        if fitness < alpha_score
            alpha_score = fitness; alpha_pos = wolves(i,:);
        elseif fitness < beta_score
            beta_score = fitness; beta_pos = wolves(i,:);
        elseif fitness < delta_score
            delta_score = fitness; delta_pos = wolves(i,:);
        end
    end
    
    % 更新位置
    a = 2 - iter * (2 / n_iter);  % 线性递减
    for i = 1:n_wolves
        for j = 1:dim
            % 三狼引导更新
            r1=rand; r2=rand; A1=2*a*r1-a; C1=2*r2;
            D_alpha = abs(C1*alpha_pos(j) - wolves(i,j));
            X1 = alpha_pos(j) - A1*D_alpha;
            % ... X2, X3 similarly
            wolves(i,j) = (X1 + X2 + X3) / 3;
        end
        wolves(i,:) = max(min(wolves(i,:), ub), lb);  % 边界
    end
end

% 最优参数训练最终 SVR
best_C = alpha_pos(1); best_gamma = alpha_pos(2); best_eps = alpha_pos(3);
model = fitrsvm(X, y, 'KernelFunction', 'rbf', ...
    'BoxConstraint', best_C, 'KernelScale', 1/sqrt(2*best_gamma), ...
    'Epsilon', best_eps);
```

## Python 备选

```python
from sklearn.svm import SVR
from sklearn.model_selection import cross_val_score
import numpy as np

# GWO 部分需自写, 类似 MATLAB
# 或用 scikit-opt 的 GWO
from sko.GWO import GWO
```

## 选型决策树

- **GWO-SVR** — SVR 超参数搜索空间连续平滑，GWO 收敛快
- **GA-SVR (PARADIGM-0105)** — 搜索空间更复杂/多峰时遗传算法更鲁棒
- **GridSearch CV** — 维数低 (C,γ 两个参数)，搜索空间小时网格搜索更稳妥
- **Bayesian Opt (PARADIGM-1002)** — 评估昂贵 (如大数据集 CV)，贝叶斯优化采样效率高

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | GWO 收敛曲线 (best score vs iter) | 验证收敛 |
| result | 预测 vs 真实散点图 | R², RMSE 标注 |
| result | 参数搜索轨迹 (C-γ 散点) | 展示搜索过程 |

## 常见坑

1. **CV 评估太耗时**: n_wolves × n_iter × kfold × SVR_train → 大数据上极慢。减少 n_wolves 或用 Hold-out 替代 CV
2. **GWO 早熟收敛**: 狼群快速聚集到局部最优 → 多样性不足。增大种群或引入随机扰动
3. **C, γ 在 log 尺度搜索**: 线性尺度下 GWO 的下限区域覆盖不足 → 狼位置取 log 编码或参数范围设宽

## 失效条件/反例 (强制小节)

- **条件1: 特征维度 p > 100 且噪声高** → 表现: SVR 的 RBF 核在高维噪声空间中 $K(\mathbf{x}_i,\mathbf{x}_j) \approx 0$ 对所有 $i \neq j$ (距离集中)，CV MSE 在超参数空间中变化平坦 → GWO 的适应度地形无梯度，狼群随机游走无收敛方向。**应对**: 先用 PCA/特征选择降维至 p < 20，或换用线性核 SVR
- **条件2: 数据集极小 (n < 100) + K-fold CV** → 表现: 每个 fold 的 MSE 方差极大，GWO 的适应度评价噪声淹没了真实的超参数优势 → GWO 收敛到噪声最优而非真实最优。**应对**: 使用 Leave-One-Out CV 或 Bootstrap 估计，或采用 Bayesian Optimization (显式建模噪声)

## 文献

1. Mirjalili S., Mirjalili S.M. & Lewis A. (2014). "Grey Wolf Optimizer." *Advances in Engineering Software*, 69:46-61. DOI: [10.1016/j.advengsoft.2013.12.007](https://doi.org/10.1016/j.advengsoft.2013.12.007)
2. Smola A.J. & Scholkopf B. (2004). "A tutorial on support vector regression." *Statistics and Computing*, 14(3):199-222. DOI: [10.1023/B:STCO.0000035301.49549.88](https://doi.org/10.1023/B:STCO.0000035301.49549.88)

## 来源溯源

自写 GWO + fitrsvm; 详见S5:gwo_svr.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0110 (GWO) |
| 前置 | PARADIGM-0205 (SVR) |
| 替代 | PARADIGM-0713 (GA-LSTM) |
| 替代 | PARADIGM-1002 (EGO 贝叶斯优化) |
