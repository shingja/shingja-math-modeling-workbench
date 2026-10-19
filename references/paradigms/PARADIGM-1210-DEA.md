# PARADIGM-1210-DEA DEA: 数据包络分析⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1210-DEA |
| 类别/子类 | ⑫多目标决策进阶 / 效率评价 |
| 难度 | 中 |
| 适用题型关键词[] | 效率评价, 投入产出, 相对效率, 技术效率, 规模效率, 决策单元 |
| confidence | high |
| source | 论文1978_DEA / 教材第12章 / 已有代码 dea_analyze.m |

## 数学形式

**CCR 模型 (假设规模报酬不变, CRS)**: 对于 DMU$_0$ (被评价单元):
$$\max_{\mathbf{u}, \mathbf{v}} \frac{\sum_{r=1}^{s} u_r y_{r0}}{\sum_{i=1}^{m} v_i x_{i0}}$$
$$\text{s.t.} \quad \frac{\sum u_r y_{rj}}{\sum v_i x_{ij}} \leq 1, \; \forall j; \quad u_r, v_i \geq 0$$

等价线性规划 (CCR 乘子型):
$$\max_{\mathbf{u}, \mathbf{v}} \sum_{r=1}^{s} u_r y_{r0}$$
$$\text{s.t.} \quad \sum_{i=1}^{m} v_i x_{i0} = 1, \; \sum_{r=1}^{s} u_r y_{rj} - \sum_{i=1}^{m} v_i x_{ij} \leq 0 \; \forall j$$

**BCC 模型 (假设规模报酬可变, VRS)**: 添加 $\sum \lambda_j = 1$ 到对偶形式, 将技术效率 $\theta_{CRS}$ 分解为纯技术效率 $\theta_{VRS}$ 和规模效率 $\theta_{VRS}/\theta_{CRS}$

| 变量 | 含义 |
|------|------|
| $n$ | DMU 数量 (决策单元) |
| $m$ | 投入指标数 |
| $s$ | 产出指标数 |
| $x_{ij}$ | DMU $j$ 的第 $i$ 个投入 |
| $y_{rj}$ | DMU $j$ 的第 $r$ 个产出 |
| $\theta$ | 效率值 (0-1, 1=有效) |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 模型类型 | enum | CCR | CCR/BCC | 高—BCC分离规模效率 |
| 投入/产出导向 | enum | 投入导向 | input/output | 中 |
| 投入/产出指标数 | — | — | 建议 $n \geq 3(m+s)$ | 高—指标过多拉高效率 |

**时间复杂度**: $O(n \cdot (m+s)^3)$ (每 DMU 求解一个 LP)
**空间复杂度**: $O(m \cdot s \cdot n)$

## MATLAB 实现

```matlab
% 已有实现
% matlab/eval/dea_analyze.m

% 内置支持: linprog 求解每 DMU 的 LP
% 实现:
% 1. 构建投入矩阵 X (n×m), 产出矩阵 Y (n×s)
% 2. 对每 DMU_0 构建 CCR LP: min θ, s.t. ...
% 3. linprog 求解对偶形式 (CCR 包络型)
% 4. 输出: 效率值, 参考集, 改进值
```

**锚点工具箱**: `linprog` (Optimization Toolbox) — 每 DMU 一次 LP

## Python 备选

```python
from scipy.optimize import linprog
import numpy as np

def dea_ccr(X, Y, orientation='input'):
    n, m = X.shape
    _, s = Y.shape
    efficiencies = np.zeros(n)
    for j0 in range(n):
        # CCR 包络型: min θ
        c = np.zeros(n + 1)
        c[0] = 1  # θ
        A_ub = ...  # 约束矩阵
        b_ub = ...
        res = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=(0, None))
        efficiencies[j0] = res.x[0]
    return efficiencies
```

备选: `pyDEA`, `DEAPy`

## 选型决策树

- **多投入多产出相对效率** → DEA (无需预设生产函数, 非参数)
- **单投入单产出** → 比率分析更直接, DEA 过度
- **需检验规模收益 (递增/不变/递减)** → DEA BCC 模型
- **效率 + 统计推断** → SFA (随机前沿, 参数法) 可检验显著性, DEA 不行
- **效率 + Malmquist 指数** → DEA 扩展, 适合面板数据 + 动态效率
- **投入/产出数据含噪声** → SFA 优于 DEA (DEA 将所有偏离视为无效率)

## 典型图型

- **raw**: 投入/产出散点矩阵 (各 DMU 在各指标上的分布)
- **process**: 两投入一产出的等产量线 + 效率前沿 (2D 可视化)
- **result**: 效率值降序柱状图 (标记 DEA 有效的 DMU), 效率分布直方图, 各投入/产出改进的雷达图

## 常见坑

1. **指标数过多拉高效率 (维数祸害)**: $m+s$ 接近 $n$ 时大多数 DMU 变为 DEA 有效 ($\theta=1$) → 建议 $n \geq 3(m+s)$
2. **投入产出方向混淆**: 投入应为 "越小越好", 产出 "越大越好" → 显式声明
3. **DEA 有效并非绝对有效**: $\theta=1$ 仅表示在样本中相对有效, 不代表绝对无改进空间
4. **outlier 使前沿偏斜**: 一个极端 DMU 主导前沿 → super-efficiency 模型检测 + 稳健 DEA

## 失效条件/反例 (强制小节)

- **条件1**: DMU 数量 $n < 3(m+s)$ (指标过多) → 超过 50% DMU 被评为 DEA 有效, 区分度丧失, 效率值不可信。**替代**: 先用 PCA/因子分析降维, 减少投入产出指标至 $n \geq 3(m+s)$
- **条件2**: 数据存在显著测量误差/噪声 → DEA 将所有偏离前沿归因于无效率, 可能严重高估无效率水平。**替代**: SFA (随机前沿分析, 分离噪声和无效率)
- **条件3**: 投入/产出指标高度共线 (相关性 > 0.9) → LP 多重解, 乘子权重可能任意且无法解释。**替代**: 删除高度相关指标, 保留最有代表性的
- **条件4**: DMU 数目 $n \leq 10$ → 前沿仅由少数 DMU 定义, 极不稳定 (删除一个 DMU 可能显著改变效率)。**替代**: 确保 $n \geq 20$ 再用 DEA

## 文献

1. Charnes, A., Cooper, W. W., & Rhodes, E. (1978). Measuring the efficiency of decision making units. *European Journal of Operational Research*, 2(6), 429-444. DOI: [10.1016/0377-2217(78)90138-8](https://doi.org/10.1016/0377-2217(78)90138-8)
2. Banker, R. D., Charnes, A., & Cooper, W. W. (1984). Some models for estimating technical and scale inefficiencies in data envelopment analysis. *Management Science*, 30(9), 1078-1092. DOI: [10.1287/mnsc.30.9.1078](https://doi.org/10.1287/mnsc.30.9.1078)

## 来源溯源

- 教材源路径: 数学建模算法与应用 第12章 综合评价
- 论文三元组: Charnes 1978, DEA CCR, relative efficiency + LP
- 已有代码: `matlab/eval/dea_analyze.m`

## 关联范式卡

组合: Malmquist 指数 (面板动态效率)
替代: SFA (参数法, 噪声分离), PARADIGM-0401-TOPSIS (方案排序而非效率)
