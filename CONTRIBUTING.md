# 贡献指南 / Contributing⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


> [中文](#中文) · [English](#english)

---

## 中文

欢迎贡献。为保护项目与使用者，贡献需遵守下面的规则；不满足硬性要求的 PR 会被直接关闭。

### 一、先看这些

| 文档 | 内容 |
|---|---|
| [`LICENSE`](LICENSE) | PolyForm Noncommercial 1.0.0 标准全文：非商业免费（需署名）；商业使用需授权 |
| [`NOTICE.md`](NOTICE.md) | Required Notice 行、署名与溯源要求、名称与背书限制、商用授权说明 |
| [`CLA.md`](CLA.md) | 贡献者许可协议 —— **PR 描述必须包含签署声明行** |
| [`SKILL.md`](SKILL.md) | 项目主指令（先读，理解流程与门禁） |
| [`protocols/README.md`](protocols/README.md) | 协议层索引 |
| [`modules/README.md`](modules/README.md) | 自研模块索引 |

### 二、欢迎的贡献（按接受难度排序）

1. 🐛 **Bug 报告**（issue 模板）—— 最欢迎，附最小复现与版本号
2. 📖 **文档修正**：错别字、断链、表述不清
3. 🧠 **范式卡改进**：补充适用条件、失败案例、参考文献（请用 `references/paradigms/_TEMPLATE.md`）
4. 📐 **协议/模块改进**：门禁规则、检查清单、边界条件
5. 🧪 **测试**：补回归用例、属性测试
6. 🧮 **算法实现**：MATLAB 或 Python 新实现（须带测试，且与既有卡不重复）

### 三、不接受的贡献

- ❌ 任何第三方受版权保护的代码或文本（含从其他 skill 复制的内容）
- ❌ 含个人、队伍、学校、竞赛内部信息的任何内容
- ❌ 当届赛题相关的解答、讨论或数据（赛季内尤其严格）
- ❌ 二进制产物、模型权重、数据集
- ❌ 修改许可条款、移除署名与版权标识的改动
- ❌ 大规模重排目录结构（请先开 issue 讨论）

### 四、提交流程

```bash
# 1. 准备环境（本仓库自带的官方工具需单独获取）
python tools/fetch_official_tools.py          # 拉取 docx/pdf/xlsx 官方工具到 tools/
pip install -r requirements-dev.txt           # 测试依赖

# 2. 改之前先跑一遍基线
python -m unittest discover -s tests -v

# 3. 改动（小步提交，一个 PR 只做一件事）
#    —— 新增 .md/.m/.py 文件后补可见归属行：
python tools/attribution.py --apply

# 4. 提交前自测（六项全绿才能提 PR）
python -m unittest discover -s tests -v       # 全部测试
python tests/test_skill_integrity.py -v       # 版本号与引用一致性
python tests/test_privacy.py -v               # 隐私与身份信息扫描
python tests/test_attribution.py -v           # 归属行完整性
python tools/manifest.py --update             # 更新内容哈希清单（必须随改动提交）
```

改动版本号时，按 [`docs/仓库与发布.md`](docs/仓库与发布.md) 第三节的清单同步全部位置（`test_skill_integrity.py` 会自动校验）。

### 五、PR 要求

- 描述里保留 CLA 签署声明行，并写清：改了什么 / 为什么 / 怎么验证
- 一个 PR 一件事；避免夹带格式化噪音
- 新增或修改行为时同步更新文档与 CHANGELOG 对应条目
- 不接受"仅靠 AI 生成、未经运行验证"的代码；所有数值与效果需可复现

### 六、评审与合并

- 本仓库目前为单人维护，**不承诺响应时间**；一周内未回复可再 ping 一次
- 维护者可能要求拆分或缩小 PR 范围
- 合并后，贡献者会在 git 历史与 Release notes 中署名

### 七、行为准则（简要）

对事不对人；不索要他人身份、队伍或成绩信息；不讨论当届赛题内容；发现隐私泄露立即报告。

---

## English

Thanks for contributing. The rules below protect the project and its users;
PRs that violate the hard requirements will be closed.

### Read first

- [`LICENSE`](LICENSE) — PolyForm Noncommercial 1.0.0 (verbatim): free for non-commercial use with attribution; commercial use requires a license. Additional requirements in [`NOTICE.md`](NOTICE.md).
- [`CLA.md`](CLA.md) — **your PR description must contain the CLA statement line.**
- [`SKILL.md`](SKILL.md) — the master instruction file; read it before changing behaviour.

### Welcome

Bug reports · documentation fixes · paradigm-card improvements · protocol/module
clarifications · regression & property tests · new MATLAB/Python algorithm
implementations (with tests, not duplicating existing cards).

### Not accepted

Third-party copyrighted material (including code copied from other skills) ·
any personal, team, school or competition-internal information · solutions or
discussions of the current competition problems · binary artifacts, weights or
datasets · changes to the license, attribution or provenance markers ·
large structural reshuffles (open an issue first).

### Workflow

```bash
python tools/fetch_official_tools.py     # fetch official docx/pdf/xlsx tools locally
pip install -r requirements-dev.txt

python -m unittest discover -s tests -v  # baseline before you change anything

# after your change: add the visible attribution line
python tools/attribution.py --apply

python -m unittest discover -s tests -v
python tests/test_skill_integrity.py -v
python tests/test_privacy.py -v
python tests/test_attribution.py -v
python tools/manifest.py --update         # refresh the content-hash manifest
```

### Pull requests

One PR = one thing. Describe what/why/how-verified, keep the CLA statement line,
update docs and CHANGELOG where behaviour changes. AI-generated code that has not
been executed and verified is not accepted.

### Review

Single maintainer, no SLA — ping again after a week. PRs may be asked to shrink.
Merged contributions are credited in git history and release notes.

### Code of conduct (short)

Criticise ideas, not people. Never request someone's identity, team or score
information. Do not discuss the current competition problems. Report privacy
leaks immediately.
