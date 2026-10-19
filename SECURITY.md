# 安全策略 / Security Policy⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


## 支持的版本

只有**最新发布版本**（当前公开版本 `1.0.0`）接受安全修复。

## 报告安全问题

**走私密报告**：[新建 Security Advisory](https://github.com/shingja/shingja-math-modeling-workbench/security/advisories/new)
（不要在公开 issue 里贴细节）。

请包含：受影响文件与版本、复现步骤、影响范围、可能的修复方向。
**不承诺响应时限**（单人维护），但会尽快确认收到。

## 属于安全问题的情况

| 类型 | 例子 |
|---|---|
| 版权标识被破坏 | 归属行或版权标识被移除、篡改、伪造的版本流传 |
| 隐私泄露 | 仓库内出现个人/队伍/学校信息，或 issue/PR 中出现他人隐私 |
| 代码执行风险 | `tools/`、`gates/`、`references/roles/*/scripts/` 中的脚本存在命令注入、路径穿越、任意写入 |
| 依赖风险 | `requirements-dev.txt` 引入被投毒或已撤回的包 |
| CI 风险 | 工作流可被 PR 提权、读取 secrets、修改自身 |
| 供应链 | 官方工具获取脚本 `tools/fetch_official_tools.py` 拉取到非预期内容 |

## 不属于安全问题（请走普通 issue）

赛题相关请求、安装问题、功能建议、成绩咨询。

## 本项目已采取的安全设计

- **不内嵌第三方代码**：`tools/docx|pdf|xlsx` 由使用者用 `tools/fetch_official_tools.py` 自行获取，仓库本身不含外部代码。
- **CI 最小权限**：workflow 级 `permissions: contents: read`，action 按 commit SHA 固定，checkout 不保留凭据。
- **提交与标签签名**：全部提交与 tag 使用 SSH 签名，GitHub 显示 Verified。
- **版权与防篡改**：源文件带可见归属行与版权标识；发布包附逐文件 SHA-256 清单，可用 `tools/manifest.py --verify` 校验。具体校验与取证方法不在公开文档披露。
- **隐私回归测试**：`tests/test_privacy.py` 阻止个人路径、私人邮箱、手机号与第三方目录进入仓库。
- **无 secrets 依赖**：核心流程不需要任何 API key；`ANYSEARCH_API_KEY` 等仅为可选增强，且只从环境变量读取。

## 给使用者的提醒

Agent Skill 会**读取并执行本仓库中的脚本**。使用前请：

1. 通读 `SKILL.md` 与你要用到的 `tools/`、`gates/` 脚本；
2. 校验内容完整性：`python tools/manifest.py --verify`；
3. 确认来源是本仓库（`shingja/shingja-math-modeling-workbench`）——第三方转载版本可能被改动过；
4. 在隔离目录里先跑一次，再用于正式题目。

## 已知的、我们不承诺保护的情况

- fork 是 GitHub 服务条款允许的行为；我们只能通过许可条款、版权标识与仓库时间戳追溯，不能阻止 fork。
- 截图、OCR、重排文字后的复制可能丢失部分版权标识；此时以可见归属行、许可条款与仓库时间戳为准。
