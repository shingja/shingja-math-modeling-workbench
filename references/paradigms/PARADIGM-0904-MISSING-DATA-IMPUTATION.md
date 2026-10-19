# PARADIGM-0904 缺失数据多重插补⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0904 |
| 类别/子类 | ⑨经典与杂项 / 数据处理 |
| 难度 | 中 |
| 适用题型关键词[] | 缺失数据, 多重插补, Multiple Imputation, MI, MAR, fillmissing, MICE, Rubin |
| confidence | high |
| source | Rubin (1987) Wiley |

## 数学形式

**缺失机制 (Rubin, 1976):**
- **MCAR (完全随机缺失):** $P(M \mid \mathbf{X}_{\text{obs}}, \mathbf{X}_{\text{miss}}) = P(M)$
- **MAR (随机缺失):** $P(M \mid \mathbf{X}_{\text{obs}}, \mathbf{X}_{\text{miss}}) = P(M \mid \mathbf{X}_{\text{obs}})$
- **MNAR (非随机缺失):** 依赖未观测值本身 → 最棘手

**多重插补 (MI) 三步骤:**

**步骤 1: 插补 (M 次)**
$$\mathbf{X}_{\text{miss}}^{(1)}, \mathbf{X}_{\text{miss}}^{(2)}, \ldots, \mathbf{X}_{\text{miss}}^{(M)}$$

产生 M 个完整数据集。常用 MICE (链式方程多重插补):
$$X_j^{(m)} \sim P(X_j \mid X_{-j}, \hat{\theta}^{(m-1)})$$

**步骤 2: 分析**
在每个完整数据集上拟合模型 → 得到 M 个估计 $\hat{Q}_m$ 和方差 $\hat{U}_m$

**步骤 3: 合并 (Rubin's Rules)**
$$\bar{Q} = \frac{1}{M}\sum_{m=1}^{M} \hat{Q}_m$$

**总方差:**
$$T = \bar{U} + \left(1 + \frac{1}{M}\right)B$$

其中:
- **组内方差:** $\bar{U} = \frac{1}{M}\sum U_m$
- **组间方差:** $B = \frac{1}{M-1}\sum (\hat{Q}_m - \bar{Q})^2$

**信息缺失率:**
$$\lambda = \frac{(1+M^{-1})B}{T}$$

**M 的选择:** 通常 M=5~20 (与信息缺失率平方相关)

**单值插补 (不推荐):** 均值/中位数/回归/Last-Observation-Carried-Forward (LOCF) → 低估方差。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| M (插补次数) | int | 10 | [5, 50] | 中 — M↑统计效率↑ |
| method | str | 'mice' | 'mean','median','knn','mice' | 高 |
| max_iter (MICE) | int | 10 | [5, 50] | 低 |
| 缺失比例阈值 | double | 0.3 | [0, 1] | 高 — >50% 变量建议删除 |

## MATLAB 实现

```matlab
% 基础方法 (fillmissing)
X_filled = fillmissing(X, 'movmean', 5);        % 移动均值
X_filled = fillmissing(X, 'linear');             % 线性插值
X_filled = fillmissing(X, 'nearest');            % 最近邻

% KNN 插补
X_filled = knnimpute(X);  % Bioinformatics Toolbox 或自写

% 自写 MICE 多重插补
function X_imp = mice_impute(X, M, max_iter)
    [n, p] = size(X);
    X_imp = cell(M, 1);
    for m = 1:M
        X_m = X;
        % 初始填充 (均值)
        for j = 1:p
            missing_idx = isnan(X(:,j));
            X_m(missing_idx, j) = mean(X(:,j), 'omitnan');
        end
        
        for iter = 1:max_iter
            for j = 1:p  % 对每个含缺变量
                missing_j = isnan(X(:,j));
                if ~any(missing_j), continue; end
                
                % 用其他变量回归预测缺失值
                obs_idx = ~missing_j;
                X_obs = X_m(obs_idx, [1:j-1, j+1:p]);
                y_obs = X_m(obs_idx, j);
                
                % 回归 + 随机噪声 (防止过度确定)
                beta = X_obs \ y_obs;
                y_pred = X_m(missing_j, [1:j-1, j+1:p]) * beta;
                sigma = std(y_obs - X_obs * beta);
                X_m(missing_j, j) = y_pred + sigma * randn(sum(missing_j),1);
            end
        end
        X_imp{m} = X_m;
    end
end
```

锚点: `fillmissing` (MATLAB内置) + 自写MICE-见S5:mice_impute.m

## Python 备选

```python
# scikit-learn
from sklearn.impute import SimpleImputer, KNNImputer
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer  # MICE

imp = IterativeImputer(max_iter=10, random_state=42, sample_posterior=True)
X_imputed = imp.fit_transform(X)
```

## 选型决策树

- **MICE** — MAR，多变量，需要正确统计推断 (SE/CI)
- **均值/中位数插补** — 仅 MCAR + 缺失 < 5% + 不关心推断
- **KNN 插补** — 数据局部结构强，相似样本可找到
- **LOCF** — 纵向数据，缺失在随访间
- **不要插补** — MNAR 时插补有偏 (需要模式混合模型或选择模型)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 缺失模式矩阵 (imagesc/spy) | 缺失 pattern 可视化 |
| process | M 次插补值分布 (箱线图) | 插补不确定性 |
| result | 完整数据后模型参数 CI (含插补方差) | 与未插补对比 |

## 常见坑

1. **插补后未增加方差**: 单值插补后当完整数据处理 → SE 被低估 → p 值虚小。必须用 MI + Rubin's Rules
2. **缺失比例极高 (> 50%) 的变量**: 基于其他变量的回归插补实际上是用其他变量预测该变量 → 几乎不提供新信息。建议删除或单独分析该变量
3. **MICE 的迭代链收敛**: MICE 本质上是在条件分布之间做 Gibbs 采样 → 需要足够迭代轮数 (一般 max_iter=10-20)

## 失效条件/反例 (强制小节)

- **条件1: MNAR (非随机缺失, 如高收入者更不愿报告收入)** → 表现: 缺失依赖于未观测值本身 → MICE 的 MAR 假设违例，插补值系统性向低值偏斜 → 回归系数的插补后估计仍有偏 (偏差量不可知)。**应对**: 使用模式混合模型 (Pattern-Mixture) 并做敏感性分析 (假设不同缺失机制下的结果范围)
- **条件2: 高维 (p > 100) + 每个变量都有少量缺失** → 表现: MICE 需要对每个含缺变量用所有其他变量做回归 → p 个回归 × max_iter 轮 → O(p²) 开销，且 $p > n$ 时的回归需要正则化。**应对**: 使用低秩矩阵补全 (SoftImpute) 或 MissForest (随机森林插补，处理高维更鲁棒)

## 文献

1. Rubin D.B. (1987). *Multiple Imputation for Nonresponse in Surveys*. Wiley. ISBN: 978-0471087052
2. van Buuren S. (2018). *Flexible Imputation of Missing Data*, 2nd ed. CRC Press. ISBN: 978-1138588318

## 来源溯源

`fillmissing` + 自写 mice_impute.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0501 (预处理) |
| 组合 | PARADIGM-0705 (Bootstrap) |
| 组合 | PARADIGM-0502 (离群点处理) |
