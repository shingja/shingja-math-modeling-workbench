# protocols/ — 协议层⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


> 版本 0.1.0 · 作者 [shingja](https://github.com/shingja) · 许可见 [LICENSE](../LICENSE)

跨阶段生效的流程协议。角色文档引用这里的协议；协议本身不产生产物，只定义"什么时候必须做什么、怎么做才算合规"。

| 协议 | 作用 | 触发时机 |
|---|---|---|
| `joint_calibration_protocol.md` | 建模×编程联合校准（calibration_score、C1 门禁） | P1 通过后、P2 之前 |
| `model_improvement_loop_protocol.md` | M-Loop：指标目标卡 → 质量评分 → 迭代 / 全网搜方法 | 指标不达标 |
| `external_search_protocol.md` | 全网方法搜索（四层搜索 + 只检不禁 + 声明义务） | 库内 ≥2 轮无改善 |
| `model-to-code-handoff.md` | Linger → Tide的结构化交接 | 阶段交接 |
| `Subagent调度.md` | 门禁节点的只读质检 Subagent 调度 | M1/P1/C1/P2/W1/W2 |
| `frozen_numbers_protocol.md` | 数值冻结与防篡改（哈希绑定） | Tide产出后 |
| `decision_log_protocol.md` | 关键决策留档与回溯 | 每个关键决策点 |
| `interactive_mode_protocol.md` | 交互式选择（关键决策点暂停确认） | 默认交互模式 |

两条总则对所有协议生效：**产物只写 `PROJECT_ROOT`**；**数值必须来自真实运行，禁止编造与占位**。

协议与 [`../modules/`](../modules/README.md) 的分工：协议管**流程顺序与门禁**，模块管**单项能力怎么检查**。
