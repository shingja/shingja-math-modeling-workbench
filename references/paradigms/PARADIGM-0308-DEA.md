# PARADIGM-0308 DEA 数据包络分析 (Data Envelopment Analysis)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0308 |
| 类别/子类 | ③评价 / 效率前沿 |
| 难度 | 高 |
| 适用题型关键词[] | DEA, 数据包络分析, CCR, BCC, 效率前沿, DMU, 投入产出, 技术效率, 规模效率, 相对效率, 包络面, 决策单元, 非参数前沿, 线性规划, efficiency frontier, super-efficiency, Malmquist |
| confidence | high |
| source | Charnes, A., Cooper, W.W. & Rhodes, E. (1978) Measuring the efficiency of decision making units. *European Journal of Operational Research*, 2(6), 429-444. |

## 数学形式

### 1. CCR 模型 (CRS — 规模报酬不变, Charnes-Cooper-Rhodes, 1978)

设有 n 个决策单元 (DMU), 每个 DMU 消耗 m 种投入 $x_{ik}$ 产出 s 种产出 $y_{rk}$.

对 DMU_0 的效率评价, 其 **投入导向 (input-oriented)** CCR 模型的对偶形式:

$$\begin{aligned}
\min \quad & \theta \\
\text{s.t.} \quad & \sum_{j=1}^n \lambda_j x_{ij} \leq \theta x_{i0}, \quad i = 1, \ldots, m \\
& \sum_{j=1}^n \lambda_j y_{rj} \geq y_{r0}, \quad r = 1, \ldots, s \\
& \lambda_j \geq 0, \quad j = 1, \ldots, n
\end{aligned}$$

其中 $\theta$ 为技术效率 (TE_CRS), $\theta \in (0, 1]$, $\theta = 1$ 表示 DEA 有效.

### 2. BCC 模型 (VRS — 规模报酬可变, Banker-Charnes-Cooper, 1984)

在 CCR 模型基础上增加凸性约束 $\sum_{j=1}^n \lambda_j = 1$:

$$\begin{aligned}
\min \quad & \theta_{VRS} \\
\text{s.t.} \quad & \sum_{j=1}^n \lambda_j x_{ij} \leq \theta_{VRS} x_{i0} \\
& \sum_{j=1}^n \lambda_j y_{rj} \geq y_{r0} \\
& \sum_{j=1}^n \lambda_j = 1 \\
& \lambda_j \geq 0
\end{aligned}$$

### 3. 规模效率分解

$$SE = \frac{TE_{CRS}}{TE_{VRS}}$$

- SE = 1: 规模有效 (optimal scale)
- SE < 1: 规模无效, 进一步判断规模报酬递增 (IRS) 或递减 (DRS)

### 4. Super-Efficiency (超效率, 用于区分 θ=1 的 DMU)

将 DMU_0 自身从参考集中移除: $\lambda_0 = 0$, 允许 $\theta > 1$.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| DMU 数量 n | int | — | ≥ max{m·s, 3(m+s)} | 极高 — 不足则区分度崩溃 |
| 投入指标数 m | int | — | ≥1, 推荐 2~5 | 高 — 越多越需要更多 DMU |
| 产出指标数 s | int | — | ≥1, 推荐 2~5 | 高 |
| 规模报酬假设 | string | "VRS" | {"CRS", "VRS"} | 中 — CRS 效率 ≤ VRS 效率 |
| 导向 | string | "input" | {"input", "output"} | 中 — 投入导向 vs 产出导向 |
| 模型类型 | string | "BCC" | {"CCR", "BCC", "Super"} | — |

**复杂度**: 对每个 DMU 求解一个线性规划 (LP). 总时间 O(n × n^3 × ε) = O(n^4) 若用单纯形, 或 O(n × √n × L) 若用内点法. n=50 时秒级完成, n=500 时需分钟级.

## MATLAB 实现

```matlab
% ===== PARADIGM-0308-DEA: 已有 matlab/eval/dea_analyze.m (linprog求解) =====
function [theta, lambda, slack_in, slack_out] = dea_ccr_input(X, Y)
    % X: m×n 投入矩阵 (m种投入, n个DMU)
    % Y: s×n 产出矩阵 (s种产出, n个DMU)
    % theta: 1×n 效率值向量
    % lambda: n×n 权重矩阵 (每列对应一个DMU的评价)
    % slack_in: m×n 投入松弛变量
    % slack_out: s×n 产出松弛变量

    [m, n] = size(X);   % m=投入数, n=DMU数
    s = size(Y, 1);     % s=产出数

    theta = zeros(1, n);
    lambda = zeros(n, n);

    % --- 对每个 DMU 求解 LP ---
    for j0 = 1:n
        x0 = X(:, j0);   % DMU_0 的投入向量
        y0 = Y(:, j0);   % DMU_0 的产出向量

        % 决策变量: [theta; lambda_1; ...; lambda_n]
        % min  f' * x  s.t.  A*x <= b,  Aeq*x = beq,  lb <= x

        % 目标: min theta
        f = [1; zeros(n, 1)];

        % 不等式约束: Σ λ_j x_ij - θ x_i0 <= 0  →  [-x_i0, x_{i1},...,x_{in}] * [θ;λ] <= 0
        %                -Σ λ_j y_rj <= -y_r0   →  [0, -y_{r1},...,-y_{rn}] * [θ;λ] <= -y_r0
        A_ineq1 = [-x0, X];                % m 个投入约束
        A_ineq2 = [zeros(s, 1), -Y];       % s 个产出约束
        A = [A_ineq1; A_ineq2];
        b = [zeros(m, 1); -y0];

        % 下界: θ >= 0 (theta 无上界, linprog f≥0), λ_j >= 0
        lb = [0; zeros(n, 1)];   % theta 无上界约束按理论 >= 0

        % 求解线性规划
        options = optimoptions('linprog', 'Display', 'off', ...
                               'Algorithm', 'dual-simplex');
        [x_opt, ~, exitflag] = linprog(f, A, b, [], [], lb, [], options);

        if exitflag ~= 1
            warning('DMU %d LP求解失败 (exitflag=%d), 设 theta=NaN', j0, exitflag);
            theta(j0) = NaN;
            continue;
        end

        theta(j0) = x_opt(1);
        lambda(:, j0) = x_opt(2:end);
    end
end

function [theta_vrs, lambda_vrs] = dea_bcc_input(X, Y)
    % BCC 模型 (VRS): CCR + Σλ=1 约束
    [m, n] = size(X);
    s = size(Y, 1);

    theta_vrs = zeros(1, n);
    lambda_vrs = zeros(n, n);

    for j0 = 1:n
        x0 = X(:, j0);
        y0 = Y(:, j0);

        f = [1; zeros(n, 1)];

        A_ineq1 = [-x0, X];
        A_ineq2 = [zeros(s, 1), -Y];
        A = [A_ineq1; A_ineq2];
        b = [zeros(m, 1); -y0];

        % 等式约束: Σ λ_j = 1
        Aeq = [0, ones(1, n)];
        beq = 1;

        lb = [0; zeros(n, 1)];

        options = optimoptions('linprog', 'Display', 'off', ...
                               'Algorithm', 'dual-simplex');
        [x_opt, ~, exitflag] = linprog(f, A, b, Aeq, beq, lb, [], options);

        if exitflag == 1
            theta_vrs(j0) = x_opt(1);
            lambda_vrs(:, j0) = x_opt(2:end);
        else
            theta_vrs(j0) = NaN;
        end
    end
end
```

**注意**: 此实现使用 `linprog` (Optimization Toolbox), 属于 MATLAB 根基函数. n>100 时建议加内点法选项以提高速度.

## Python 备选

```python
import numpy as np
from scipy.optimize import linprog

def dea_ccr_input(X: np.ndarray, Y: np.ndarray) -> tuple:
    """CCR-DEA 投入导向 (需 scipy)"""
    m, n = X.shape   # 投入数, DMU数
    s = Y.shape[0]   # 产出数

    theta = np.zeros(n)
    lambdas = np.zeros((n, n))

    for j0 in range(n):
        x0 = X[:, j0]
        y0 = Y[:, j0]

        # 目标: min θ
        c = np.hstack([1.0, np.zeros(n)])

        # 不等式约束
        A_ub1 = np.hstack([-x0.reshape(-1, 1), X])       # Σ λ_j x_ij ≤ θ x_i0
        A_ub2 = np.hstack([np.zeros((s, 1)), -Y])         # -Σ λ_j y_rj ≤ -y_r0
        A_ub = np.vstack([A_ub1, A_ub2])
        b_ub = np.hstack([np.zeros(m), -y0])

        bounds = [(0, None)] + [(0, None)] * n

        res = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds,
                      method='highs')

        if res.success:
            theta[j0] = res.x[0]
            lambdas[:, j0] = res.x[1:]
        else:
            theta[j0] = np.nan

    return theta, lambdas
```

## 选型决策树

```
评价多个决策单元 (DMU) 的投入产出效率
│
├─ 多投入多产出, 无须预设生产函数 → DEA ✓ (本范式)
│   ├─ 规模报酬不变 (所有 DMU 在最优规模) → CCR 模型
│   ├─ 规模报酬可变 (DMU 规模差异大) → BCC 模型, 分解为纯技术效率 × 规模效率
│   ├─ 多个 DMU θ=1 需进一步区分 → Super-Efficiency DEA
│   └─ 面板数据, 比较时间趋势 → Malmquist 指数 (DEA 动态扩展)
│
├─ 单投入单产出 → 直接用比率分析 (产出/投入), 无需 LP
├─ 预设生产函数形式 (Cobb-Douglas/Translog) → 随机前沿分析 (SFA, 参数法)
│   └─ 有随机误差项需求 → SFA 能将误差分解为 inefficiency + noise
├─ 效率 + 排序综合 → DEA-EWM-TOPSIS 串联
└─ DMU 数量不足 → ❌ 放弃 DEA, 改用比率分析或 SFA
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 效率前沿 (2D) | 散点图 + 包络线 — 投入产出空间 | CCR 射线前沿, BCC 分段线性凸包 |
| 效率分布 | 直方图 — 各 DMU 效率值 θ 分布 | 叠加 KDE, 标注 θ=1 的 DMU 占比 |
| 效率分解 | 堆叠条形图 — TE_crs / PTE_vrs / SE | 识别效率损失的来源 (纯技术 vs 规模) |
| 效率-规模矩阵 | 散点图 — PTE vs SE, 四分象限 | 识别改进方向 (技术改进 / 规模调整) |
| 投入产出投影 | 散点图 — 无效 DMU 到前沿的投影向量 | 箭头指向目标改进值 |

## 常见坑

1. **DMU 数量不足导致 θ=1 泛滥**: 经验法则要求 n ≥ max{m×s, 3(m+s)}. 若 n 不足, 大量 DMU 会被评为"有效"(θ=1), 前沿面过拟合, 区分度为零. 必须精简指标 (用 PCA 或专家筛选) 或增加 DMU.
2. **投入产出指标的线性相关**: 若两个投入指标高度相关 (如员工数和薪资总额), DEA 会在二者之间任意分配权重, 导致效率评估不稳定. 应在 DEA 前做相关分析, 删除或合并高度相关的同类指标.
3. **异常 DMU (Outlier) 拉偏前沿**: 一个效率远超其他 DMU 的"超级单元"会单独定义前沿面, 使其所有其他 DMU 的效率被系统性低估. 必须做异常值检测 (super-efficiency 过度高 >2.0 的 DMU 应标记审查).
4. **导向 (Orientation) 选择错误**: 投入导向假设"给定产出下最小化投入", 适合投入可控场景; 产出导向假设"给定投入下最大化产出", 适合产出可控场景. 选错方向会导致效率值含义完全不同.
5. **规模报酬假设的跳跃影响**: 同一组数据在 CCR (CRS) 下 vs BCC (VRS) 下效率值可能差异巨大. CRS 效率是"全局效率", VRS 效率是"纯技术效率". 如果样本 DMU 规模差异显著 (如大银行与小信用合作社), 必须使用 VRS 模型.
6. **松弛变量 (Slack) 被忽略**: θ=1 不代表"完全有效". 只有同时满足 θ=1 且所有松弛变量为零, DMU 才是 Pareto-Koopmans 有效的. 仅报告 θ 而不检查 slack 是竞赛论文中的常见遗漏.

## 失效条件/反例 (强制小节)

- **条件1 — DMU 数量不足以支撑指标维度 (n < max{m×s, 3(m+s)})**: DEA 的核心机制是"每个 DMU 在 Σλ=1 或 λ≥0 的可行集中寻找最有利于自己的权重". 当 DMU 数太少而指标数较多时, 自由度太大 — 每个 DMU 都能找到一组权重使自己 θ=1. 典型案例: 5 个 DMU, 4 个投入, 3 个产出 → n=5 << max{12, 21}=21, 结果 5 个 DMU 全部 θ=1. DEA 在此条件下完全丧失区分能力. 解决: 合并指标 (PCA), 或改用比率分析法.
- **条件2 — 异常 DMU (Super-Efficiency > 3.0) 单独定义前沿面**: 若存在 1 个 DMU 在某一投入产出组合上极端高效 (如一家科技企业以 1/10 的投入创造 10 倍产出), 前沿面将仅由该 DMU 和坐标轴构成, 所有其他 DMU 被投影到由这一个"怪胎"定义的超平面上, 效率被严重低估. 检测方法: 计算 Super-Efficiency, 若某 DMU 的 super-efficiency > 2.0, 应标记为 outlier, 做敏感性分析 (剔除后重新计算). 若剔除后大多数 DMU 效率显著上升, 则必须说明该 outlier 的影响.
- **条件3 — 投入产出指标中高度相关的同维度指标双计数**: 投入侧同时包含"固定资产总额"和"设备台数"(相关度 r>0.9), 产出侧同时包含"主营收入"和"利润总额" (r>0.85). DEA 处理为独立维度, 对两个高度可替代的指标赋予独立约束, 导致效率评估结果不稳定: 某些 DMU 在"固定资产约束"上无效但在"设备台数约束"上有松弛, 效率值对这两指标的相对测量误差极其敏感 (conditioning 问题). 必须在 DEA 前做相关分析, 删除 VIF>10 的冗余指标.

## 文献

1. Charnes, A., Cooper, W. W., & Rhodes, E. (1978). Measuring the efficiency of decision making units. *European Journal of Operational Research*, 2(6), 429-444. (CCR 原始论文, DEA 开篇)
2. Banker, R. D., Charnes, A., & Cooper, W. W. (1984). Some models for estimating technical and scale inefficiencies in data envelopment analysis. *Management Science*, 30(9), 1078-1092. (BCC 模型)
3. Andersen, P., & Petersen, N. C. (1993). A procedure for ranking efficient units in data envelopment analysis. *Management Science*, 39(10), 1261-1264. (Super-Efficiency)
4. Fare, R., Grosskopf, S., Norris, M., & Zhang, Z. (1994). Productivity growth, technical progress, and efficiency change in industrialized countries. *American Economic Review*, 84(1), 66-83. (Malmquist 指数)
5. Cook, W. D., & Seiford, L. M. (2009). Data envelopment analysis (DEA) — Thirty years on. *European Journal of Operational Research*, 192(1), 1-17. (30年综述)
6. 魏权龄. (2004). 数据包络分析. 科学出版社. (中文 DEA 权威教材)

## 来源溯源

DEA 由 Charnes, Cooper 和 Rhodes (1978) 在德州大学奥斯汀分校创立, 最初用于评估美国公立学校"Program Follow Through"的投入产出效率. 核心创新在于用线性规划替代参数回归, 从数据中直接构建分段线性生产前沿, 无需预设生产函数形式. CCR 模型假设规模报酬不变 (CRS), Banker 等人 (1984) 将之扩展为规模报酬可变的 BCC 模型, 从而可分解技术效率为纯技术效率和规模效率. DEA 自此成为运筹学中最重要的非参数效率评价方法, 在银行业、医疗保健、教育、能源、环境等领域产生数万篇应用论文. 2022年, Charnes 和 Cooper 的 DEA 入选运筹学经典论文殿堂.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 效率评价替代方法 (参数法) | SFA 随机前沿分析 (非本 Skill, 需自建) |
| 效率分解下游分析 | Malmquist 指数 (DEA 面板扩展, 非本 Skill) |
| 指标筛选前处理 | PCA 降维 / 相关分析 VIF 检验 |
| 效率值用作评价得分 → TOPSIS | DEA 效率值 → TOPSIS 贴近度 (串联) |
| 权重对比 — DEA 最优权重 vs AHP | DEA multiplier form 给出的权重与 AHP 比较 |
| 异常值检测 | Super-Efficiency DEA |
