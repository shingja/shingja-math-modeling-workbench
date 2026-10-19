## [1.0.0] - 2026-10-19

### 首个公开版本

- 🚀 公开仓库 `shingja/shingja-math-modeling-workbench`，干净历史，单一公开基线。
- 🧭 四段工作流：Linger 徘徊 → Tide 潮起 → Gloom 沉郁 → Yearn 心生惦念，6 道门禁。
- 📚 12 类 164 张范式卡、228 个 MATLAB 实现 + 等价 Python、出版级出图规范。
- 🎓 面向北京科技大学同学，也适合任何想学习数学建模的人。
- 🔐 公开层只保留许可、署名、版权声明与高层维权说明；具体校验与取证方法不入公开仓库。
- 🛡 分支保护、签名提交、Secret scanning、私密漏洞报告、Dependabot 安全更新已开启。
- 🖼 Social preview 已设置。

## [0.1.0] - 2026-10-08⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


### 版本线重编：内部开发期起点

- 🔢 版本号由内部序号 `4.4.0` 重编为 `0.1.0`（语义化版本 0.y.z = 初始开发期：尚未公开发布，接口与目录结构仍可变）。内容与重编前的 v4.4.0 一致。
- 🎯 **首次公开发布时定版 `1.0.0`**，并打 tag `v1.0.0`；发布前的全部改动只累计到 0.x。
- 📦 代码仓库迁移至 `github.com/shingja/shingja-math-modeling-workbench`（私有，2026-10-08 建立，全新提交历史）；旧账号 `XiaoMaColtAI` 名下的公开仓库弃用，不再推送、不接 PR。
- 📄 版本号同步清单与发版流程见 `docs/仓库与发布.md`；`docs/` 与 `.claude-plugin/` 已随仓库纳入版本管理。
- 🧭 嵌套 shim 的加载协议改为相对定位（原写死旧机器绝对路径），版本一致性改为"VERSION 文件 vs shim frontmatter"自校验。
- 🗂 下方 `[1.0.0]`–`[4.4.0]` 条目为内部开发期历史记录，保留存档，**不代表对外发布历史**。

### 开源准备（2026-10-09）

- 📜 **许可换标准全文**（`LICENSE` = PolyForm Noncommercial 1.0.0 逐字全文）：非商业免费（需署名，允许署名转载）；附加要求（Required Notice 行/署名与版权标识/名称与背书限制/商用授权）见 `NOTICE.md`；商业使用需书面授权（联系 @shingja）
- 🤝 **贡献体系落地**：`CLA.md`（贡献者许可协议，含再许可权）、`CONTRIBUTING.md`（中英）、PR 模板与 Issue 模板（bug / feature / config）
- 🔒 **合规**：`tools/docx|pdf|xlsx`（Anthropic 第三方代码）**移出仓库**，改由 `tools/fetch_official_tools.py` 从官方来源本地获取；新增 `tests/test_privacy.py`（隐私与合规回归：机器路径 / 私人邮箱 / 手机号 / 第三方目录 + 可选禁词表）
- ⚙️ **CI**：`.github/workflows/ci.yml`（隐私扫描 + 完整性 + 完整性校验 + 全套测试）与 `requirements-dev.txt`
- 🖼 **README**：徽章（stars / forks / 双许可）、FAQ、路线图、贡献章节、双许可说明、官方工具获取步骤、社交预览图（1280×640）
- 📋 内部发布计划（不入库，`docs/internal/`）：开源发布计划 / 发版检查清单 / 推广方案
- 🏷 **实战内容匿名化**：两份实战复盘重写 + 全库赛题标识清理（去题名/赛事/平台/答案数值）；版权标识与内部版权规则同步更新；公开仓库名定为 `math-modeling-workbench`（不含校名）

## [4.4.0] - 2026-08-17

### CV 目标检测实战范式化 (S7)

- 🆕 3 张 CV 范式卡 (⑥ML): `PARADIGM-0623-CV-DET-BASELINE`(YOLO基线+分阶段延训) / `PARADIGM-0624-CV-ENSEMBLE`(WBF/TTA/逐类阈值/Severity Top-K) / `PARADIGM-0625-CV-FSF-FIM`(频域-边缘架构增强)
- 🆕 `references/lessons/实战复盘_CV目标检测.md`: 题目画像(黑箱评估vs传统题)/无负样本二分类(检测推导法)/训练充分性(延训相对提升约 52%)/集成后处理/提交包工程(路径封装/20MB/附录代码一致性)/审计教训清单/环境坑清单(AMP黑名单/VRAM残留/换机三件套)/下次CV题检查链
- 🔧 三角色 SKILL.md: Linger+CV数据拓扑审计特例与范式卡路由; Tide+CV工程管线特例; Gloom+CV三对齐审计/硬性门控CV附加项/B题格式教材指针
- 🔧 INDEX.md: S7 新增块 + ⑥ML 27卡 + 视图二 D题CV子路线; keyword_router.json 3 新条目(CV/检测/频域关键词, D题权重0.8)
- 🔧 版本号六处同步 4.3.1→4.4.0 (VERSION/frontmatter/shim/plugin.json/README/使用教程/KNOWN_ISSUES)
- 📖 Gloom格式教材: 样例提交版论文 docx/pdf (本地留存) 作为排版范例入口已写入Gloom"何时加载"

### 外部搜索政策

- ✅ 保持 v4.3.1 "只检不禁" 不变 (赛题级搜索放开, 覆盖/效果/结果更优检查, 合规落声明侧)

## [4.3.1] - 2026-08-16

本次为补丁升级（PATCH）。用户决策修订: 全网搜索协议从"设禁"改为"只检不禁"。

### Changed
- **external_search_protocol.md 策略重写**: 删除"硬红线/禁题号/禁赛题讨论"门禁, 改为 §2 检查清单(只检不禁):
  - 2.1 搜索覆盖检查: 赛题级讨论与解答列为**应当主动搜**的最高效解题参照路径(题号+题名关键词, CSDN/知乎/GitCode/小红书/面包多)
  - 2.2 效果检查: 找到的方案 vs 库内方案指标对比/候选卡齐全
  - 2.3 结果更优检查: 引入后指标是否提升、与搜到的其他队伍方案对比我方是否更优更有说服力
  - 2.4 风险提示(提示不阻止): 照抄=规则第4条后果、查重风险——由队员自行决策
- **§8 声明义务独立成节**(搜索完成后的必做事项, 非搜索门禁): 参考文献引用/正文标注/AI 工具使用详情如实声明
- M-Loop 协议 §3.1b、Linger SKILL.md、主 SKILL.md 路由行同步"只检不禁"表述
- 版本 4.3.0 → 4.3.1(七处同步)

### 设计说明
用户立场: 搜赛题相关内容是解题刚需(实战中即搜 5 平台、25 条目), 别队也会搜; skill 不自我设限, 只检查"搜得全不全、用得值不值、结果强不强"; 合规作为最终声明义务落地(论文/AI 详情/参考文献), 不在搜索环节设卡。

---

## [4.3.0] - 2026-08-16

本次为次版本升级（MINOR）。用户提议扩展: 建模库内任何模型组合都无法达标时, 升级全网开源方法搜索; 全部尝试后取最优方案, 其余方案转论文对比分析。

### Added
- **`references/external_search_protocol.md`**: 全网方法搜索协议。§1 触发(库内 ≥2 轮无改善/无匹配模型族/用户要求); **§2 硬红线**(搜索词禁题号题名届次/禁浏览赛题讨论——参赛规则第5条/禁照抄开源——规则第4条/只找方法不找答案); §3 四层搜索(学术→开源→平台→数学, 每层 ≤45 分钟); §4 新方法候选卡(来源DOI/适用性/实现成本/失败风险); §5 引入流程(评审→改造→重跑scorecard→成功后吸收审计范式卡化入库); §6 方案对比终局; §7 预算(与 M-Loop 共用, 外部引入 ≤2 个)
- **M-Loop 协议升级**: §3.1b 库内耗尽→全网扩展层; §3.4 方案对比终局(汇总全部方案→取最优→其余转论文辅助证明)
- **诚实披露协议 §六**: 方案对比分析节模板(落选方案挂数值差距+文献, 失败尝试也写)
- 三角色接入: Linger(搜索触发+候选卡评审+对比终局裁决)、Tide(方案对比表.md 落盘)、Gloom(对比分析节写法)

### Changed
- 版本 4.2.0 → 4.3.0(七处同步: VERSION/frontmatter/shim/plugin.json/README/使用教程/KNOWN_ISSUES)
- SKILL.md 路由表新增"库内耗尽/全网方法搜索"行; M-Loop 能力行与目录结构更新

### 设计要点
- 搜索必须是**方法论级**(找算法/数学方法/文献), 严禁赛题级(找答案)——这是竞赛纪律红线, 协议 §2 写死
- 外部方法文献化(DOI)+代码改造而非照抄(抄袭=无条件取消评奖)
- 对比终局 = 实战中 RSM vs GPR 三对比模式的泛化, 评审实证为加分项
- 成功的外部方法经吸收审计范式卡化入库, 形成"库内→全网→吸收"闭环

---

## [4.2.0] - 2026-08-16

本次为次版本升级（MINOR）。核心: **M-Loop 模型迭代闭环**——建模方案实现后指标不达标时的自动寻优路径(此前只有"模型不可实现"才回Linger, 指标不满意无闭环)。

### Added
- **`references/model_improvement_loop_protocol.md`**: M-Loop 协议。指标目标卡格式(§2)/迭代轮次(§3, 预算=剩余小时×1 上限5轮)/收敛判定(达标/连续2轮改善<2%/预算尽)/轨迹留档 metric_trajectory.json(§3.3, 迭代轨迹=论文加分材料)/四层方案评审(§5, 取自 nature-proposal-writer 四层QA管线)/防自欺条款(§6, 禁换口径达标)
- **`tools/model_quality_score.py`**: 评分卡工具。读指标目标卡(md表格或json, 支持 ≥/< 方向与硬软双档)→输出每指标 PASS/FAIL/MISSING 三态+summary(ALL_PASS/SOFT_FAIL/HARD_FAIL), 退出码 0/1/2 可直接脚本化
- **C1 门禁 D6 维度**: 读 model_quality_score.json——HARD_FAIL/SOFT_FAIL→FAIL(须M-Loop迭代), ALL_PASS→PASS, 文件缺失→N/A(老项目兼容不阻塞)。三分支 MATLAB 实测通过
- **tests/test_model_quality.py**: 5 断言(全过/硬失败exit2/软失败exit1/MISSING判硬不达标/双档取硬值)
- Linger固定产物新增 `指标目标卡.md`(v4.2, T2/T1 必须)+ 步骤10 设定指标目标 + 步骤11 四层自审 + M-Loop 迭代响应
- Tide步骤10 指标评分(硬不达标发[模型迭代]+证据包含诊断深度; 软不达标先数值卫生修复)
- Gloom加载表 + 诚实披露协议 §五: metric_trajectory → 方法学洞察写法
- SKILL.md 路由行 + C1 门禁表 D6 + 核心能力 M-Loop 行

### Changed
- 版本 4.1.0 → 4.2.0(七处同步: VERSION/frontmatter/shim/plugin.json/README/使用教程/KNOWN_ISSUES)
- 使用教程门禁链/加载链/协议层更新(含 M-Loop 与 model_quality_score)
- plugin.json description 增 M-Loop
- 套件 11 → 12

### 设计背景(用户提议, 实战实证支撑)
实战中 GPR raw R²=-6.09 → 诊断 → scaled R²=0.996 就是一次成功的模型迭代, 但当时靠误打误撞。M-Loop 把"指标不达标→带证据回Linger→修订→重实现→轨迹留档"范式化, 与 joint_calibration(管一致性)、多轮审计(管论文)三者互补。

---

## [4.1.0] - 2026-08-16

本次为次版本升级（MINOR）。将本地教材资源（<资料根目录>\）增量学习并入：补齐算法实现、新增论文格式实测基线、AI 声明模板、题目与论文库索引。

### Added
- **6 个 MATLAB 实现**（全部 self-test+validate 通过，从教材资源移植并改造为 skill 统一风格）: matlab/stats/em_algorithm.m（EM/GMM）、matlab/ml/apriori_association.m（关联规则）、matlab/optim/simulated_annealing.m、matlab/optim/genetic_algorithm.m（自写无 gatbx 依赖）、matlab/simulation/monte_carlo.m、matlab/stats/regression_diagnostics.m（残差分析/杠杆值/Cook 距离）
- **2 张范式卡**: PARADIGM-0621-EM.md、PARADIGM-0622-APRIORI.md（INDEX/router/算法索引/assets/09/manifest 全同步）
- **论文格式实测基线** `references/lessons/论文格式基线_CUMCM规范与实测.md`: 样例提交版 docx 逐项反解（styles.xml/numbering.xml/sectPr 依据）——页面/节结构/标题体系/图注表注自动编号/三线表 XML 可复制定义/OMML 486 公式/参考文献 [n] 制/代码附录格式；CUMCM 2026 官方三件套逐条核对；国赛 Word 构建检查单
- **AI 工具使用详情模板** `references/lessons/AI工具使用详情模板.md`: 六节结构+两表列规范+5 条交互记录实例+贡献占比量化+"写 AI 的失败"策略+生成 checklist
- **题目与论文库索引** `references/lessons/CUMCM题目与论文库索引.md`: 2003+2010-2025 共 84 题索引、256 篇论文库、5 篇实测写作范式、国一三增量范式（策略命名制/精度数据并列/附录三件套）、9 月备赛题型趋势
- **训练题库索引** `references/lessons/训练题库与资料索引.md`: 团队 6 周训练题、完整训练题 B/D、smoke 测试候选
- **本地算法资源差异清单** `references/lessons/本地算法资源差异清单.md`: 算法资料 28 模块+新1 7 目录 vs skill 差异表、LOCAL_*_ROOT 路径索引

### Changed
- 版本 4.0.0 → 4.1.0（VERSION/frontmatter/plugin.json/shim 四处同步）
- 范式卡 159 → 161、MATLAB 222 → 228 个 .m、ML 大类 22 → 24
- SKILL.md 路由表新增 5 行（格式基线/AI 模板/题目论文库/训练题库/本地资源）
- 三角色"何时加载"表接入新 lessons 文件
- 避坑手册_Gloom.md 新增"国一论文三增量范式"节

### Fixed
- lessons 目录历史遗留"创新杯"内容全量清除（基线/AI 模板/训练题库三文件）
- 论文格式基线文件定名 论文格式基线_CUMCM规范与实测.md（去除历史赛事代号），论文格式规范.md 引用同步
- rebuild_manifest.py GBK 编码隐患标注（需 PYTHONUTF8=1 运行）

### 验证
- validate_m_files.py 全量 228 文件 176 过/52 既有失败（零回归）
- 11/11 python 套件通过（含 integrity 的 router 覆盖：153 条全非占位）
- 6 个新 .m MATLAB 实跑 self-test 6/6 通过

---

## [4.0.0] - 2026-08-16

本次为重大版本升级（MAJOR）。将 2026 年夏两项完整实战（机理优化类、CV 检测类，已匿名化）的经验范式化进 skill：数值卫生诊断、诚实披露、多轮审计、外部对标、提交包规范五条经验链。其中 60+ 轮审计迭代、GPR 标准化发现（R²=-6.09→0.996）、RSS 低估、KKT 验证为核心贡献。

### Added
- **实战经验库 `references/lessons/`（7 文件）**: 实战复盘_机理优化 / 避坑手册_Tide（15 坑+数值卫生速查+6 数值模式+加分诊断表）/ 避坑手册_Gloom（18 教训+摘要/章节实战模板）/ 诚实披露协议（披露清单+诚实小节模板+AI 声明六节模板+AI 率控制）/ 多轮审计迭代协议（R1-R60 轮次登记+单轮聚焦+审计者池+收敛判定）/ 外部对标协议（平台 sweep+对比矩阵+偏离二分法+防御话术）/ 提交包规范（S1 门禁+干净目录重跑验证+身份五查）
- Tide质检清单新增"数值卫生"15 条（尺度比/条件数/train-test 双列/灵敏度量纲/域覆盖审计/σ 语义/反装饰数据/有效断言数/提交包复现等，坑1-坑15 逐条对应）
- Tide常见模式新增"九、数值模式"6 个（代理三对比/多重验证/灵敏度收敛矩阵/MC 传播/机理标定+9/9 验证/冻结断言）
- Gloom自审框架新增"六、实战新增"12 条
- Gloom CUMCM 硬性门控扩充（图引用覆盖率/附录文件列表/AI 条目四要素/R² 分指标/元数据身份检查/摘要逐数字比对）
- Linger执行顺序新增: 数据拓扑审计 / 外部对标（M1 前）/ 代理模型选型特例（标准化前置）/ decision_log 记录（含诊断深度标注）
- Tide执行顺序新增: 数据域审计 / 数值卫生自检 / C1 五文件生产链 / 提交包干净目录重跑验证
- Gloom优化模式: "最多 2 轮"硬限改为按剩余时间预算轮次（实战验证: 60+ 轮显著提升）
- 新增 tests/test_skill_integrity.py（版本一致/description 单行/死引用/路由覆盖/门禁参数/编码完整性）

### Changed
- **版本号统一 4.0.0**: VERSION / SKILL.md frontmatter / plugin.json / 嵌套 shim / README（原 VERSION=3.2.0、frontmatter=3.0.0、plugin.json=2.2.1、shim=2.2.1 四处不一致）
- SKILL.md 全面重写: description 改单行（修复多行 `|` 块加载风险）、真实数字（159 范式卡/222 .m/12 大类各算法数）、路由表修死引用（§4/§2/S5/OPTIMIZATION_REPORT/run_all）、目录结构补全、新增经验库路由行与 Subagent 调度行
- 门禁表标注硬/软属性（硬 3: C1/W1/W2；软 3: M1/P1/P2）；W2 注明电子版/纸质版双结构
- 嵌套 shim 更新为 v4.0.0 指针, description 与主文件一致
- 外部备份 skill `math-modeling.backup-v2.2.1-20260728-131003` 移出 skills/ 目录（双触发冲突消除, 归档至 <本地备份目录>）
- 恢复 v2.2.1 被删的 AI 工具使用详情自动生成条款并升级为六节模板（诚实披露协议 §四）

### Fixed
- test_subagent_protocol.py 全量重写（原断言 v2.x 旧协议字符串, 5/6 失败; 现 10/10 对齐 v4 内容）
- 算法索引死链 9 处（knn.m→knn_predict.m 等）
- INDEX.md 统计表数字、死锚点、NS-ENERGY 幽灵引用
- keyword_router.json 100% 占位问题（脚本从卡名自动填真实关键词）
- W2 门禁承诺书/编号页要求与 2026 电子版规范矛盾（--mode electronic|paper）
- 身份黑名单 regex 误报（"节省/区域/市面"）
- C1 脚本阈值一刀切（改为协议三档 PASS/WARN/FAIL）
- Subagent调度.md 门禁表补 C1 行
- matlab/ 下 8 个 .backup 残留移入 .backups/
- 常见模式.md 两个"## 七"编号
- 过期 coverage_report.json 移入 docs/history/

### Paradigm-Updated
- PARADIGM-1001-GPR.md: 新增"数值卫生必查"（标准化前置/ARD 不能替代标准化/预测 σ≠制造 σ/负 R² 诊断）
- PARADIGM-1003-RSM.md: 新增"数值卫生必查"（标准化空间系数不可物理解释/train-test 双列/外推禁区）
- joint_calibration_protocol.md: 条件数检查扩展到全部代理模型

### 回退方案
- 完整备份: `<本地备份目录>\v3.2.0-20260816-pre-refactor\`（650 文件）
- 历史备份: `<本地备份目录>\math-modeling.backup-v2.2.1-20260728-131003\`
- 复制回 skills 目录即可回退

---

## [3.0.0] - 2026-07-29

### Added
- **联合校准闭环**: joint_calibration_protocol + C1 门禁 (gates/C1_joint_calibration_check.m, tools/joint_calibrate.m/.py)
- **结果-主张哈希绑定**: tools/result_claim_bind.m/.py (SHA-256, bind/verify 模式)
- **多模型选优**: tools/model_ensemble_select.m/.py (AIC/BIC/CV/calibration/weighted)
- **C1 门禁**: 5 维度检查 (calibration_score, 修正记录, 哈希绑定, 多模型选优, 握手包完整性)
- **3 大新算法类**: ⑩代理模型(6), ⑪鲁棒优化(5), ⑫MCDM进阶(12)
- **151 张范式卡**: references/paradigms/ + INDEX.md + keyword_router.json
- **Tide工程化**: 9 题型模板(matlab/templates/), 24 图表函数(matlab/figures/), 数值健壮性层(matlab/utils/), 31 属性测试(matlab/tests/property/)
- **Gloom 2026 规范对齐**: LaTeX 模板(tools/latex/assets/templates/cumcm/main_2026.tex), Word 结构规范, W1/W2 门禁脚本
- **论文数值自动生成**: tools/generate_paper_numbers.m (JSON→LaTeX newcommand)
- **吸收审计全流程**: absorption_audit/absorption_audit_b/c/d.md, dedup_map.json, paper_index_skeleton.md, new_algo_candidates.md, crosswalk_D_vs_newalgo.md
- **知识图谱路由**: references/paradigms/keyword_router.json

### Changed
- MATLAB 覆盖率: 89.9% → 97.7% (82 → 150 .m 文件, 129 pass validate, 128/131 honest coverage)
- 算法库: 9大类89算法 → 12大类150+算法
- 门禁: 5道(M1/P1/P2/W1/W2) → 6道(M1/P1/C1/P2/W1/W2)
- 门控第 1 条: 修正为 2026 官方页面结构(承诺书→编号→摘要→正文)
- 触发词/路由: 全面重写, 中英文双语, 含负面边界
- SKILL.md description: 单行→多行, 含 triggers 列表, 含 "Do NOT use for" 负面边界
- Gloom写作规范: 新增 2026 数值格式 + S7 联动 + MCM/ICM 章节
- Gloom自审框架: 更新页面结构/页眉/身份信息检查项

### Fixed
- 旧模板冲突: "第一页摘要" "含英文摘要" "有页眉" 等与 2026 官方规范冲突项
- 18 个 fail-validate .m 文件 (v6 exitflag/convergence + v7 self-test)
- validate_m_files.py v7 regex 过严问题 (assert(all(abs(...))) 匹配)
- dedup_map.json: 由文件名模式升级为 SHA-256 内容哈希验证 (34对全部identical)

### Removed
- 无 (所有旧文件已备份为 *.backup-v2.2.1-<timestamp>)

### Paradigm-Added
- 151 张范式卡 (references/paradigms/PARADIGM-*.md)
- 联合校准协议 (references/joint_calibration_protocol.md)

### S11 端到端冒烟
- **2024 CUMCM C题全链路验证**: Linger→Tide→C1→Gloom→W1/W2
- **calibration_score = 0.81 (WARN, > 0.70)**: 真实冒烟, validation_cases name mismatch 导致 magnitude 偏低, 非算法缺陷
- **CONDITIONAL PASS**: 18/18 phases complete, 已知限制诚实记录

### S12 最终报告
- `RELEASE_NOTES_v3.0.0.md` (迁移指南+回滚), `KNOWN_ISSUES.md` (9条目+复核记录), `FINAL_METRICS.md` (规模/质量/耗时), `DIRECTORY_TREE_v3.0.0.txt`

### S13 根目录整理
- 根目录 32项 → 13项 (15 DOC→docs/, 3 BACKUP→.backups/, 0删除)
- 引用修复 3处, 零死链, 零功能回归

### 复核轮次 (四轮取证, 2026-07-29)
- **R1**: 澄清 129 vs 170 (过期快照)
- **R2**: 门禁软硬定性 (3硬C1/W1/W2 + 3软M1/P1/P2)
- **R3**: 52 fail拆解 (真3+合49), Z=0, 三口径固化
- **R4**: sigmoid 6引用方全验 (5PASS+1N/A), Z=0焊死

---

# 更新日志

根目录 `VERSION` 是当前版本的唯一准据。

## 2.1.0 - 2026-07-27

本次更新为次版本升级（MINOR），包含三阶段优化：目录去重与SKILL.md修复、MATLAB全量覆盖（14个新算法）、建模-编程协作协议。

### Phase 1: 目录去重与元数据修复

- **目录合并**：`math-modeling`（符号链接）→ 重命名 `math-modeling-skill` → `math-modeling`（唯一真实目录）
- **SKILL.md 修复**：description 改为纯单行无引号字符串；移除非标准 `when_to_use` 字段；`name` 与目录名严格一致
- **引用清理**：`settings.json`、`skills/README.md`、`docs/使用教程.md` 中所有 `math-modeling-skill` → `math-modeling`

### Phase 2: MATLAB 全量覆盖

- **14 个新增 MATLAB 实现**（含 2026-07-27 同日 ML 10个 + 本次 14个）：
  - **图论** (5): `dijkstra.m`, `floyd_warshall.m`, `kruskal.m`, `maxflow_ford_fulkerson.m`, `hungarian.m`
  - **预处理** (2): `normalize_data.m` (5方法), `fill_missing.m` (5方法)
  - **聚类/降维** (2): `kmeans_cluster.m` (k-means++), `pca_decomp.m` (SVD)
  - **统计** (1): `anova_oneway.m`
  - **插值** (2): `interp_lagrange.m`, `interp_cubic_spline.m`
  - **优化** (2): `ant_colony_tsp.m`, `differential_evolution.m`
- **算法索引同步更新**：图论/统计/预测/优化/ML 各节 MATLAB 列路径
- **新增文档**：`docs/history/MATLAB增量更新日志_v2.1.0.md`（差距分析+优先级+规范）

### Phase 3: 建模-编程协作协议

- **新增** `references/model-to-code-handoff.md`：结构化交接协议
  - Linger交付物标准：变量映射表 + 算法伪代码 + 参数约束 + 验证用例
  - Tide反馈标准：实现偏差 + 数值稳定性 + 性能瓶颈 + 交叉验证
  - T1/T2/T3 三级粒度对照表
  - 交接检查清单 + 握手确认信号 + 产物模板
- **Linger SKILL.md 更新**：新增"Tide握手交付"节 + 固定产物增加 `模型握手交付包.md` + 何时加载新增握手协议
- **Tide SKILL.md 更新**：新增"输入检查清单" + 步骤0握手接收 + 步骤4-5验证/反馈

### 算法库大幅扩充（同日早期更新）

- 基于 `算法资料新1` 目录新增 10 个机器学习算法、增强 6 个已有算法的代码实现、集成本地知识库 6 个新资源目录。

### MATLAB 实现（2026-07-27 同日追加）

- **10 个全新 MATLAB 实现文件** 存放于 `SKILL_ROOT/matlab/`：
  - `perceptron.m` — 原始形式 + 对偶形式，含交叉验证
  - `knn.m` — 暴力搜索（4种距离）+ 交叉验证选k + 加权回归
  - `naive_bayes.m` — Gaussian/Multinomial/Bernoulli 三种变体
  - `logistic_regression.m` — 二分类 + Softmax多分类，SGD/Mini-batch，L1/L2/ElasticNet 正则化
  - `svd_algo.m` — 完整/随机化/幂迭代 SVD + 压缩 + 协同过滤
  - `pagerank.m` — 标准 + 个性化 + TextRank 变体
  - `lsa.m` — TF-IDF/Log-Entropy 加权 + 语义查询 + 文档检索
  - `plsa.m` — EM算法 + 主题词提取 + 文档主题分析
  - `lda.m` — 坍缩 Gibbs 采样 + 困惑度评估
  - `mcmc.m` — Metropolis-Hastings + 自适应MH + Gibbs + ESS/R-hat诊断
- **统一测试脚本** `matlab/test_ml_algorithms.m` — 10 个算法的单元测试
- 每个函数均含完整 docstring（参数/返回值/算法来源/参考文献/复杂度标注）
- 代码风格与现有 `LOCAL_ALGO_ROOT` MATLAB 代码一致（`%%`分段、中文注释、`disp`输出）
- 算法索引 `references/算法索引.md` 已同步更新 MATLAB 列路径

### 算法库大幅扩充

- **新增 10 个ML算法**（感知机、k近邻法、朴素贝叶斯、逻辑斯谛回归、SVD、PageRank、LSA、PLSA、LDA、MCMC），均含完整 Python 实现
- **增强 6 个已有算法**（SVM/SMO、AdaBoost/GBDT、EM/GMM、PCA、K-Means/层次/DBSCAN、线性回归向量化），从"无代码"升级为"有完整 Python 实现"
- **ML 算法总数**：8 → 24+，覆盖线性分类器/集成学习/聚类/降维/概率图模型/文本挖掘/图算法 7 个子类
- 新增资产文件 `assets/09-机器学习算法进阶说明.md`（17,000+ 字），含算法原理/公式/复杂度/代码路径/场景指南/参考文献
- `references/算法索引.md` ML 章节从 1 个表 8 行扩展为 7 个子表 24+ 行
- 新增题型感知推荐：NLP/文本挖掘、降维与特征工程、概率建模与贝叶斯、图与网络分析

### 本地知识库扩展（6 个新目录）

| 环境变量 | 路径 | 内容 |
|----------|------|------|
| `LOCAL_ML_ALGO_ROOT` | `算法资料新1/22种机器学习常用算法Python实现全套代码/` | 22 个 ML 算法 Jupyter Notebook |
| `LOCAL_ML_BOOKS_ROOT` | `算法资料新1/MLbooks-master/` | 20+ 本 ML 经典教材 PDF |
| `LOCAL_MATH_BOOKS_ROOT` | `算法资料新1/数学基础/` | 7 本数学基础教材 PDF |
| `LOCAL_CASES_ROOT` | `算法资料新1/大数据竞赛实战案例/` | 3 个完整 Kaggle 竞赛流水线 |
| `LOCAL_VIZ_ROOT` | `算法资料新1/Matplotlib-and-Seaborn-master/` | 10+ 可视化教程 Notebook |
| `LOCAL_PYTHON_ROOT` | `算法资料新1/备赛学习资料/` | Python入门→进阶→数据分析 |

### 渐进式加载表新增 4 行

- 查找 ML Python 实现 → `LOCAL_ML_ALGO_ROOT`
- 查找 ML 理论基础 → `LOCAL_ML_BOOKS_ROOT` / `LOCAL_MATH_BOOKS_ROOT`
- 参考竞赛实战案例 → `LOCAL_CASES_ROOT`
- 查找可视化模式 → `LOCAL_VIZ_ROOT`

### 算法库统计更新

| 指标 | v2.0.0 | v2.1.0 | 变化 |
|------|--------|--------|------|
| ML 算法数 | 8 | 24+ | +16 |
| 有代码的 ML 算法 | 4 | 20+ | +16 |
| 本地知识库目录 | 6 | 12 | +6 |
| 资产文档数 | 8 | 9 | +1 |
| 算法索引 ML 子类 | 1 | 7 | +6 |

### 参考资料来源

- `算法资料新1`：22 种ML算法 Python 实现、ML 教材 20+ 本、大数据竞赛案例 3 个、可视化教程、Python 技能栈、数学基础教材 7 本
- 理论基础：李航《统计学习方法》、Bishop PRML、Hastie ESL、周志华《机器学习》、Mitchell ML

### 向后兼容

- 所有已有函数签名和索引路径保持不变
- 新增条目仅追加，不影响已有算法查找
- Python 新增实现标注"MATLAB 翻译待完成"，不强制优先使用
- 线性回归/决策树重复实现以增强版独立路径提供，旧路径不变

## 2.0.0 - 2026-07-14

本次更新为重大版本升级（MAJOR），全面重构算法库索引、确立 MATLAB 为主语言范式、集成本地知识库、提取获奖论文排版范式。

### 语言范式变更（BREAKING）

- **MATLAB > Python**：Tide交付物优先要求 MATLAB（`.m`）代码，Python 作为备选或数据处理辅助
- 算法索引新增每个算法的本地 MATLAB 路径（`LOCAL_ALGO_ROOT`），标注 MATLAB/Python 代码存在状态
- Tide实现前必须先检查本地 MATLAB 代码是否存在
- 完成判定新增"MATLAB 代码为主，Python 为备选"
- 可视化规范强调 MATLAB `exportgraphics` 优先，`rng(seed,"twister")` 确定性

### 算法库重构

- **算法索引 v2.0**：从简化速查表升级为 8 大类完整索引，每个算法标注 MATLAB 路径、Python 路径、教材章节、Skill 文档
- **与 28 个培训模块完全对齐**：每个模块标注本地代码存在状态（✅/—）
- **新增教材对照**：关联《各类常用数学模型》30 章 + 4 附录
- **新增算法路径**：统计推断系列（条件概率/独立性/常用分布/统计量/CLT/参数估计/假设检验）的 MATLAB 和 Python 实现路径
- **去重说明**：Inter2Max/Min2Max/Mid2Max/Positivization 在 TOPSIS 和灰色关联分析两处重复，保留 TOPSIS 版本为权威来源

### 本地知识库集成

- 主 SKILL.md 新增"本地知识库路径"章节，定义 6 个本地资源路径
- 新增环境变量：`LOCAL_ALGO_ROOT`、`LOCAL_TEXTBOOK_ROOT`、`LOCAL_PAPER_ROOT`
- 渐进式加载表新增 3 行：参考获奖论文、查找 MATLAB 实现、查找理论依据
- 根目录契约新增本地只读知识库约束

### 输出模板：获奖论文范式

- 基于 2023-2025 年 CUMCM 国家奖论文（37 篇）逆向分析
- 摘要写法规范：背景→方法→求解→**数值结果**（强制）→贡献
- 正文结构规范：问题重述→问题分析→模型假设→符号说明→模型建立与求解→灵敏度分析→模型评价→参考文献
- 图表规范：三线表 `\toprule[2pt]`/`\midrule[1.3pt]`/`\bottomrule[2pt]`、colorblind-friendly 色板、300 DPI
- 数值表达规范：4 位有效数字、百分比 2 位小数、p 值 3 位小数

### 团队定制增强

- 队员角色说明（Linger/Tide/Gloom）
- 软件栈：VS Code、MATLAB、Python(Jupyter)、LaTeX、Excel/WPS、SPSS/SPSSPRO、Visio/PowerPoint
- 队伍 LaTeX 模板路径
- 暑假选拔作业（A/B/C/D 四选二）及截止日期

### 参考资料来源

- 本地算法代码库：`<资料根目录>\算法资料\`（28 个模块，~160 MATLAB 文件 + ~60 Python 文件）
- 本地教材库：`各类常用数学模型\`（30 章 + 4 附录，61 PDF）
- 本地论文库：2003-2025 获奖论文（250+ 篇 PDF）
- 团队培训资料：6 周作业
- 团队官方规则文件

## 1.1.0 - 2026-07-14 (排版与算法库升级, 与 2026-07-24 条目合并记录)

本次更新基于配套资料（获奖论文、算法培训材料、团队资料）全面优化升级。

### 排版质量升级

- 论文格式规范新增"国赛一等奖论文格式特征"章节，提炼 2023-2025 年获奖论文的结构、摘要、图表、公式、三线表规范
- 论文格式规范新增"字体与段落""附录与代码规范""参考文献格式"：字体/字号/对齐标准表、附录代码注释/路径/种子规范、GB/T 7714 参考文献格式
- 写作规范新增"一等奖论文写作特征"，包括摘要数值结果要求、正文论证展开方式、数值表达精度规范
- 章节模板和自审框架保持原有完整性

### 算法库扩充

- 新增 `assets/08-机理建模算法说明.md`：人口增长模型（Malthus/Logistic/Leslie）、传染病模型（SIR/SEIR/SIS）、ODE/PDE 数值求解、差分方程
- `assets/05-统计分析与数据处理算法说明.md` 新增：概率分布与统计推断（10 种分布、中心极限定理、MLE/贝叶斯/EM 参数估计）
- `assets/07-机器学习算法说明.md` 新增：决策树（分类/回归、剪枝策略、Gini/信息增益/CART 准则、规则导出）
- 算法索引更新：添加团队培训 28 个模块与资产文件的对应关系表
- 资产目录 README 更新：新增机理建模算法文档
- 覆盖率提升：填补了之前统计基础（CLT/参数估计/分布实现）和决策树的 4 个 HIGH/MEDIUM 缺口

### 多 Skill 协作集成

- 主 SKILL.md 新增"关联 Skill 协作"路由表：nature-polishing（英文润色）、nature-figure（图表增强）、nature-statistics（统计审查）、nature-reviewer（论文预审）、nature-academic-search（文献搜索）、nature-ref-verifier + nature-citation（参考文献校验）、nature-writing（写作辅助）
- Gloom SKILL.md 加载表增加可选 nature-skill 调用入口
- 英文化工作流增加 nature-polishing 工具链推荐
- 可视化规范增加 nature-figure 增强选项

### AI 合规与团队定制

- 主 SKILL.md 新增"AI 工具合规"章节：依据 2025 年试行规定的透明原则、正文标注、参考文献记录、AI 使用详情文档要求
- 主 SKILL.md 新增"官方规则摘要（2026 版）"：提交前核验清单
- 主 SKILL.md 新增"团队定制"章节：培训进度、选拔作业要求、算法库对齐

### 参考资料来源

- 配套资料文件夹：获奖论文（2003-2025）、算法资料（28 个模块）、团队资料
- 团队官方规则文件：论文格式规范（2026 版）、AI 工具使用规定、参赛规则

## 1.1.0 - 2026-07-24

### 图表数量门禁

- Tide的原始数据图、模型运行过程图和模型最终结果图由“每类至少一张”提高为每类至少 3 张逻辑候选图、合计至少 9 张，并由 `figure_audit.py --strict` 确定性拦截数量不足。
- 新增按子问题覆盖门禁：用 `raw_q1_*`、`process_q1_*`、`result_q1_*` 等命名，每个子问题在三类中各至少 1 张；审计命令必须通过 `--questions` 显式传入题目全部子问题，防止只为问题一集中出图。
- Word 与 LaTeX 论文统一采用至少 8 幅图的默认质量基线，MCM/ICM 等其他竞赛不再低于 CUMCM；当届官方规则或用户明确要求仍可覆盖默认值。

### Subagent 默认质检与可选协作

- 将质检从主 Agent 的阶段末自评改为作者自检、确定性脚本与独立 Subagent 验收三层门禁，禁止等全流程结束后才首次派发。
- 新增 `M1` 建模终检、`P1` 最小可运行结果、`P2` 编程终检、`W1` 证据大纲和 `W2` 论文终检；在全量计算和长篇排版前提前暴露模型漂移与证据缺口。
- 统一 Subagent 的只读边界、输入快照、`PASS/FAIL/BLOCKED` 回执、证据格式、返工归属、产物变更失效和修后复验规则。
- 明确默认只运行固定质检 Subagent；规则核验、附件盘点、文献与模型调研、算法原型、独立实验、双语言对照和术语核验仅在用户明确选择后运行。
- 为可选协作补充输入输出、隔离执行和权威产物边界，同时禁止多人并写权威产物或重复已有脚本的机械检查。
- 保持公开版本基线为 `1.0.0`，不增加第四个固定角色或额外交付物。

### 出版级科学可视化

- 将 Nature Skills 的图表契约、证据映射和出版级交付思想，与 SciPilot 的数据剖析、图型决策、科研绘图避坑和成图复核闭环按数学建模场景重新设计后融入Tide，不直接照搬外部 Skill。
- 根据 CUMCM 实际运行产物补齐视觉层级：每张图先写一句话结论并选择叙事原型，显式声明主面板、辅助证据、非对称比例和图例策略，避免把 Nature/SCI 简化为字体、色板与 DPI。
- 为 Python 与 MATLAB 增加出版设计预检，默认拦截长标题、超量图例、稠密逐点标记、非零基线柱状图和已标数值 2×2 小矩阵的冗余 colorbar。
- 补充分组经验率、少量点估计、PR 曲线、混淆矩阵和特征重要性的选图规则，修正锯齿折线、巨型纹理柱、面板机械等分和仪表盘式布局。
- 恢复并明确 Nature/SCI 风格为默认可视化基线，同时声明目标竞赛、学校或期刊的当届官方规范优先，不把通用风格误写成官方认证。
- 新增 Python `plot_style.py` 和 MATLAB 出版样式/导出工具，统一色觉友好配色、字体、线宽、最终尺寸、无网格线基线、可编辑 SVG 与 300 DPI PNG 双格式输出。
- 新增标准库 `figure_audit.py`，自动检查 `raw_`、`process_`、`result_` 三类图、SVG/PNG 配对、SVG 可编辑文本、PNG DPI、JPEG 和嵌入位图风险。
- 补齐导出前缺字/越界/刻度重叠预检与灰度预览，移除会改变最终物理尺寸的 `bbox_inches="tight"`，并在审计报告中记录 PNG 的实际英寸尺寸。
- 新增图表选择与避坑指南，覆盖分布、比较、趋势、优化、预测、分类、评价、空间网络和物理模型，同时保留多生成候选图、由用户和Gloom选择的策略。
- 将视觉验收改为“生成 → 文件审计 → 实际打开预览 → 修改源代码 → 重绘复核”的闭环，并补充 README 中的可视化能力说明与 SciPilot 致谢。

### 模板驱动的 LaTeX 论文支持

- 新增 `doctor` 环境诊断，按所选引擎、BibTeX/Biber 后端、Pandoc 与 PDF 审计能力动态检查 `latexmk`、TeX 引擎、`pypdf`、`pdfimages` 和 `pdftoppm`，缺项时在写作前明确阻塞。
- 初始化项目新增 `latex-project.json`，支持子目录主入口和 `generic` 官方模板，并记录模板 URL、适用届次、目录哈希与唯一主入口。
- 构建新增 `.build.json`，绑定当前源码、PDF、项目模板哈希，记录工具路径与版本、实际命令、返回码、耗时、告警、覆盖理由和复现命令；无清单、旧源码或被替换的 PDF 均不能通过校验。
- LaTeX 改为在系统临时目录的完整项目副本中编译，原始源码不作为编译写入目标；编译后同时核对副本和原项目哈希，动态控制序列造成的文件写入也无法污染真实项目或绕过发布门禁。
- PDF/DOCX 与对应 JSON 清单改为成对替换；覆盖旧版本时先备份，任一替换失败自动回滚，避免留下无绑定产物或丢失上一套有效文件。
- 构建输出固定为项目根目录 `build/`，拒绝会混入源码哈希的任意输出目录；显式传入不存在的 PDF 现在始终失败。
- 编译错误、未解析引用、LaTeX/宏包/文档类、Overfull/Underfull 和字体告警默认阻断 PDF 发布；只允许通过精确正则和具体理由覆盖已核对告警，默认拒绝覆盖既有发布产物。
- 修复 `$$...$$` 被重复计数；新增分隔符配对检查、空图/空表拦截、图表题注与环境外正文引用检查，避免仅堆叠空环境绕过数量门禁。
- 质量校验要求通过 `--questions` 声明全部子问题，并以 `fig:q1-*` 等标签检查正式图覆盖；阈值禁止负数，降低默认目标必须记录官方条款或用户要求。
- 安全编译链只直接接受 PDF、PNG、JPG/JPEG，明确拒绝依赖 shell escape 的 SVG/EPS 编译期转换；新增 PDF 空白页、页面尺寸、字体嵌入与内嵌位图 DPI 检查。
- 完整 LaTeX→DOCX 转换会递归展开项目内 `\input`/`\include`，拒绝越界和循环包含；Pandoc 警告默认阻断 DOCX 发布，并生成绑定输入、输出、模板、版本、命令和覆盖理由的 `.conversion.json`。
- 新增 `verify-conversion`，交付前重新验证 LaTeX/Markdown 源文件、全部项目资源、参考模板、DOCX、清单哈希和完整字段类型；注释与字面量环境保持原样，`verbatim`/`\verb` 内伪命令和百分号不会掩盖后续真实命令，`\nocite{*}` 不再造成误报。
- LaTeX 与 DOCX 命令行统一强制 UTF-8 输出，编译/转换超时可配置；新增针对空图表、旧 PDF、阈值绕过、公式计数、子问题覆盖、嵌套入口、SVG、告警发布和递归转换的回归测试。
- 将 Skill 遵循要求改为可观察的强制执行协议：首次更新回显激活与路径，禁止绕过内置工具，环境缺失时明确阻塞，最终回复必须提供实际命令、退出码和质量指标。
- 新增 DOCX 命令行完成门禁，并将 LaTeX 布局、宏包、文档类和字体预警纳入失败条件，防止篇幅不足或带编译预警的论文被错误宣布完成。
- Gloom默认同时生成内容一致的 DOCX 与 LaTeX/PDF；用户明确只要一种格式时仍可只运行对应分支，两种格式分别生成并校验哈希绑定的质量报告。
- 新增完整 LaTeX 论文转 DOCX：复用 Pandoc 将 `.tex`、相对图片和公式转换为 Word，支持官方 DOCX 参考模板、OMML 公式、转换警告、原子发布与覆盖保护。
- 新增独立 `tools/latex`，支持复制当届官方 LaTeX 模板项目并显式选择多入口模板的主文件；无官方模板时可选择 CUMCM 中文或 MCM/ICM 英文构建基线。
- 新增 `latex_paper.py`，提供模板初始化、XeLaTeX/LuaLaTeX/pdfLaTeX 编译、编译日志诊断、完整项目依赖哈希和 PDF 实际页数检查。
- 增加 LaTeX 论文结构与质量校验：检测占位符、篇幅、公式、图表文件、重复标签、图表正文引用、BibTeX/正文引用对应和官方页数上限。
- Gloom支持按用户要求生成 Word、LaTeX，或默认同时生成两种格式；当届官方提交要求仍决定实际可提交的版本。
- LaTeX 分支交付完整源码项目和由其实际编译的 PDF，不把缺少 `.cls/.sty/.bib` 依赖的单个 `.tex` 文件视为完整交付。
- 编译默认禁用 shell escape、忽略项目级 `.latexmkrc`、限制文件读写范围并拒绝符号链接；缺少引擎或宏包时明确失败，不自动安装或静默换引擎。
- 新增 LaTeX 回归测试，覆盖内置/官方模板复制、覆盖保护、递归源码检查、图表与文献关联、路径越界和编译环境缺失。

## 1.0.0 - 2026-07-10

本版本由 **GPT 5.6 Sol 进行全面检查和完善**。在保留数学建模完整工作流的基础上，对角色职责、论文检索、公式转换、DOCX/Excel 工具、Python/MATLAB 支持、复现机制、路径规则和参考资料进行了系统性修正，并从 `1.0.0` 重新建立公开版本基线。

### 工作流与交付物

- 将完整流程统一为“Linger → Tide → Gloom”三个独立阶段，既支持顺序执行，也支持按需单独执行。
- 固定Linger交付物为 `题目分析报告.md` 和 `术语表格.md`。
- 固定Tide交付物为 Python/MATLAB 代码，以及代码运行产生的表格、原始数据图、模型运行过程图和模型运行结果图。
- 固定Gloom交付物为 `.docx` 格式的完整论文，并规定论文仅供参考，论文内容、结构和格式必须服从目标竞赛当届官方规则与官方模板。
- 完善阶段反馈闭环：下游阶段发现模型、数据、程序或论证问题时，返回对应上游阶段修正，不在后续产物中掩盖问题。

### 建模与算法规范

- 调整模型选择逻辑：先理解题目与数据，再确定结论所需的模型；每个子问题最多使用两个独立模型体系，物理题中同一机理的不同近似和精度展开按一个模型族计数。
- 鼓励在合理、可解释和可验证的前提下避免常见简单模型，以体现建模创新性。
- 修正常见建模模式、算法说明和示例，移除不合理的固定阈值说明、硬编码规则及“同一结论的两个模型必须删一个”等限制。
- 统一可视化要求，允许提供更丰富的候选图；修正双子图示例、HTML 相关说明和算法库示例，并统一取消示例图网格线。

### 论文检索与资料核验

- 实现 OpenAlex + AnySearch 真正的双引擎论文搜索，分别执行检索后汇总结果。
- 优先使用 DOI 归并重复文献；无 DOI 时按规范化题名交叉核验，并保留来源、作者、年份和链接等追溯信息。
- 修正算法资料与引用说明，移除“优秀论文库”相关声明，避免把非官方资料误写成固定依据。

### 公式、DOCX 与 Excel 工具

- 完善 LaTeX、MathML 与 Word OMML 之间的公式转换流程，增加转换校验与失败处理，降低公式丢失、错位和不可编辑风险。
- 改进模板驱动的 DOCX 论文生成方式：优先继承官方模板的页面、样式与章节设置，再填充正文、公式、图表和参考文献。
- 完善 DOCX 生成后的结构检查、公式检查和渲染抽检，确保关键内容在 Word 中可编辑、可见且版式稳定。
- 完善 Excel 表格读写、格式处理和结果导出说明，合并 DOCX 与 XLSX 工具中的重复资源，修正相关 Markdown 文档。

### Python、MATLAB 与复现能力

- 在既有 Python 支持基础上补全 MATLAB 的建模、绘图、结果导出、依赖检查和运行规范。
- 改为根据选中的模型和功能动态检查依赖，不再要求安装与当前任务无关的完整工具集合。
- 统一记录随机种子、输入文件 SHA-256、运行环境与依赖版本、关键参数和唯一复现命令。
- 明确程序必须真实运行，并把对应表格和图形作为论文写作的可追溯输入。

### 路径、资源与文档治理

- 显式区分 `SKILL_ROOT` 与 `PROJECT_ROOT`：所有 Skill 内置资源只从前者读取，所有任务产物只写入后者。
- 默认禁止任务运行过程覆盖 Skill 自身文件，统一并修正全部相对路径。
- 完善渐进式加载，只在当前任务需要时读取相应角色规范、算法资料、工具说明和模板资源。
- 更新根目录 README、`references/README.md`、版本规则和验证说明，同时完整保留版本号重置前的历史更新记录。

### 实际任务测试反馈修正

- 扩充 OMML 公式引擎的常用 LaTeX 命令，补齐 `\nu`、`\mu`、`\approx`、`\arcsin`、`\arccos`、`\arctan` 及更多希腊字母、关系符号和函数。
- 扩展 `validate_paper_structure()`：统计中英文混排篇幅、可编辑公式、图和表，检查图表编号连续性、正文引用、参考文献双向对应，并接收渲染页数。
- 将 CUMCM 的约 15000 字词单位、约 20 页明确为可覆盖的完整度质量目标；依据 2026 年官方规范，将正文不超过 30 页作为当前已核验的硬约束，禁止混淆二者。
- 为 OpenAlex + AnySearch 融合结果增加查询词覆盖率过滤、相关性优先重排和同题名预印本/正式版折叠，减少物理、材料与光学专题中的高被引无关结果与重复结果。
- 增加无隐式表头推断的 XLSX 读取工具和预期行数断言，防止第一行数据被 `pandas` 默认 `header=0` 吞作列名。
- 增加图表题注—正文引用检查，识别孤儿图表、缺失编号和编号跳跃。
- 修正物理建模的模型数量口径：同一控制机理的基础模型与高精度展开属于一个模型族，不机械占用两个模型名额。

## 版本规则

采用语义化版本 `MAJOR.MINOR.PATCH`：

- `MAJOR`：不兼容变更，例如修改固定交付物、目录契约、命令参数或复现清单结构。
- `MINOR`：向后兼容的新能力，例如新增算法类别、工具功能或竞赛配置。
- `PATCH`：向后兼容的修复，例如错误修正、文档校正和测试补充。

预发布版本使用 `1.2.0-beta.1`；Git 标签使用 `v1.1.0`。

## 版本号重置前的历史记录

> 以下内容保留编号重置前的开发历史，仅说明当时版本发生过什么，不代表当前版本仍保留相同文件、规则或能力。

### v2.4 (2026-05)

#### 🏗️ 重大架构更新：角色子Skill + 渐进式加载

原三个单文件角色文档重构为独立子Skill体系，每个角色自包含入口 SKILL.md + 细分引用文件，按阶段渐进加载，大幅降低单次对话上下文负担。

**角色文件迁移**：
```
旧（单文件）                   新（子Skill + 渐进式加载）
references/roles/
├── Linger说明.md    →    references/roles/Linger/{SKILL.md + 4个引用}
├── Tide说明.md    →    references/roles/Tide/{SKILL.md + 4个引用}
└── Gloom说明.md    →    references/roles/Gloom/{SKILL.md + 7个引用}
```

#### 🎯 Linger：新增 Model Contract + 常见模式 + 缺失输入处理

- **Model Contract（前置合同）**：在分析前建立核心结论→证据链→方案评审→交付规格的完整规划框架
- **11种建模常见模式**：按优化/预测/评价/综合分类，含模型组合决策树
- **缺失输入处理规则**：数据不足、模型不适用、问题类型不明确时的标准化处理流程
- **防冗余原则**：每个模型承载独特分析维度，避免重复建模

#### 🎨 Tide：SCI/Nature 级可视化规范 + 环境检查 + 图表常见模式

- **Figure Contract**：绘图前先定核心结论→证据链→面板映射→评审风险检查
- **完整颜色体系**：语义调色板 PALETTE + 低饱和度 PALETTE_NMI_PASTEL，跨面板统一色系
- **SVG + PNG 双格式输出**：强制 `svg.fonttype='none'` 保持文本可编辑，dpi=300
- **HTML 可视化导航面板**：左侧导航栏 + SVG 渲染 + 导出 + 缩放控制
- **环境检查步骤**：在编码前检查运行时和依赖包，不因环境问题切换语言
- **11种图表常见模式**：分组柱状图、趋势+CI、热力图、气泡图、箱线图等，含代码模板
- **无网格线 / 仅左+下spines / 面板标签规范 / 统计标注规则**

#### 📝 Gloom：论证驱动写作 + 章节架构模式 + 自审框架 + 英文化工作流

- **Argument-first 写作法**：一句话论证模板 + 核心论证要素 + Claim-Evidence 显式映射
- **摘要六要素架构**：context→gap→approach→result→implication→boundary
- **引言五要素架构**：field scale→bottleneck→prior attempts→gap→present study
- **结果证据阶梯**：system→validation→main result→comparison→analysis→application
- **Discussion 架构**：advance→evidence→relation→constraints→future
- **Related Work 主题综合法**（美赛专用）：按技术主题组织，非逐篇罗列
- **四轮自审框架**：论证逻辑→章节结构→表述质量→格式规范，含反方测试
- **英文化工作流**：三阶段转换（理解→写作→校准）+ 动词强度谱系 + 句式转换表
- **段落流检查**：一段一消息三步检查法
- **正式输出格式**：草稿 + 大纲 + 假设 + Claim-Evidence 映射 + 结构说明

#### 📦 其他

- 所有角色文档路径从 `roles/` 迁移至 `references/roles/`
- 新增 `references/roles/Linger/references/建模设计理论.md`
- 新增 `references/roles/Tide/references/可视化面板模板.html`
- 新增 `references/roles/Gloom/references/论文模板.docx`
- 整体 README 和 CLAUDE.md 同步更新

#### 🔬 可视化面板科研化重设计

- **配色升级**：采用项目可视化规范 PALETTE 色系（学术蓝 `#0F4D92` + 金色 `#FFD700` 激活态）
- **新增导出 PNG**：SVG 渲染为高分辨率 PNG（2x DPR）下载
- **图表元信息栏**：Figure 编号 + 描述，模拟论文图表标题格式
- **键盘快捷键**：`Ctrl+=`/`-` 缩放、`Ctrl+E` 导出、`↑↓` 切换、`F11` 全屏
- **Ctrl+滚轮缩放 + 缩放百分比指示器**

#### 🔎 Paper Search 双引擎并行搜索

- **AnySearch Academic 集成**：直接通过 JSON-RPC 2.0 调用 AnySearch API，无需外部依赖
- **混合搜索引擎 `hybrid_scholar.py`**：ThreadPoolExecutor 并行调用 OpenAlex + AnySearch
- **交叉验证机制**：DOI 精确去重 + 标题模糊去重，结果分三区展示（交叉验证 / OpenAlex 独有 / AnySearch 独有）
- **兼容原参数**：支持 `--openalex-only`、`--anysearch-only` 单源模式，JSON 输出
- 新增 `anysearch_academic.py`、`hybrid_scholar.py`，更新 `SKILL.md` 和 README 配置说明

#### 🏆 适配竞赛列表

- 完整列出 6 大适配竞赛（美赛 MCM/ICM、亚太赛 APMCM、国赛 CUMCM、MathorCup、认证杯、数维杯）

### v2.0 (2025-02)

#### ✨ 重大更新：论文AI味去除系统

针对AI生成论文容易被检测工具识别的问题，本次更新在 `references/roles/Gloom/references/写作规范.md` 中加入了完整的**去AI味写作指南**，基于Wikipedia的"Signs of AI writing"研究整理：

**七大类AI痕迹识别与去除：**

1. **内容模式去AI化**

   - 消除"标志着/重要的是/关键作用"等过度强调词汇
   - 去除"独立报道/专家认为"等模糊归因
   - 避免"不仅...而且..."等公式化平行结构
   - 删除"突破性的/令人惊叹的"等广告式宣传语
2. **语言语法规范化**

   - 控制"此外/关键的/深入探讨"等AI高频词汇使用
   - 避免"拥有/具有"等复杂结构替代简单系动词
   - 破除强行分组的"三法则"套路
   - 消除同义词过度替换（"模型/算法/方法/方案"循环）
3. **写作风格真实化**

   - 减少破折号和粗体的过度使用
   - 避免内联标题垂直列表（**准确性：** 95%）
   - 删除表情符号和装饰性元素
   - 用具体数据替代模糊积极结论
4. **数学建模论文专用规范**

   - 禁用"深入探讨/充分展示/具有重要意义"等空泛表达
   - 用"准确率达到95.6%，比基准方法高8.2%"替代"结果令人振奋"
   - 要求每句话都有具体数据或信息支撑
   - 承认复杂性和局限性，注入真实分析思考

**完整自查清单**（Gloom必须遵守）：

- [ ] 是否使用了AI高频词汇？
- [ ] 是否过度使用破折号、粗体？
- [ ] 是否有"不仅...而且..."结构？
- [ ] 是否强行将内容分成三组？
- [ ] 是否有模糊的"专家认为"？
- [ ] 是否有公式化的"挑战与展望"？
- [ ] 每句话是否都有具体数据支撑？

---

#### 🛠️ 新增四个专业子Skill

原 `scripts/` 目录已移除，功能由以下专业子Skill替代：

| 子Skill                  | 功能                      | 使用场景                       |
| ------------------------ | ------------------------- | ------------------------------ |
| 📑`tools/pdf`          | PDF文档读取、文本表格提取 | 读取比赛题目、学习优秀论文     |
| 📊`tools/xlsx`         | Excel表格处理、公式计算   | 处理题目数据、输出结果表格     |
| 📘`tools/docx`         | Word文档生成、模板编辑    | 生成标准格式论文               |
| 🔎`tools/paper_search` | OpenAlex+AnySearch双引擎学术搜索 | 交叉验证式参考文献搜索（需配置邮箱，AnySearch API Key可选） |

**⚠️ Paper Search 配置提醒**：使用 `paper_search skill` 前需配置 OpenAlex 邮箱（必填），AnySearch API Key 可选但建议配置，详见上方【⚙️ 配置说明】部分。

**三角色必须正确使用对应skill：**

- 🧠 **Linger**：使用 `pdf skill` 读题目、`xlsx skill` 分析数据、`paper_search skill` 搜索文献
- 💻 **Tide**：使用 `xlsx skill` 处理Excel数据；普通结果汇总用 CSV，指定 Excel 模板保留结构和公式
- ✍️ **Gloom**：使用 `docx skill` 生成.docx格式论文、使用 `paper_search skill` 交叉验证文献

---

#### 🏆 优秀论文资源库扩充

新增 `references/Outstanding Thesis/` 目录：

**🇨🇳 国赛优秀论文 (CUMCM)** - 9篇

- 🚛 RGV动态调度优化系列（3篇）
- 👥 百货商场会员画像描绘系列（2篇）
- 🚗 汽车总装线配置系列（3篇）
- 🌡️ 高温作业专用服装设计（1篇）

**🌍 美赛O奖论文 (2017MCM ICM)** - 27篇

- 📈 A题连续型（4篇）
- 📊 B题离散型（5篇）
- 💡 C题数据洞察（4篇）
- 🕸️ D题运筹网络（5篇）
- 🌱 E题环境科学（5篇）
- 📋 F题政策分析（4篇）

---

#### 📚 三角色说明文档全面增强

| 角色文档                    | 新增内容                                                                                                        |
| --------------------------- | --------------------------------------------------------------------------------------------------------------- |
| 🧠**Linger说明.md**   | 增加pdf/xlsx/paper_search skill详细使用方法、文献记录要求、算法资源库索引                                       |
| 💻**Tide说明.md**   | 增加xlsx skill公式处理、Python/MATLAB库速查表、SCI/Nature可视化标准                                             |
| ✍️**Gloom说明.md** | **重点增加去AI味写作指南**、docx skill使用教程、图文并茂规范（每张图≥100字分析）、人称约束、叙述方式规范 |

---

#### 🔧 算法文档改进

- ✅ 修正了所有算法文档中的文献引用格式
- 🔎 新增 `paper_search skill` 支持通过OpenAlex API自动搜索学术论文
- 📖 优化了 `assets/README.md` 算法快速索引

---

### 🎉 v1.0 (2025-01)

- 🎊 初始版本发布
- 🔄 基础三阶段工作流程：建模分析 → 代码实现 → 论文撰写
- 📚 7大类60+算法资源库
- 👥 基础角色分工文档

---
