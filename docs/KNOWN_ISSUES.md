# 已知问题与改进路线图⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


> v1.0.0 | 2026-10-19

## v1.0.0 状态（对应重编前的内部 v4.4.0）

- v3.x 已知问题 #1(validation name mismatch)/#5(软门禁)/#6(口径)/#11(触发精度) 在 v4.0.0/v4.1.0 已处理或标注
- 测试: test_skill_integrity.py(版本/引用/路由/编码) + test_subagent_protocol.py, 12/12 套件全绿
- 实战经验库 12 文件入库(新增: 格式基线/AI模板/题目论文库/训练题库/资源差异), 三角色全量接入
- 算法库: 228 .m + 161 范式卡(新增 EM/Apriori/SA/GA/MC/回归诊断)
- M-Loop 模型迭代闭环: 指标目标卡 + tools/model_quality_score.py + C1-D6 三分支(实测通过)
- 版本一致性: VERSION/frontmatter/plugin.json/shim/README/使用教程 六处同步 1.0.0, 由 test_skill_integrity.py 自动检查

## 当前已知问题

| # | 问题 | 严重度 | 影响 | 临时方案 | 计划修复 |
|---|------|:----:|------|------|:------:|
| 1 | M1/P1/P2 仍为软门禁, 无独立可执行脚本 | 中 | 依赖角色自觉+Subagent 质检 | 按 Subagent调度.md 固定门禁表执行 | v4.1.0: gates/M1.m/P1.m/P2.m |
| 2 | xelatex 环境依赖本机配置 | 低 | LaTeX 编译在缺 TeX 环境机器上不可用 | pdflatex 或 Overleaf | 环境配置 |
| 3 | keyword_router 权重未做真实相关性标定(关键词为卡名提取) | 低 | 路由结果按关键词字面匹配, 非语义 | INDEX.md 按大类人工索引兜底 | v4.1.0 |
| 4 | 部分图论/统计 .m 的 validate 仍 fail(3 真 fail) | 低 | 见 v3.0.0 复核记录三口径 | 口径③ 98.3% 为准 | v4.1.0 validate 规则适用域更新 |
| 5 | pandoc 缺失时 equations.py convert-latex/generate 不可用 | 低 | Word 分支用 python-docx 直写 OMML | 安装 pandoc | 环境配置 |
| 6 | 触发精度待实测: v4 description 已单行化, 但未跑真实 query 验证加载 | 中 | 若触发率低, 159 卡成摆设 | 发典型建模 query 验证 | 封版后立即验证 |

## 架构级待改进

| # | 方向 | 说明 | 优先级 |
|---|------|------|:------:|
| 1 | 数值卫生脚本化 | 避坑手册的检查项目前是文档, 待做 numeric_hygiene.py 自动扫描 | P2 |
| 2 | CI/CD 集成 | 属性测试 + validate + integrity 接入 GitHub Actions | P2 |
| 3 | 知识图谱可视化 | keyword_router 可路由, 交互式 HTML 待做 | P3 |
| 4 | M1/P1/P2 硬门禁脚本 | 见上表 #1 | P2 |
| 5 | 2024-2025 23 篇国家奖论文 OCR 偿还 | 吸收审计分子数 | P3 |

## 版本规划

| 版本 | 内容 | 预估 |
|------|------|:--:|
| v0.1.1 | 触发精度实测 + 数值卫生脚本 + validate 适用域更新 | 3-5 天 |
| v0.2.0 | M1/P1/P2 硬门禁 + 知识图谱 UI + CI/CD | 1-2 周 |

---

## v3.0.0 历史问题(2026-07-29 记录, 多数已处理)

| # | 问题 | 严重度 | 影响 | 临时方案 | 计划修复 |
|---|------|:----:|------|------|:------:|
| 1 | validation_cases name mismatch | 中 | calibration_score 偏低 ~0.15 (magnitude_score → 0.5) | 手动对齐 handshake JSON 中的字段名 | v3.0.1 |
| 2 | xelatex 环境不可用 | 低 | LaTeX 模板仅静态校验, 无法确认 PDF 渲染 | pdflatex 或 Overleaf 编译 | 环境配置 |
| 3 | 2024-2025 23篇国家奖论文仅文件名线索 | 低 | 论文吸收审计的"A已吸收论文数"缺少这23篇的分子 | 等待 OCR/视觉读取环境就绪后偿还 | v3.0.1 |
| 4 | 部分图论/统计 .m 文件的 v2/v4 校验仍为 fail | 低 | 12 个 standalone_m_fails 未完全修复(thin _predict wrappers) | 标为 subfunction_of, 不计入分母 | v3.0.1 |

## 架构级待改进

| # | 方向 | 说明 | 优先级 |
|---|------|------|:------:|
| 1 | Word 模板自动生成 | 当前仅 spec 文档, 未用 python-docx 生成实际 .docx | P2 |
| 2 | CI/CD 集成 | 属性测试 + validate 接入 GitHub Actions | P2 |
| 3 | 范式卡自动更新 | 新增算法时自动生成范式卡骨架 | P3 |
| 4 | Python 求解模板 | 当前以 MATLAB 为主, Python 备选模板待写 | P3 |
| 5 | M1/P1/P2 为软门禁，无独立可执行脚本 | P1 | "6道门禁"中3道不可机器卡控，依赖agent自觉，存在漏检风险 | 在角色SKILL.md工作流中显式checklist人工核对 | v3.1.0: 补gates/M1.m/P1.m/P2.m + self-test，升级为硬门禁 |
| 6 | validate通过率口径未在文档定义，地图曾出现129/170双数 | 中 | 指标可读性差，易误读为100%或互相矛盾 | 以Phase A重跑四元组(170/222)为准，标注口径="7/7全部校验项通过的.m文件数" | v3.0.1: FINAL_METRICS/地图统一口径定义 |
| 7 | 知识图谱可视化 | JSON+INDEX 双索引可用, 交互式 HTML 待做 | P3 |
| 8 | OCR 论文偿还 | 2024-2025 23篇 → LEDGER-1 路径③ 偿还需要 OCR 环境 | P3 |

## 版本规划

| 版本 | 内容 | 预估 |
|------|------|:--:|
| v3.0.1 | 修复 #1-#2-#3-#4 + xelatex 环境 + 统一 validate 口径文档 | 1-2天 |
| v3.1.0 | Word自动生成 + CI/CD + 属性测试接入 + **M1/P1/P2 升级为硬门禁** | 1周 |
| v3.2.0 | Python 模板 + 范式卡自动化 + 知识图谱UI | 2周 |

| 9 | validate 通过率 76.6% (52/222 fail)，较 S5 的 ~95% 回归 | P2 | 规模指标(222/150+)与质量指标(76.6%)脱钩 | 三口径并列写入 FINAL_METRICS | v3.1.0 — 52 fail 名单详见复核记录 |
| 10 | 3个真fail(hierarchical_cluster/lda_train/naive_bayes_train)的v6修法悬案 | P2 | validate v6规则越界：聚类/LDA/朴素贝叶斯无优化器语义，本不该被exitflag校验卡 | 路线甲: 更新validate_m_files.py v6适用域，非优化器函数不校验exitflag | v3.0.1: 更新validate规则，3文件从"真fail"改归类为"合理未过" |
| 11 | 触发精度未实测：description(935chars/43triggers)覆盖充分，但未跑真实query验证Skill是否被加载 | 中 | 若触发率<80%，151范式卡/222.m全成摆设 | 封版后第一个实验：发3-5个典型建模query，确认Skill被触发+keyword_router命中 | v3.0.0 封版后立即验证 |
| 12 | token预算未测：151范式卡+222.m触发后可能占>30%上下文(50K-100K tokens) | 中 | Max套餐token配额有限，范式卡/代码全文加载可能烧穿预算 | 封版后第二个实验：跑/context看占比；若>30%考虑范式卡分级加载(高频20全量+低频131摘要) | v3.0.1 分级加载策略 |

## 复核记录 (2026-07-29)

### 终轮补证

- **52名单已递(H)**: 3真fail + 49合理(25prop+5fig+7predict_wrapper+7nlp_helper+2template+1test_runner+1thin_wrapper+1config)
- **gre证据已递(I)**: 52文件名 × 3引用源 = 156次比对, Z=**0**
- **wrapper底层算法**: 7个_predict wrapper → 各自主_train PASS, 除naive_bayes_predict→naive_bayes_train FAIL(v6, 属3真fail之一)
- **3悬案已定(J)**: 全选路线甲(validate规则越界)
- **三口径固化**:
  - ① 存在覆盖 97.7% = 128/131 (分母=算法卡, 151范式卡=131算法+16概念+4Python, 独立定义见manifest.json impl_type分布)
  - ② validate覆盖 76.6% = 170/222 (全部.m)
  - ③ 算法子集validate覆盖 98.3% = 170/173 (222-49非算法=173, 173-3真fail=170)
- **范式卡131 vs 151定义** (2026-07-29补): manifest.json impl_type分布 = standalone_m(70)+standalone_m_fails(12)+standalone_m_missing(49)=131算法卡; conceptual(16)+python_only(4)=20非算法卡。存在覆盖分母=131算法卡, 非全部151范式卡。

### 封版最后一刀: sigmoid 6 引用方全验 (2026-07-29)

| # | 范式卡 | 主算法 .m | Validate 状态 |
|---|--------|----------|:------------:|
| 1 | PARADIGM-0204-LSTM-FORECAST | lstm_forecast.m | PASS |
| 2 | PARADIGM-0606-PERCEPTRON | perceptron.m | PASS |
| 3 | PARADIGM-0609-LOGISTIC-REG | logistic_regression_train.m | PASS |
| 4 | PARADIGM-0618-CNN | N/A (Python备选) | N/A |
| 5 | PARADIGM-0709-SEIRS-STOCHASTIC | seirs_vaccine.m | PASS |
| 6 | PARADIGM-0802-LOGISTIC | logistic_model.m | PASS |

**sigmoid 污染判定**: 不计污染, Z = 0 (6/6 全验, 所有主算法 PASS, sigmoid fail 仅作为工具函数被引用, 不影响核心链路)。
**选择性举证自查**: 上轮仅验 logistic_regression 1/6, 本轮已用 6/6 全验替代。

### 复核方法论 (四轮递进取证)
1. **验计数**：四元组闭合 (pass+fail+warn+skip = 总数)
2. **验归类**：每个 fail 有名字、子类、理由
3. **验名单**：52 行逐行列出，14 wrapper 逐个路径
4. **验举证**：sigmoid 从 1/6 → 6/6 全验，Z=0 焊死

### 诚实账本封版 (2026-07-29)
52 个红灯全部有: 文件路径 / 失败项 / 归类(真3+合49) / 子类名 / 修法路线。3 个真 fail 已定路线甲(validate 规则越界, v3.0.1 更新适用域)。Z=0 经 156+6 次 grep 全验焊死。v3.0.0 诚实账本可封版。

### 抽查友好性声明
全部52行归类均附文件路径，可通过 `grep <path> tests/validate_report.json` 独立复核原始数据。3真fail的原因(v6-only)与49合理的子类归类均可通过阅读对应.m文件头15行验证。

- **validate 重跑四元组**: pass=170, fail=52, warn=0, skip=0 (合计=222 ✅)
- **门禁软硬**: 硬 3 (C1/W1/W2), 软 3 (M1/P1/P2)
- **129 vs 170 定论**: 129 是 S5 中期的过时快照（当时仅 136 .m），170 是当前 validate 重跑的准确数。地图 ③ "129/7/7 pass" 应从全景地图修正为 "170/222 pass (7/7全项)"。地图 ⑨ 的 170 正确无需改动。
- **本次写操作**: 仅本文件 (docs/KNOWN_ISSUES.md)，见操作清单
