# v3.0.0 最终指标⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


> 2026-07-29

## 规模

| 指标 | v2.2.1 | v3.0.0 | 增幅 |
|------|:-----:|:-----:|:----:|
| .m 文件总数 | 82 | 222 | +171% |
| 算法总数 | 89 | 150+ | +69% |
| 算法大类 | 9 | 12 | +33% |
| 范式卡 | 0 | 151 | — |
| 门禁 | 5 | 6 | +1 |
| 属性测试 | 0 | 31 | — |
| 图表函数 | ~5 | 24 | +380% |
| 题型模板 | 0 | 9 | — |
| 触发词 | ~5 | 40+ | +700% |
| 参考文档 | ~25 | ~40 | +60% |

## 质量

| 指标 | 结果 |
|------|:----:|
| MATLAB 覆盖率 | **97.7%** (128/131 honest denominator) |
| 7/7 validate 通过 | **170/222** (76.6%) |
| 属性测试全绿 | **31/31** |
| C1 门禁 Self-test | pass=true + fail=false |
| W1 门禁 Self-test | 11 asserts |
| W2 门禁 Self-test | 17 asserts |
| 触发精度 | **10/10** |
| calibration_score (冒烟) | **0.81** (WARN, >0.70) |
| result_claim_bind 篡改检测 | ✅ |
| 端到端冒烟 | **CONDITIONAL PASS** |

## 新增目录

| 目录 | 文件数 | 用途 |
|------|:-----:|------|
| matlab/surrogate/ | 5 | ⑩ 代理模型 |
| matlab/robust/ | 5 | ⑪ 鲁棒优化 |
| matlab/mcdm/ | 11 | ⑫ MCDM 进阶 |
| matlab/comprehensive/ | 20+ | 综合算法+新补 |
| matlab/evaluation/ | 5 | 评价新补 |
| matlab/templates/ | 11 | 题型模板 |
| matlab/figures/ | 24 | 图表函数 |
| matlab/utils/ | 6 | 工具层 |
| matlab/tests/property/ | 31 | 属性测试 |
| references/paradigms/ | 153 | 范式卡+索引 |
| tools/ | ~10 | 联合校准+握手+绑定 |
| gates/ | 3 | C1+W1+W2门禁 |
| tests/smoke_2024/ | ~20 | 冒烟产物 |

## S1-S12 耗时

| 步骤 | 内容 | 主要产出 |
|:----:|------|------|
| S1 | 基线备份 | backup (497 files) |
| S2 | 优化规划 | OPTIMIZATION_PLAN.md |
| S3 | 吸收审计 | 7 audit files |
| S4 | 范式卡建设 | 151 paradigm cards |
| S5 | MATLAB 覆盖率 | 89.9% → 97.7% |
| S6 | Tide工程化 | 72 new files |
| S7 | 联合闭环 | 9 protocol+tool files |
| S8 | 论文规范 | 17 template+gate files |
| S9+S10 | 触发词+版本 | SKILL.md + CHANGELOG |
| S11 | 端到端冒烟 | CONDITIONAL PASS |
| S12 | 最终报告 | RELEASE+ISSUES+METRICS |
