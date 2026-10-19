# S9_BORROW_NOTES.md — skill-creator description 模式分析⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

> 借鉴源: `skill-creator/SKILL.md`

## 模式提取

| 特征 | skill-creator 做法 | 适配 math-modeling |
|------|-------------------|-------------------|
| 长度 | 1 长句 (~50 words) | 1-2 句, ~80 words (算法/场景多) |
| 句式 | "Use when users want to..." | ✅ 采用 |
| 能力列举 | 内部埋具体动词: create/modify/measure/optimize/eval/benchmark | ✅ 建模/求解/出图/写论文/评估/校准/审计 |
| 负面边界 | 无 (skill-creator 无明确边界) | **新增**: "Do NOT use for: 纯前端/纯数据库/非数学论文/纯翻译" |
| paths | `**/SKILL.md` `**/.claude/skills/**` | 保留现有 paths 模式 |
| name | `skill-creator` (kebab-case) | `math-modeling` 不变 |
