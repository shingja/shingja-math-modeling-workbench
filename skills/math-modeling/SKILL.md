---
name: math-modeling
version: 0.1.0
description: 当用户要求数学建模、建模竞赛、建模分析、代码求解、结果可视化或生成数学建模论文时使用。覆盖优化/预测/评价/图论/统计/机器学习(含CV目标检测)/机理建模/综合/代理模型/鲁棒优化/MCDM共12大类164张范式卡(含CV目标检测)，MATLAB-Python双语言。支持完整四段流程(Linger 徘徊-建模 / Tide 潮起-求解 / Gloom 沉郁-写作 / Yearn 心生惦念-终审交付)、6道门禁(M1/P1/C1/P2/W1/W2)、联合校准闭环、机理优化+CV检测双实战经验库(数值卫生/诚实披露/多轮审计/外部对标/提交包规范/CV检测管线)。触发词：数学建模、math modeling、建模竞赛、优化问题、预测模型、评价模型、图论分析、CUMCM、MCM、ICM、Linger、Tide、Gloom、Yearn、模型建立与求解、计算机视觉、目标检测、YOLO、图像识别、缺陷检测。
when_to_use: 数学建模, math modeling, 建模竞赛, 建模分析, 代码求解, 结果可视化, 数学建模论文, 优化问题, 预测模型, 评价模型, 图论分析, 统计分析, 机器学习建模, 机理建模, CUMCM, MCM, ICM, Linger, Tide, Gloom, Yearn, 模型建立与求解, 代理模型, 鲁棒优化, 联合校准, 灵敏度分析, 多目标优化
---
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


# 数学建模 Skill v0.1.0⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

本 Skill 的完整指令和参考文档位于主 SKILL.md。

## 加载协议

0. **版本回显(必做)**: 开始执行前先向用户回显一行:
   `[math-modeling v0.1.0] SKILL_ROOT=<仓库根目录> | VERSION 文件=<VERSION 文件内容>`
   若 VERSION 文件与本文件 frontmatter 的 `version` 不一致, 立即告知用户"版本不一致"并停止, 不要静默用旧版本执行。
1. 首先读取完整指令文件: `<仓库根目录>/SKILL.md`
2. 设定环境变量:
   - `SKILL_ROOT` = 本文件所在目录(`skills/math-modeling/`)的上两级目录, 即仓库根目录
   - `PROJECT_ROOT` = 用户指定的题目和工作目录
3. 严格按照主 SKILL.md 中的路由表、强制执行协议、阶段流程和完成判定执行
4. 所有相对路径引用（`references/`, `tools/`, `assets/`, `matlab/` 等）均相对于 `SKILL_ROOT`

## 强制门禁

本 Skill 的执行受主 SKILL.md 中定义的以下协议约束:
- 6 道门禁 (M1/P1/C1/P2/W1/W2)
- Subagent 质检调度规则 (`protocols/Subagent调度.md`)
- 联合校准闭环 (`protocols/joint_calibration_protocol.md`)
- 实战经验库 (`references/lessons/`, 双实战完整复盘)
- AI 工具合规要求 (CUMCM 2026+, 含 AI 工具使用详情模板)
- 提交包规范 (`references/lessons/提交包规范.md`)
- 完成判定标准

加载并遵循主 SKILL.md 的全部指令。不得跳过验证、静默换工具或编造结果。
