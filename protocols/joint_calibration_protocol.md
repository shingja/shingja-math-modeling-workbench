# 联合修正闭环协议 (Joint Calibration Protocol)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


> 作者 [shingja](https://github.com/shingja) · 许可见 [LICENSE](../LICENSE) · 禁止移除署名与版权标识

> v4.1.0 | 2026-08-16 | Linger × Tide 双向握手机制(条件数诊断已扩展到全部代理模型)

## §1 总览

Linger与Tide之间建立结构化握手 + 迭代修正闭环，用量化判据 (`calibration_score`) 取代经验性"模型好像还行"的判断。

### 闭环示意

```
Linger ──[模型握手包]──→ Tide
  ↑                        │
  │                        ↓
  └──[数值诊断反馈]──← 求解+后验
  │                        │
  ↓                        ↓
修正模型 ←── score < 0.70 ──→ score ≥ 0.85 → 进入Gloom
  │               │
  │               └─ 0.70 ≤ score < 0.85 → C1 WARN: 有条件进入, 论文必须写局限性
  └── 第3轮仍<0.70 ──→ 降级模型 + 论文写局限性
```

### 角色定义

| 角色 | 代号 | 职责 |
|------|:----:|------|
| Linger | Modeler | 设计模型、定义变量映射、提供验证用例、申明不变量 |
| Tide | Coder | 实现求解、运行验证、回传数值诊断、多模型对比 |
| 独立审计 | Auditor (C1) | 独立 Subagent，检查 calibration_score、修正记录、哈希绑定 |

### 迭代上限

最多 N=3 轮。第 3 轮后 `calibration_score < 0.70` → 降级模型，在论文中如实写局限性。禁止粉饰。

---

## §2 前向握手：模型握手包 (Modeler → Coder)

握手包是Linger交付给Tide的结构化契约。7 个必填字段，缺任一 → `[握手阻塞]` 回Linger。

| # | 字段 | 类型 | 说明 | 示例 |
|---|------|------|------|------|
| 1 | `model_id` | string | 模型唯一标识 | `"Q1-TOPSIS-EWM"` |
| 2 | `math_formulation` | string | 标准数学形式 (LaTeX) | `"min f(x) s.t. g(x) <= 0"` |
| 3 | `variable_map` | struct[] | 变量名→含义→量纲→可行域 | `[{name:"x1", meaning:"产量", unit:"吨", bounds:[0,1000]}]` |
| 4 | `pseudo_code` | string | 求解步骤伪代码 (语言无关) | `"Step1: Normalize; Step2: Compute weights..."` |
| 5 | `parameter_bounds` | struct | 参数可行域 | `{alpha: [0.01, 0.99], max_iter: [50, 1000]}` |
| 6 | `validation_cases` | struct[] | ≥2 个验证用例 (输入→期望输出→容差) | `[{input:{...}, expected:0.8234, tol:1e-3}, ...]` |
| 7 | `invariants` | string[] | 守恒律/单调性/有界性声明 | `["sum(w)=1", "w_i ∈ [0,1]", "S+E+I+R=N"]` |

**握手确认流程**:
1. Linger交付握手包 (JSON/MAT 文件) → 发送 `[握手请求]`
2. Tide用 `handshake_validate.m` 校验 7 字段 → 全通过则 `[握手确认]`，缺字段则 `[握手阻塞] 缺失: <清单>`
3. 阻塞状态下Tide禁止编码

---

## §3 后向反馈：数值诊断 (Coder → Modeler)

Tide求解后，用 S6 的 `numerical_diagnostics.m` 采集诊断，回传Linger。

| 诊断项 | 阈值 | 动作 | 说明 |
|--------|:----:|------|------|
| 条件数 > 1e10 | 警告 | 建议检查变量量纲/标准化 | 病态矩阵导致解不可靠; 全部代理模型统一适用 (见下) |
| 残差 norm > 1e-3 | 阻塞 | 回Linger修正模型结构 | 解不满足方程约束 |
| 解越界 (超出 parameter_bounds) | 阻塞 | 回Linger检查约束 | 模型遗漏了可行域约束 |
| 灵敏度爆炸 (|∂result/∂param| > 5) | 警告 | 建议增加约束或换模型 | 参数微小变化导致结果剧烈波动 |
| 与 validation_cases 偏差 > tol | 阻塞 | 回Linger检查数学公式 | 代码实现与模型定义不一致 |
| 多重共线性 VIF > 10 | 警告 | 建议删除/合并变量 | 回归系数不可靠 |
| 过拟合 (train R^2 > 0.99 且 test R^2 < 0.7) | 警告 | 建议简化模型或增加正则化 | 模型泛化能力差 |

> **条件数诊断统一适用全部代理模型**: GPR/Kriging 核矩阵 $\mathbf{K}$、SVR 核矩阵、RBF 插值矩阵、RSM 高次项设计矩阵 $\mathbf{X}^T\mathbf{X}$ 共用同一阈值 (条件数 > 1e10 警告)。触发时首先检查输入尺度比与标准化，而不是归咎于算法本身。
>
> **负 R² / 发散诊断**: 统计类拟合出现负 R²、预测发散或 Cholesky 失败时，按 `references/lessons/避坑手册_Tide.md` 的负 R² 诊断清单排查实现缺陷（标准化缺失、核矩阵病态、噪声项缺失等），不得直接判定"算法不可用"。

---

## §4 联合收敛判据：calibration_score

### 定义

```
calibration_score = 0.30 * magnitude_score
                  + 0.30 * goodness_score
                  + 0.20 * stability_score
                  + 0.20 * invariant_score
```

### 分项计算

**magnitude_score** (结果量级合理性)
```
magnitude_score = 1 - mean(|actual - expected| / max(|expected|, 1e-10))
```
截断到 [0, 1]。对比对象为握手包的 `validation_cases`。

**goodness_score** (拟合优度/残差)
- 优化类: `goodness_score = 1 - relative_residual` (relative_residual = ||Ax-b|| / ||b||)
- 统计类: `goodness_score = R^2_adjusted` (若可得) 或 `1 - RMSE / range(y)`
- 机理类: `goodness_score = 1 - max(|ODE_error_per_step|)` (用守恒律残差)

**stability_score** (多种子敏感性)
```
CV = std(results_across_seeds) / |mean(results_across_seeds)|
stability_score = max(0, 1 - CV / 0.2)   % CV ≥ 0.2 → score = 0
```
用 5 个不同 seed 重复求解。

**invariant_score** (不变量满足率)
```
invariant_score = (通过的不变量数) / (总不变量数)
```
不变量从握手包 `invariants` 字段读取，Tide逐条验证。

### 阈值判定

| score | 判定 | 动作 |
|:-----:|:----:|------|
| ≥ 0.85 | **PASS** | 进入Gloom |
| [0.70, 0.85) | **WARN** | 允许进入，论文必须写局限性；C1 门禁判定 WARN（不计 PASS） |
| < 0.70 | **BLOCK** | 必须迭代修正（C1 门禁判定 FAIL） |

---

## §5 结果-主张一致性闸

### 机制

1. Tide输出 `results/results.json` (S6 schema)
2. `result_claim_bind.m --bind` 计算 JSON 的 SHA-256 哈希 → `results/.bind_hash`
3. Gloom从 JSON 提取数值写入论文
4. 每次编译前 `result_claim_bind.m --verify`：
   - 若 JSON 哈希变 → 阻断，报错 `[结果-主张不一致] 数值已变更，请重跑确认`
   - 若论文中数值与 JSON 不匹配 → 阻断（正则提取数值对比）

### 安全属性

- JSON 任一数值改动 → 哈希必然不同 (SHA-256 防碰撞)
- `.bind_hash` 与 JSON 一起提交到版本控制
- Gloom必须在摘要页下方标注 `结果绑定: SHA256=<hash>`

---

## §6 多模型交叉验证

### 流程

1. Linger对同一子问题提供 ≥2 个候选模型
2. Tide对每个模型独立求解，产出各自的 `calibration_score`
3. `model_ensemble_select.m` 综合排序，选出最优

### 选优准则

| 准则 | 适用场景 | 指标 |
|------|---------|------|
| AIC/BIC | 统计/回归模型 | 值越小越好 |
| CV RMSE | 预测模型 | K-fold 交叉验证均方根误差 |
| calibration_score | 通用 | 综合质量评分 |
| weighted | 默认 | 0.4×c_score + 0.3×(1-cv_rmse_norm) + 0.3×(1-aic_norm) |

### 输出

`results/model_selection.json`:
```json
{
  "subproblem": "Q1",
  "candidates": [
    {"name": "TOPSIS-EWM", "calibration_score": 0.91, "aic": null, "cv_rmse": null},
    {"name": "AHP-Fuzzy", "calibration_score": 0.78, "aic": null, "cv_rmse": null}
  ],
  "selected": "TOPSIS-EWM",
  "reason": "calibration_score 0.91 > 0.78; weights sum to 1 (invariant passed); sensitivity CV=0.03 (stable)"
}
```

Gloom必须在"模型评价"节引用此报告。

---

## §7 迭代修正记录

每次迭代修正产出 `calibration_log.md`:

```markdown
## 迭代 #1 → #2

**症状**: 残差 = 0.15, 条件数 = 3.2e12
**诊断**: 变量 x3 量纲为"万元"而 x1 为"吨"，量纲不统一导致系数矩阵病态
**修正**: Linger将 x3 Z-score 标准化; 删除变量 x5 (VIF=23)
**重跑结果**: 残差 = 0.0008, 条件数 = 45
**calibration_score**: 0.62 → 0.91 ✅

## 最终判定
- 迭代次数: 1
- 最终 score: 0.91
- 判定: PASS
- 选优模型: TOPSIS-EWM
```

---

## §8 与门禁系统的集成

现有门禁链路更新为:

```
M1 (建模终检) → P1 (最小可运行) → [C1] (联合校准) → P2 (编程终检) → W1 (证据大纲) → W2 (论文终检)
```

C1 的 5 个检查维度 (三档判定与 `C1_joint_calibration_check.m` 一致):
| 维度 | 检查项 | 阻塞条件 |
|:----:|--------|---------|
| D1 | calibration_score 三档: ≥0.85 PASS / [0.70,0.85) WARN / <0.70 FAIL | WARN 与 FAIL 均不计 PASS; < 0.70 阻塞必须迭代 |
| D2 | 修正记录完整性 | 有迭代但无 calibration_log.md 阻塞 |
| D3 | 结果-主张哈希绑定 | .bind_hash 缺失或 verify 失败 |
| D4 | 多模型选优证据 | model_selection.json 缺失或 <2 候选 |
| D5 | 握手包完整性 | handshake_validate 返回 false |

C1 独立于Linger和Tide，由未参与编写的 Subagent 执行。
