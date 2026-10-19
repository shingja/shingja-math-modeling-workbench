# PARADIGM-0118 双层规划⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0118 |
| 类别/子类 | ①优化 / 分层决策 |
| 难度 | 高 |
| 适用题型关键词[] | 双层规划, Bilevel Programming, 领导者-追随者, Stackelberg, 嵌套优化, fmincon |
| confidence | medium |
| source | Bard (1998) Kluwer |

## 数学形式

**双层规划 (Bilevel Programming):**

**上层 (Leader):**
$$\min_{\mathbf{x}} \; F(\mathbf{x}, \mathbf{y})$$
$$\text{s.t.} \; G(\mathbf{x}, \mathbf{y}) \leq 0$$

**下层 (Follower):**
$$\mathbf{y} \in \arg\min_{\mathbf{y}} \; f(\mathbf{x}, \mathbf{y})$$
$$\text{s.t.} \; g(\mathbf{x}, \mathbf{y}) \leq 0$$

- 领导者先决策 $\mathbf{x}$，追随者看到 $\mathbf{x}$ 后最优响应 $\mathbf{y}^*(\mathbf{x})$
- 嵌套结构: 下层问题是上层约束的一部分

**KKT 单层化 (下层为凸优化时):**
将下层问题替换为其 KKT 条件:
$$\nabla_\mathbf{y} f(\mathbf{x}, \mathbf{y}) + \sum \lambda_i \nabla_\mathbf{y} g_i(\mathbf{x}, \mathbf{y}) = 0$$
$$g_i(\mathbf{x}, \mathbf{y}) \leq 0, \quad \lambda_i \geq 0, \quad \lambda_i g_i = 0$$

从而双层 → 带互补约束的单层问题 (MPCC)。

**数值解法 (fmincon 嵌套):**
```matlab
function [F_opt, x_opt] = bilevel_solve(F_fn, f_fn, G_fn, g_fn, lb, ub)
    % 上层: fmincon 搜索 x
    % 下层: 对每个 x 调用 fmincon 求 y*(x)
    outer_obj = @(x) upper_level(x, F_fn, f_fn, g_fn);
    [x_opt, F_opt] = fmincon(outer_obj, x0, [], [], [], [], lb, ub, @upper_constraints);
end

function F_val = upper_level(x, F_fn, f_fn, g_fn)
    % 内层: 求解追随者的最优响应
    y_opt = fmincon(@(y) f_fn(x,y), y0, [], [], [], [], [], [], @(y) g_fn(x,y));
    F_val = F_fn(x, y_opt);
end
```

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 嵌套层数 | — | 2 | 2 (标准) | — |
| 下层解唯一性 | — | — | — | 极高 — 下层的多最优解使上层定义模糊 |
| 复杂度 (嵌套) | — | — | O(外层迭代 × 内层优化) | — |
| 复杂度 (KKT) | — | — | 单层 O((n+m)³) | — |

## MATLAB 实现

```matlab
% 嵌套求解 (通用但慢)
function [x_opt, F_opt, y_opt] = bilevel_fmincon(F, f, x0, y0, lb, ub)
    % 外层 fmincon
    function obj = outer_obj(x)
        % 内层 fmincon → 追随者最优响应
        inner_problem = @(y) f(x, y);
        [y_star, ~] = fmincon(inner_problem, y0, [], [], [], [], [], [], ...
            @(y) deal(g(x,y), []));
        obj = F(x, y_star);
    end
    
    [x_opt, F_opt] = fmincon(@outer_obj, x0, [], [], [], [], lb, ub);
    
    % 最终 y*
    y_opt = fmincon(@(y) f(x_opt, y), y0, [], [], [], [], [], [], ...
        @(y) deal(g(x_opt, y), []));
end
```

锚点: `fmincon` 嵌套-见S5:bilevel_fmincon.m

## Python 备选

```python
from scipy.optimize import minimize
# Pao (Pyomo bilevel)
# 或 BilevelJuMP (Julia)
```

## 选型决策树

- **双层规划** — 存在明确的 Stackelberg 领导-追随关系
- **单层多目标** — 无层次结构，所有目标同时优化
- **MPEC/MPCC** — 下层为凸 → KKT 转化为互补约束问题 (用专门求解器)
- **Stackelberg Game** — 同构双层但带博弈元素 (多个追随者)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 战略/战术分层结构图 | 示意决策顺序 |
| result | 上层目标 vs 下层响应 (1D x 的曲线) | 展示嵌套关系 |
| result | 可行域变化 (下层约束在不同 x 下) | 展示 induced region |

## 常见坑

1. **下层多最优解 (乐观 vs 悲观)**: 追随者对多个最优解无偏好 → 上层应选择乐观 (有利于 Leader) 还是悲观 (保守)? 需在建模时明确
2. **嵌套求解极度耗时**: 外层每函数评估 = 一次完整内层优化 → 评估次数 O(100) × O(100) = 10000 次内层优化
3. **KKT 转化后的互补约束**: MPCC 在标准 NLP 求解器上可能违反约束规格 (MFCQ) → 用专门 MPCC 求解器或正则化

## 失效条件/反例 (强制小节)

- **条件1: 下层问题非凸 (存在多个局部最优解)** → 表现: 追随者在多个局部最优间"跳跃" (fmincon 找到不同 $\mathbf{y}^*$ 对接近的 $\mathbf{x}$)，上层目标 $F(\mathbf{x}, \mathbf{y}^*(\mathbf{x}))$ 不连续 → 上层 fmincon 梯度估计失败，优化失败。**应对**: 对下层使用多起点 fmincon (GlobalSearch) 确保全局最优，或假设下层凸性
- **条件2: 下层有等式约束 + KKT 罚函数法** → 表现: KKT 条件转化为互补约束的乘子 $\lambda$ 在求解中趋于无穷 → 数值不稳定，NLP 求解器在接近可行解时收敛困难。**应对**: 使用正则化方法 (如 Scholtes 全局松弛) 或完全避免 KKT 单层化，改用嵌套 + 代理模型加速

## 文献

1. Bard J.F. (1998). *Practical Bilevel Optimization: Algorithms and Applications*. Kluwer. ISBN: 978-0792354581
2. Dempe S. (2002). *Foundations of Bilevel Programming*. Springer. ISBN: 978-1402006319

## 来源溯源

fmincon 嵌套 bilevel_fmincon.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0103 (NLP fmincon) |
| 组合 | PARADIGM-0116 (MultiStart, 下层求解) |
| 组合 | PARADIGM-0701-GAME-NASH |
