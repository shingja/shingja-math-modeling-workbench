# PARADIGM-0301 层次分析法 (AHP)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0301 |
| 类别/子类 | ③评价 / 主观赋权 |
| 难度 | 低 |
| 适用题型关键词[] | AHP, 层次分析法, 判断矩阵, 特征向量, 一致性检验, CR, RI, 成对比较, Saaty标度, 主观赋权, 指标体系, 权重确定, 多准则决策, MCDM |
| confidence | high |
| source | Saaty, T.L. (1980) *The Analytic Hierarchy Process*. McGraw-Hill, New York. |

## 数学形式

### 1. 构造判断矩阵

采用 Saaty 1-9 标度对 n 个指标进行两两比较, 构造判断矩阵:

$$A = (a_{ij})_{n \times n}, \quad a_{ij} = \frac{1}{a_{ji}}, \quad a_{ii} = 1$$

| 标度 | 含义 |
|------|------|
| 1 | i 与 j 同等重要 |
| 3 | i 比 j 稍微重要 |
| 5 | i 比 j 明显重要 |
| 7 | i 比 j 强烈重要 |
| 9 | i 比 j 极端重要 |
| 2,4,6,8 | 相邻标度的中间值 |

### 2. 权重计算

权重向量 $\boldsymbol{w}$ 为判断矩阵 A 的最大特征值 $\lambda_{\max}$ 对应的归一化特征向量:

$$A\boldsymbol{w} = \lambda_{\max}\boldsymbol{w}, \quad w_i = \frac{\tilde{w}_i}{\sum_{j=1}^n \tilde{w}_j}$$

### 3. 一致性检验

$$CI = \frac{\lambda_{\max} - n}{n - 1}$$

$$CR = \frac{CI}{RI}$$

其中 RI 为随机一致性指标 (Saaty 给出的标准值):

| n | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|---|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| RI | 0 | 0 | 0.58 | 0.90 | 1.12 | 1.24 | 1.32 | 1.41 | 1.45 | 1.49 | 1.51 | 1.54 | 1.56 | 1.58 | 1.59 |

当 $CR < 0.10$ 时, 认为判断矩阵具有满意的一致性, 否则需要调整判断矩阵。

### 4. 层次总排序

若准则层有 m 个元素, 权重为 $\boldsymbol{a} = (a_1,\ldots,a_m)$; 方案层对第 j 个准则的权重为 $\boldsymbol{b}_j = (b_{1j},\ldots,b_{nj})^T$, 则方案层总排序为:

$$W_i = \sum_{j=1}^m a_j \cdot b_{ij}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 指标数 n | int | — | 3~15 | 高 — n>15 一致性难保证 |
| 判断矩阵 A | matrix (n×n) | — | a_ij∈{1/9,...,9} | 极高 — 核心输入, 直接影响权重 |
| 一致性阈值 CR_threshold | float | 0.10 | 0.05~0.15 | 中 — 放宽则更多矩阵通过但结果不可靠 |
| RI 表 | array | Saaty 标准值 | — | 低 — 查表值固定 |

**复杂度**: 空间 O(n^2), 时间 O(n^3) (特征值分解 eig), n≤15 时计算可忽略不计。

## MATLAB 实现

```matlab
% ===== PARADIGM-0301-AHP: 层次分析法权重计算 =====
function [w, CR, lambda_max] = ahp_weight(A)
    % A: n×n 判断矩阵, a_ij = 1/a_ji
    % w: 归一化权重向量
    % CR: 一致性比率
    % lambda_max: 最大特征值

    n = size(A, 1);

    % --- 计算特征值与特征向量 ---
    [V, D] = eig(A);
    lambda_vec = diag(D);
    [lambda_max, idx] = max(lambda_vec);
    w_raw = V(:, idx);           % 最大特征值对应特征向量
    w = w_raw / sum(w_raw);      % 归一化

    % --- 一致性检验 ---
    CI = (lambda_max - n) / (n - 1);

    % Saaty 随机一致性指标 RI 表 (n=1..15)
    RI_table = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, ...
                1.45, 1.49, 1.51, 1.54, 1.56, 1.58, 1.59];
    if n <= 15
        RI = RI_table(n);
    else
        RI = 1.59 + (n - 15) * 0.02;  % 外推 (不推荐)
        warning('n>15, RI外推不精确, 建议降维或分组AHP');
    end

    CR = CI / RI;

    if CR < 0.10
        fprintf('一致性检验通过: CR = %.4f < 0.10\n', CR);
    else
        fprintf('一致性检验未通过: CR = %.4f >= 0.10, 请调整判断矩阵\n', CR);
    end
end
```

**脚本依赖**: 纯根基 `eig` (MATLAB 内置函数, 无需任何工具箱)

## Python 备选

```python
import numpy as np

def ahp_weight(A: np.ndarray):
    """层次分析法权重计算 (纯 numpy, 无额外依赖)"""
    n = A.shape[0]

    # 特征值分解
    eigenvalues, eigenvectors = np.linalg.eig(A)
    idx = np.argmax(eigenvalues.real)
    lambda_max = eigenvalues[idx].real
    w = eigenvectors[:, idx].real
    w = w / w.sum()

    # 一致性检验
    CI = (lambda_max - n) / (n - 1)
    RI_table = {1:0, 2:0, 3:0.58, 4:0.90, 5:1.12, 6:1.24, 7:1.32,
                8:1.41, 9:1.45, 10:1.49, 11:1.51, 12:1.54,
                13:1.56, 14:1.58, 15:1.59}
    RI = RI_table.get(n, 1.59 + (n - 15) * 0.02)
    CR = CI / RI

    return w, CR, lambda_max
```

## 选型决策树

```
需要为指标体系确定权重
│
├─ 有领域专家可提供判断 → AHP ✓ (本范式)
│   ├─ 指标数 ≤ 9 → 标准 AHP, 判断矩阵小
│   ├─ 9 < n ≤ 15 → 可用但边际, 建议分组 AHP
│   └─ n > 15 → ❌ 不建议, 改用 ANP 或 DEMATEL
│
├─ 仅有数据无专家 → 客观赋权
│   ├─ 指标差异明显 → 熵权法 (PARADIGM-0303)
│   └─ 量纲不同 → 变异系数法 (PARADIGM-0307)
│
└─ 模糊不确定判断 → 模糊 AHP 或模糊综合评价 (PARADIGM-0304)
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 模型构建 | 层次结构图 (目标-准则-方案三层) | 展示指标体系层次分解 |
| 一致性检验 | 条形图 — 各判断矩阵 CR 值 | 标注 0.10 阈值线 |
| 权重展示 | 堆叠条形图 — 准则层+方案层总排序权重 | 颜色区分层次, 数值标注 |
| 灵敏度分析 | 折线图 — 单准则权重变动对总排序影响 | tornado 图型展示敏感指标 |

## 常见坑

1. **标度误用**: 用 1-5 标度或 1-100 标度代替 1-9 标度, 导致判断矩阵尺度不匹配 RI 表. 一致性检验公式中的 RI 表仅在 Saaty 1-9 标度下校准过.
2. **CR 机械通过**: CR<0.10 不代表判断矩阵合理 — 可能存在逻辑反转 (如 A>B, B>C, 但 C>A 被忽略) 未被检测. 建议结合几何一致性指标 (GCI) 做二次校验.
3. **层次传递误差**: 三层 AHP 中, 准则层和方案层的判断误差在总排序中叠加放大. 当两层都有边界一致性时 (如均 CR=0.09), 总排序的等效 CR 可能 >0.15.
4. **RI 外推风险**: n>15 时 RI 表无标准值, 多项式外推不可靠. 应用分组 AHP 或改用网络层次分析法 (ANP).
5. **归一化方式不统一**: 特征向量法、算术平均法、几何平均法给出的权重略有不同, 必须统一说明所采用方法.

## 失效条件/反例 (强制小节)

- **条件1 — 指标数 n>15**: 两两比较次数为 n(n-1)/2, n=15 时需 105 次判断, 专家认知负荷过大, 判断疲劳导致一致性严重衰减. 实践中 n>12 即显著退化. 此时应改用分组 AHP (聚类指标, 分层逐级比较) 或 ANP (网络层次分析法).
- **条件2 — 专家意见严重分歧 (群决策失败)**: 多位专家给出的判断矩阵无法通过几何平均或加权调和达成一致, CR 值系统性超标 (如 5 位专家中有 3 位的 CR>0.15). 单纯取平均会掩盖真实偏好结构, 此时应改用 Delphi 法多轮收敛, 或 Bayesian AHP 显式建模意见分歧.
- **条件3 — 指标间存在强线性或因果关联**: AHP 的层次结构隐含"同层指标相互独立"的假设. 若指标 A 和指标 B 高度相关 (如 GDP 与人均收入), 则双计入导致二者实际权重被放大. 需改用 ANP (网络层次分析法) 或先对指标做因果分析 (DEMATEL) 再结合 AHP (DEMATEL-ANP 串联).

## 文献

1. Saaty, T. L. (1980). *The Analytic Hierarchy Process*. McGraw-Hill. (原始著作)
2. Saaty, T. L. (2008). Decision making with the analytic hierarchy process. *International Journal of Services Sciences*, 1(1), 83-98. (精简回顾)
3. Saaty, T. L. (1990). How to make a decision: the analytic hierarchy process. *European Journal of Operational Research*, 48(1), 9-26. (应用指南)
4. 刘豹, 许树柏, 赵焕臣. (1988). 层次分析法—规划决策的工具. *系统工程*, 6(2).
5. Alonso, J. A., & Lamata, M. T. (2006). Consistency in the analytic hierarchy process: a new approach. *International Journal of Uncertainty, Fuzziness and Knowledge-Based Systems*, 14(04), 445-459.

## 来源溯源

AHP 由 Thomas L. Saaty 于 1970 年代在沃顿商学院和美国国防部工作期间创立, 最早用于伊朗军备采购决策和蘇丹运输系统规划. 核心创新在于将定性判断定量化为成对比较矩阵, 并通过特征向量法提取权重, 辅以 CR 作为一致性质量控制. 1980 年 McGraw-Hill 专著奠定其数学基础和工程应用范式. 此后发展为 ANP (1996)、模糊 AHP 等分支, 是运筹学中引用量最高的多准则决策方法之一.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 主观赋权同级对比 (客观) | PARADIGM-0303 (熵权法) |
| 主观赋权同级对比 (客观) | PARADIGM-0307 (变异系数法) |
| 组合赋权搭档 (主客观结合) | PARADIGM-0303 + PARADIGM-0301 乘法合成 |
| 评价下游 (用 AHP 权重驱动) | PARADIGM-0302 (TOPSIS) |
| 评价下游 (用 AHP 权重驱动) | PARADIGM-0304 (模糊综合评价) |
| 替代方案 (指标相关时) | DEMATEL-ANP (非本 Skill, 需自建) |
| 群决策扩展 | 群组 AHP (几何平均法/加权算术平均法) |
