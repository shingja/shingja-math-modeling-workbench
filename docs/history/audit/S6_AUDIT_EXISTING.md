# S6_AUDIT_EXISTING.md — Tide工程化资产基线审计⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

> 2026-07-29 | v3.0.0-s6

## 存量扫描

| 目录 | 文件数 | 评级 | 说明 |
|------|:-----:|:----:|------|
| `matlab/templates/` | 0 | — | 不存在，需从零建 |
| `matlab/figures/` | 0 | — | 不存在，需从零建 |
| `matlab/utils/` | 0 | — | 不存在，需从零建 |
| `matlab/tests/property/` | 0 | — | 不存在，需从零建 |
| `scripts/` | 0 | — | 不存在，部分功能在 tools/ 下已有 |
| 现有 `tools/docx/scripts/` | 10+ | A | 已有 paper_format/equations/OOXML 校验 |
| 现有 `tools/paper_search/` | 3 | A | 已有 hybrid_scholar/openalex/anysearch |
| 现有 `tools/evaluate/` | 2 | A | 已有 scoring_rules.json |

## 现有 150 个算法 .m 的质量分布

| 质量 | 数量 | 特征 |
|:----:|:----:|------|
| A (7/7 pass) | **129** | S5 已验：arguments+rng+exitflag+self-test+fullfile |
| B (缺 v6) | ~18 | 缺 exitflag 或自测格式，S5 末已批量修复 |
| C (薄 wrapper) | ~3 | _predict 类的 thin wrapper，已标 subfunction_of |

> **结论**: 算法 .m 全部已达到工程化标准 (A/B)，S6 无需改造。聚焦在模板/可视化/工具/属性测试四个新增目录。

## 兄弟 Skill 借鉴清单

| 源 Skill | 借鉴点 | 落地 |
|---------|-------|------|
| `property-based-testing` | 不变量定义模式、shrinking 策略、随机种子控制 | §4 属性测试框架 |
| `nature-figure` | 色板 PALETTE、字体/DPI 规范、figure_audit 检查项 | §2 可视化样式系统 |
| `docx` | OMML 表格生成、paper_format 调用接口 | §6 结果输出 JSON→DOCX 桥接 |
| `modern-python` | dataclass/类型注解模式 | Python 备选代码风格参考 |

## 联网补盲（S6_WEB_RESEARCH）

| 搜索主题 | 发现 | 采纳 | 落地 |
|---------|------|:---:|------|
| MATLAB publication quality figures 2024 | `exportgraphics` 为推荐导出方式；`tiledlayout` 替代 `subplot`；`sgtitle` 统一标题 | ✅ | export_publication_figure 用 exportgraphics |
| MATLAB project template engineering | 统一 `+` 包目录结构；`Project` 对象管理路径；` startup.m` 初始化 | ✅ | skeleton 内置初始化 |
| Solver fallback chain pattern | fmincon→ga→particleswarm→simulannealbnd 为标准链 | ✅ | solver_fallback_chain.m |
| Invariant testing in MATLAB | `matlab.unittest.TestCase` + `assume` + `verify`；随机种子固定保证可复现 | ✅ | 属性测试用 assertions 包 |
| Code organization for competitions | 按子问题分目录 (q1/q2/q3)；results/figures/ 与代码分离 | ✅ | skeleton 内置目录创建 |
