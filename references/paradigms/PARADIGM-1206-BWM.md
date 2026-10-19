# PARADIGM-1206-BWM BWM: 最佳最劣法⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1206-BWM |
| 类别/子类 | ⑫多目标决策进阶 / 主观赋权 |
| 难度 | 中 |
| 适用题型关键词[] | 主观赋权, 成对比较, 最佳准则, 最劣准则, 一致性检验, 专家赋权 |
| confidence | high |
| source | 论文2015_BWM / 题解反推_Weight类 |

## 数学形式

**核心思想**: 决策者仅需识别最佳 (Best/Most important) 和最劣 (Worst/Least important) 准则, 然后分别进行 Best-to-Others 和 Others-to-Worst 的成对比较。相比 AHP ($O(n^2)$ 次比较), BWM 只需 $2n-3$ 次。

1. 确定最佳准则 $B$ 和最劣准则 $W$
2. 构造 Best-to-Others 向量: $\mathbf{A}_B = (a_{B1}, a_{B2}, \ldots, a_{Bn})$ (1-9 标度)
3. 构造 Others-to-Worst 向量: $\mathbf{A}_W = (a_{1W}, a_{2W}, \ldots, a_{nW})^T$ (1-9 标度)
4. 求解非线性优化 (或等价 LP):
   $$\min_{\xi, \mathbf{w}} \xi$$
   $$\text{s.t.} \quad \left|\frac{w_B}{w_j} - a_{Bj}\right| \leq \xi, \; \forall j; \quad \left|\frac{w_j}{w_W} - a_{jW}\right| \leq \xi, \; \forall j$$
   $$\sum_j w_j = 1, \; w_j \geq 0$$
5. 一致性比率: $CR = \xi^* / CI$ (CI 查表); $CR < 0.1$ 即可接受

| 变量 | 含义 | 范围 |
|------|------|------|
| $a_{Bj}$ | 最佳准则比准则 $j$ 的重要度 | 1-9 |
| $a_{jW}$ | 准则 $j$ 比最劣准则的重要度 | 1-9 |
| $\xi^*$ | 优化得到的一致性指标 | $\geq 0$ |
| $CI$ | 一致性指标 (查表, 取决于 $a_{BW}$) | 0.44-5.23 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| $a_{BW}$ (最佳比最劣) | int | — | 1-9 | 极高—决定整体一致性基准 |
| 求解方法 | enum | LP | LP/Nonlinear | 中—LP更稳定, NLP理论上更精确 |
| CR阈值 | float | 0.1 | 0.05-0.15 | 低—标准值即可 |

**时间复杂度**: 小型 LP 求解, 毫秒级
**空间复杂度**: $O(n)$

## MATLAB 实现

```matlab
% 自写 BWM 线性规划求解版本
% 自写LP-见S5:bwm_weight.m

% 实现步骤:
% 1. 输入 Best/Worst 准则编号及比较向量 A_B, A_W
% 2. 构造 LP: 变量 [xi, w1, w2, ..., wn]
% 3. 约束: |w_B/w_j - a_Bj| <= xi (线性化为4条约束)
% 4. 约束: |w_j/w_W - a_jW| <= xi (线性化为4条约束)
% 5. linprog 求解, 输出最优权重和 CR
```

**锚点工具箱**: `linprog` (Optimization Toolbox) — 等价 LP 求解

## Python 备选

```python
from scipy.optimize import linprog
import numpy as np

def bwm_weight(a_B, a_W, best_idx, worst_idx):
    n = len(a_B)
    # 构造 LP: min xi, s.t. 线性化约束 + sum(w)=1
    # a_B[j] * w_j - w_B + xi * w_j >= 0  etc.
    # 线性化需假设 w_j 量级; 简化: 分式规划用迭代
    from scipy.optimize import minimize
    def objective(w):
        return max(abs(w[best_idx]/w[j] - a_B[j]) for j in range(len(a_B))) + \
               max(abs(w[j]/w[worst_idx] - a_W[j]) for j in range(len(a_W)))
    # ... constrained optimization
    return w
```

## 选型决策树

- **准则数 $n \geq 5$ + 需主观赋权** → BWM (比 AHP 节省 60%+ 比较次数, 一致性更高)
- **准则 $n \leq 4$** → AHP 和 BWM 均可 (比较次数相近), AHP 更普及
- **决策者无法确定单一 Best/Worst** → 考虑多个 Best 的扩展 BWM, 或回归 AHP
- **仅需客观赋权** → CRITIC (PARADIGM-1205)/熵权法
- **准则有网络依赖** → DEMATEL-ANP (PARADIGM-1208)

## 典型图型

- **raw**: 成对比较矩阵可视化 (A_B 和 A_W)
- **process**: LP 求解后 $\xi$ 与各约束松弛量柱状图
- **result**: 权重降序柱状图; 灵敏度分析: B/W 定义变化对权重的影响

## 常见坑

1. **未定义 Best/Worst 的认知负担**: 准则数多时难选单一最佳/最劣 → 验证用"如果换一个 Best"是否稳定
2. **$a_{BW}$ 设定与其他比较不一致**: $a_{Bj} \times a_{jW} \neq a_{BW}$ 导致 $\xi$ 大, CR 高 → 调回修改比较矩阵
3. **LP vs 非线性解不同**: 线性化引入近似 → LP 版本 $\xi$ 稍大但更鲁棒
4. **多最优解**: 当 $\xi^* = 0$ 时可能有多个权重向量满足约束 → 补充成对比较或直接任选

## 失效条件/反例 (强制小节)

- **条件1**: 决策者无法一致地识别单一 Best 或 Worst 准则 → BWM 框架假定 Best/Worst 存在且唯一; 若有两个准则"无法区分哪个更重要", 扩展 BWM 可用但不成熟。**替代**: 传统 AHP (接受 $n(n-1)/2$ 次比较)
- **条件2**: 准则数 $n$ 极多 ($>20$) → Best-to-Others 向量长度增长, 认知负担上升, BWM 相比 AHP 的优势缩小。**替代**: 分组 + 层级赋权 (两阶段 AHP/分治)
- **条件3**: 比较标度偏好乘法关系而非加法关系 → BWM 用比率标度, 但 1-9 标度可能不足以捕捉极端差异 ($a_{BW} > 9$)。**替代**: 换用连续标度或 DEMATEL 的影响关系矩阵

## 文献

1. Rezaei, J. (2015). Best-worst multi-criteria decision-making method. *Omega*, 53, 49-57. DOI: [10.1016/j.omega.2014.11.009](https://doi.org/10.1016/j.omega.2014.11.009)
2. Rezaei, J. (2016). Best-worst multi-criteria decision-making method: Some properties and a linear model. *Omega*, 64, 126-130. DOI: [10.1016/j.omega.2015.12.001](https://doi.org/10.1016/j.omega.2015.12.001)

## 来源溯源

- 论文三元组: Rezaei 2015, BWM, best-worst reference comparisons + consistency ratio
- 教学用例: 供应商选择准则赋权, 物流绩效指标排序

## 关联范式卡

组合: PARADIGM-1204-VIKOR (BWM赋权 + VIKOR排序), PARADIGM-1207-PROMETHEE
替代: AHP (小准则), PARADIGM-1205-CRITIC (客观赋权), PARADIGM-1208-DEMATEL-ANP (网络依赖)
