# AGENTS.md — 数学建模 Skill 的通用 Agent 入口⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


本仓库是一个数学建模工作流 Skill（同时是 Claude Code skill 与通用 agent 指令集）。
This repository is a math-modeling agent skill. `AGENTS.md` is the generic entry point;
the master instruction file is [`SKILL.md`](SKILL.md) — always read it before acting.

## 加载顺序 / Load order

1. `SKILL.md` — 主指令：路由表、阶段流程、门禁、完成判定。
2. `references/roles/<角色>/SKILL.md` — 只加载当前阶段需要的角色（Linger / Tide / Gloom）。
3. 按需加载协议与资料：`protocols/joint_calibration_protocol.md`、`protocols/model_improvement_loop_protocol.md`（M-Loop）、`protocols/Subagent调度.md`、`references/lessons/`、`references/paradigms/INDEX.md`。
4. 自研模块（出图 / 润色 / 统计审查 / 预审 / 检索）：按需读取 `modules/README.md` 指向的单个模块文件；模块不改变流程，只定义检查标准。
5. 显示 README 的图表示例来自 `tools/demo_figures.py`（可复现）。

## 触发条件 / When to activate

用户提到：数学建模、建模竞赛、CUMCM、MCM/ICM、优化问题、预测模型、评价模型、图论、统计分析、机理建模、目标检测，或明确要求"Linger/Tide/Gloom"、"模型建立与求解"、"生成建模论文"。

## 运行约定 / Operating rules

- **路径隔离**：`SKILL_ROOT`（本仓库）只读；所有产物写入 `PROJECT_ROOT`（用户题目目录）。图形产物禁止写回 `SKILL_ROOT`（`plot_style.export_figure` 会直接报错）。
- **门禁**：`M1 → P1 → C1 → P2 → W1 → W2`。`C1/W1/W2` 为硬门禁，对应 `gates/` 下的可执行校验；未通过不得进入下一阶段。
- **数值纪律**：任何数字必须来自真实运行；禁止编造或"占位"结果；异常、失败、不确定必须在报告中显式披露（见 `references/lessons/诚实披露协议.md`）。
- **出图规范**：统一走 `references/roles/Tide/scripts/plot_style.py`（Okabe-Ito 色板、300 DPI、SVG+PNG、布局与设计双门禁）。
- **论文合规**：结构与格式以当届官方规则与模板为准；使用 AI 工具须按当届规定声明（模板见 `references/lessons/AI工具使用详情模板.md`）；交付前跑身份信息与元数据清理检查（`references/lessons/提交包规范.md`）。
- **语言**：与用户交流使用中文；算法名、库名、文件名保留原文。

## 完整性 / Integrity

提交或分发前可自查：

```bash
python -m unittest discover -s tests -v
python tests/test_skill_integrity.py -v
```

修改版本号时须同步 `docs/仓库与发布.md` 第三节列出的全部位置，否则 `test_skill_integrity.py` 会失败。

## 许可 / License

源码可见但非开源（禁商用、禁二次发布、禁止移除署名与归属标识），完整条款见 [LICENSE](LICENSE)。
`tools/docx`、`tools/pdf`、`tools/xlsx` 为 Anthropic 第三方代码，遵循其自带 `LICENSE.txt`。
