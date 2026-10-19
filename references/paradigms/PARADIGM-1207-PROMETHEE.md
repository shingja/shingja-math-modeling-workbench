# PARADIGM-1207-PROMETHEE PROMETHEE: 偏好排序组织法⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1207-PROMETHEE |
| 类别/子类 | ⑫多目标决策进阶 / 多属性决策 |
| 难度 | 中 |
| 适用题型关键词[] | 偏好函数, 流入流出流, 偏序, 净流排序, 完全排序, GAIA平面 |
| confidence | high |
| source | 论文1986_PROMETHEE / 题解反推_MCDM类 |

## 数学形式

**核心思想**: 基于方案对的两两比较和偏好函数, 通过正流 (流出) 和负流 (流入) 确定排序。

1. **偏好函数 $P_j(a,b)$**: 量化方案 $a$ 在准则 $j$ 上优于 $b$ 的程度
   $$P_j(a,b) = F_j[d_j(a,b)], \quad d_j(a,b) = f_j(a) - f_j(b)$$
   常用类型: Usual, U-shape, V-shape, Level, Linear, Gaussian

2. **综合偏好指数**:
   $$\pi(a,b) = \sum_{j=1}^{n} w_j P_j(a,b)$$

3. **流入/流出/净流** (PROMETHEE II 完全排序):
   $$\phi^+(a) = \sum_{b \neq a} \pi(a,b) \quad \text{(正流—a优于其他)}$$
   $$\phi^-(a) = \sum_{b \neq a} \pi(b,a) \quad \text{(负流—a被其他优于)}$$
   $$\phi(a) = \phi^+(a) - \phi^-(a) \quad \text{(净流—按降序排列)}$$

4. **PROMETHEE I** (偏序): 基于 $\phi^+$ 和 $\phi^-$ 的偏好/无差异/不可比关系

| 变量 | 含义 |
|------|------|
| $d_j(a,b)$ | 方案 $a$ 比 $b$ 在准则 $j$ 上的差值 |
| $P_j(a,b)$ | 偏好程度 (0-1) |
| $\phi^+(a)$ | 正流 (优势度) |
| $\phi^-(a)$ | 负流 (劣势度) |
| $\phi(a)$ | 净流 (综合) |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 偏好函数类型 | enum | Linear | Usual/U-shape/V-shape/Level/Linear/Gaussian | 高—决定差值映射方式 |
| 偏好阈值 $q$ (无差异) | float | 0 | $\geq 0$ | 中 |
| 偏好阈值 $p$ (严格偏好) | float | 根据数据 | $> q$ | 高 |
| Gaussian $\sigma$ | float | 根据数据 | $> 0$ | 中 |
| 准则权重 $w_j$ | float[] | 等权 | — | 高 |

**时间复杂度**: $O(m^2 n)$ ($m$ 方案, $n$ 准则)
**空间复杂度**: $O(m^2)$ (偏好矩阵)

## MATLAB 实现

```matlab
% 自写 PROMETHEE II (含6种偏好函数 + GAIA可视化)
% 自写-见S5:promethee_rank.m

% 实现步骤:
% 1. 决策矩阵输入 + 准则类型声明
% 2. 逐准则计算偏好函数值 (选择类型)
% 3. 加权聚合为综合偏好矩阵
% 4. 计算正流/负流/净流
% 5. PROMETHEE I (偏序) + PROMETHEE II (完全排序)
% 6. GAIA 可视化 (净流 PCA投影)
```

**锚点工具箱**: 无内置; 可借助 `pca` (Statistics Toolbox) 实现 GAIA 平面

## Python 备选

```python
# scikit-criteria 库 (推荐)
import skcriteria as skc
from skcriteria.madm import closeness

dm = skc.mkdm(matrix=matrix, objectives=[min/max]*n, 
              alternatives=alts, criteria=criterias)
result = closeness.PROMETHEE(seed=42).evaluate(dm)
```

备选: `pyDecision` (含 PROMETHEE + GAIA 可视化)

## 选型决策树

- **需要同时输出偏序和完全排序** → PROMETHEE (I + II)
- **偏好非线性 (存在阈值效应)** → PROMETHEE (偏好函数灵活) > TOPSIS/VIKOR
- **需要可视化方案间支配关系** → PROMETHEE (GAIA平面) 天然优势
- **准则少 + 偏好线性** → TOPSIS (更简洁) 也可; PROMETHEE 过度工程
- **需要妥协解 (保守决策)** → VIKOR (PARADIGM-1204) > PROMETHEE
- **大规模方案 ($m > 100$)** → 偏好矩阵 $O(m^2)$ 可能过重, 先用筛选

## 典型图型

- **raw**: 各准则差值 $d_j(a,b)$ 矩阵热力图
- **process**: GAIA 平面图 (方案 + 准则轴投影), 正/负流散点图
- **result**: 净流 $\phi$ 排名柱状图 (正负区分色), PROMETHEE Rainbow 图

## 常见坑

1. **偏好函数阈值选择主观**: $p$ 和 $q$ 的选择显著影响排序 → 敏感性分析 (阈值 $\pm 20\%$)
2. **GAIA 平面仅捕获 $\sim$ 70% 方差**: PCA 降维信息损失 → 标注前两主成分解释方差
3. **准则方向误设**: 成本型未反转导致偏好方向颠倒 → 显式验证 `minimize`/`maximize` 每个准则
4. **$m > 50$ 时偏好矩阵过大**: VISUAL 解释困难 → 优先输出完整排序表 + top 方案 GAIA

## 失效条件/反例 (强制小节)

- **条件1**: 方案数 $m \leq 2$ → 偏好矩阵近乎平凡, PROMETHEE 无优势; 直接比较准则值即可。**替代**: 简单加权和/TOPSIS
- **条件2**: 准则数 $n = 1$ → 偏好函数退化为单准则排序, 且偏好阈值需凭经验设定, 直接排序更可靠。**替代**: 直接按准则值排序
- **条件3**: 决策者无法理解偏好函数概念 → PROMETHEE 的透明性假设决策者能理解非线性偏好阈值; 若需"透明可追溯"排序, TOPSIS/VIKOR 的数学更直接。**替代**: TOPSIS/VIKOR
- **条件4**: 所有准则值与方案间差值 $d_j(a,b)$ 极小 (噪声级) → 偏好函数对阈值过于敏感, 微小变化引起排序反转。需大幅增加 $p$ 或换等级偏好函数

## 文献

1. Brans, J. P., Vincke, P., & Mareschal, B. (1986). How to select and how to rank projects: The PROMETHEE method. *European Journal of Operational Research*, 24(2), 228-238. DOI: [10.1016/0377-2217(86)90044-5](https://doi.org/10.1016/0377-2217(86)90044-5)
2. Brans, J. P., & Mareschal, B. (2005). PROMETHEE methods. In *Multiple Criteria Decision Analysis: State of the Art Surveys* (pp. 163-186). Springer. ISBN: 978-0-387-23067-2.

## 来源溯源

- 论文三元组: Brans 1986, PROMETHEE, preference function + outranking flows
- 教学用例: 项目优先级排序, 供应商评估

## 关联范式卡

组合: PARADIGM-1205-CRITIC (客观权重), PARADIGM-1206-BWM (主观权重)
替代: PARADIGM-1204-VIKOR (妥协解), PARADIGM-0401-TOPSIS (理想解距离)
前置: 任意赋权法
