# PARADIGM-0303 熵权法 (Entropy Weight Method)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0303 |
| 类别/子类 | ③评价 / 客观赋权 |
| 难度 | 低 |
| 适用题型关键词[] | 熵权法, EWM, 信息熵, Shannon熵, 客观权重, 离散度, 指标变异, 数据驱动赋权, 差异系数, 归一化, 客观赋权, entropy weight |
| confidence | high |
| source | Shannon, C.E. (1948) A Mathematical Theory of Communication. *Bell System Technical Journal*, 27(3), 379-423. |

## 数学形式

### 1. 数据归一化 (消除量纲)

设有 m 个样本, n 个指标, 原始数据矩阵 $X = (x_{ij})_{m \times n}$.

**正向指标** (越大越好):

$$p_{ij} = \frac{x_{ij} - \min(x_{:j})}{\max(x_{:j}) - \min(x_{:j})}$$

**负向指标** (越小越好):

$$p_{ij} = \frac{\max(x_{:j}) - x_{ij}}{\max(x_{:j}) - \min(x_{:j})}$$

为避免 $\ln(0)$, 平移 δ=0.0001: $p_{ij}' = p_{ij} + \delta$.

### 2. 计算比重矩阵

$$P_{ij} = \frac{p_{ij}'}{\sum_{i=1}^m p_{ij}'}$$

### 3. 计算信息熵

$$e_j = -k \sum_{i=1}^m P_{ij} \cdot \ln(P_{ij})$$

其中 Boltzmann 常数 $k = \frac{1}{\ln(m)} > 0$, 使得 $e_j \in [0, 1]$.

**信息论解释**: $e_j$ 越接近 1, 指标 j 在各样本的取值越均匀, 信息量越小.

### 4. 计算差异系数与权重

$$g_j = 1 - e_j \quad \text{(信息效用值 / 差异系数)}$$

$$w_j = \frac{g_j}{\sum_{j=1}^n g_j}$$

权重 $w_j$ 反映指标 j 的区分能力: 取值越离散的指标权重越大, 取值越一致的指标权重越小.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 样本数 m | int | — | ≥5 (推荐≥10) | 高 — m 小则熵估计不稳定 |
| 指标数 n | int | — | ≥2 | 中 — 指标越多权重越分散 |
| 归一化方法 | string | "min-max" | {"min-max", "sum"} | 低 — min-max 使用更广 |
| 平移常数 δ | float | 0.0001 | 1e-6 ~ 1e-3 | 极低 — 仅用于数值稳定性 |

**复杂度**: 空间 O(mn), 时间 O(mn) — 全为逐元素运算 + 一次求和, 极快.

## MATLAB 实现

```matlab
% ===== PARADIGM-0303-EWM: 自写-见S5:entropy_weight.m =====
function [w, e, g] = entropy_weight(X, dirs)
    % X: m×n 原始数据矩阵, 样本×指标
    % dirs: 1×n, 'b'=benefit (正向/越大越好), 'c'=cost (负向/越小越好)
    % w: 1×n 熵权向量
    % e: 1×n 信息熵
    % g: 1×n 差异系数 (1-e)

    [m, n] = size(X);

    if nargin < 2 || isempty(dirs)
        dirs = repmat('b', 1, n);
    end

    % --- Step 1: Min-Max 归一化 ---
    p = zeros(m, n);
    for j = 1:n
        xj = X(:, j);
        x_min = min(xj);
        x_max = max(xj);
        if x_max == x_min
            % 指标恒定 → 熵=1, 权重→0
            p(:, j) = 1/m;
        else
            if dirs(j) == 'b' || dirs(j) == 'B'
                p(:, j) = (xj - x_min) / (x_max - x_min);
            else
                p(:, j) = (x_max - xj) / (x_max - x_min);
            end
        end
    end

    % 平移避免 log(0)
    delta = 1e-4;
    p = p + delta;

    % --- Step 2: 计算比重矩阵 ---
    P = p ./ sum(p, 1);

    % --- Step 3: 计算信息熵 ---
    k = 1 / log(m);
    e = -k * sum(P .* log(P), 1);

    % --- Step 4: 差异系数与权重 ---
    g = 1 - e;
    w = g / sum(g);
end
```

## Python 备选

```python
import numpy as np

def entropy_weight(X: np.ndarray, dirs: np.ndarray = None) -> tuple:
    """熵权法客观赋权 (纯 numpy)"""
    m, n = X.shape

    if dirs is None:
        dirs = np.full(n, 'b')

    # Min-Max 归一化
    p = np.zeros((m, n))
    for j in range(n):
        xj = X[:, j]
        x_min, x_max = xj.min(), xj.max()
        if x_max == x_min:
            p[:, j] = 1.0 / m
        elif dirs[j] == 'b':
            p[:, j] = (xj - x_min) / (x_max - x_min)
        else:
            p[:, j] = (x_max - xj) / (x_max - x_min)

    # 平移 + 比重
    delta = 1e-4
    p = p + delta
    P = p / p.sum(axis=0)

    # 信息熵
    k = 1.0 / np.log(m)
    e = -k * np.sum(P * np.log(P), axis=0)

    # 差异系数与权重
    g = 1 - e
    w = g / g.sum()

    return w, e, g
```

## 选型决策树

```
需要从数据本身出发确定指标权重 (无专家)
│
├─ 指标有量纲差异, 关注数据离散度 → 熵权法 ✓ (本范式)
│   ├─ 样本量 m ≥ 10 → 熵估计可靠, 直接用
│   └─ 样本量 5 ≤ m < 10 → 可用但提醒结果不稳定
│
├─ 关注指标间对比度 (均值归一化) → 变异系数法 (PARADIGM-0307)
│   ├─ 均值可能接近零 → 不建议 CV 法, 用熵权法
│   └─ 指标量纲相同 → 两种方法结果通常一致
│
├─ 有专家判断结合数据 → 组合赋权
│   ├─ AHP (PARADIGM-0301) 主观 × 熵权法 (本范式) 客观
│   └─ 乘法合成: w_final = w_ahp ⊙ w_entropy (逐元素乘后归一化)
│
└─ 样本量极小 m<5 → ❌ 客观赋权均不可靠, 必须用主观赋权 (AHP)
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 权重展示 | 横向条形图 — 指标熵权 w_j 降序 | 颜色表示差异系数 g_j 大小 |
| 熵值分布 | 散点图 — (e_j, w_j) 每点一个指标 | 标注: 高熵→低权 (左上), 低熵→高权 (右下) |
| 归一化对比 | 箱线图 — 各指标归一化后分布 | 展示各指标离散度差异 (离散大→权重高) |
| 组合赋权 | 双轴图 — AHP 权重 vs 熵权 w_j | 散点+对角线, 识别主观 vs 客观赋权分歧指标 |

## 常见坑

1. **零值/微小值导致 ln(0)**: 归一化后 p_ij=0 时 ln(0) → 负无穷. 必须加平移常数 δ (常用 0.0001). 但 δ 取过大会使所有 p 被人为拉近, 减小区分度.
2. **样本量过小 (m<5)**: 熵的统计学基础要求样本量充分, m 太小熵估计方差大. 建议 m≥10, 竞赛中若样本少必须在论文中说明局限性.
3. **指标恒定问题**: 某指标在所有样本取值相同 → e_j=1, g_j=0, w_j=0. 数学上正确 (无信息), 但业务上该指标可能极为重要. 应单独讨论该指标的业务意义, 而非机械接受零权重.
4. **异常值劫持**: 一个极端异常值会大幅拉宽 min-max 范围, 使其他样本的归一化值挤在一起, 虚拟地提高了该指标的"区分度" (熵降低, 权重虚高). 建议先做异常值检测和处理 (Winsorize 或剔除).
5. **信息论的局限性**: Shannon 熵假设指标间独立. 两个高度相关的指标各自有独立熵值, 但在 TOPSIS 等下游方法中会造成信息重复. 应与相关性分析结合.

## 失效条件/反例 (强制小节)

- **条件1 — 样本量极小 n<5**: 熵权法依赖样本间取值差异来估计信息量. 当 m=2 或 3 时, 熵值几乎完全由一两个样本决定, 权重随机波动极大. 例如同一指标体系两次采样, 熵权可能从 [0.2, 0.5, 0.3] 变为 [0.45, 0.15, 0.4]. 此时客观赋权丧失可靠性, 应改用主观赋权 (AHP) 或等待更多样本.
- **条件2 — 指标值几乎恒定 (CV < 0.01)**: 若某指标在所有样本间几乎无变化 (如所有城市的"宪法遵守指数"均为 100), 则 e_j → 1, w_j → 0. 熵权法在信息论意义上判断正确 (该指标无区分力), 但在评价业务中该指标可能具有强制一票否决意义. 此时不能机械使用熵权, 需要业务专家介入设定保底权重.
- **条件3 — 异常值主导**: 某一样本在某个指标上的取值远超其余 (如 GDP 指标中, 北上广深为万亿级, 其余城市为百亿级), min-max 归一化后 90% 样本被压缩在 [0, 0.1] 区间, 仅少数样本分布在 [0.9, 1.0]. 熵值将因分布极不均匀而降低, 该指标获得虚高权重. 解决: 先做对数变换或 Winsorize 截尾处理.

## 文献

1. Shannon, C. E. (1948). A Mathematical Theory of Communication. *Bell System Technical Journal*, 27(3), 379-423. (原始信息论著作)
2. Zeleny, M. (1982). *Multiple Criteria Decision Making*. McGraw-Hill. (首次将 Shannon 熵引入 MCDM 赋权)
3. Hwang, C. L., & Yoon, K. (1981). *Multiple Attribute Decision Making*. Springer-Verlag. (MADM 经典, 含熵权法讨论)
4. 邱菀华. (2001). 管理决策与应用熵学. 机械工业出版社. (中文熵权法经典教材)
5. Zou, Z. H., Yun, Y., & Sun, J. N. (2006). Entropy method for determination of weight of evaluating indicators in fuzzy synthetic evaluation for water quality assessment. *Journal of Environmental Sciences*, 18(5), 1020-1023.

## 来源溯源

信息熵概念源于 Claude Shannon 1948 年的开创性论文"通信的数学理论". Shannon 定义熵为信息源不确定性的度量, 公式 $H = -\sum p_i \log p_i$ 成为信息论的基石. Zeleny (1982) 首次将这一思想移植到多准则决策中: 若某准则在备选方案间的取值高度一致, 则该准则对决策的分辨力低 (对应高熵), 应赋予低权重. 熵权法因此成为完全数据驱动的客观赋权方法, 与 AHP 等主观赋权方法互补, 广泛应用于环境评价、供应商选择、信用评级等领域.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 客观赋权同级对比 | PARADIGM-0307 (变异系数法) |
| 主观赋权对比/互补 | PARADIGM-0301 (AHP) |
| 组合赋权搭档 (乘法合成) | PARADIGM-0301 (AHP — 主观×客观) |
| 下游 — 用熵权驱动 TOPSIS | PARADIGM-0302 (TOPSIS) |
| 下游 — 用熵权驱动模糊综合评价 | PARADIGM-0304 (模糊综合评价) |
| 数据前处理 (异常值) | 箱线图 + Winsorize (pct 1/99) |
