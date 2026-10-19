<!--
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->

提交前请确认以下自测全绿：
  python -m unittest discover -s tests -p "test_*.py" -v
  python tests/test_skill_integrity.py -v
  python tests/test_privacy.py -v
  python tests/test_attribution.py -v
  python tools/manifest.py --verify
-->

## 改了什么⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

<!-- 一句话说明；一个 PR 只做一件事 -->

## 为什么

<!-- 关联 issue 号；说明场景或缺陷 -->

## 怎么验证

<!-- 运行的命令 + 关键输出；涉及数值请给出来源 -->

## 自查清单

- [ ] 自测全绿（上方命令）
- [ ] 新增 `.md`/`.m`/`.py` 文件已跑 `python tools/attribution.py --apply`
- [ ] 已运行 `python tools/manifest.py --update` 并随改动提交清单
- [ ] 不含任何第三方受版权保护的内容（未从其他 skill / 论文 / 网站复制正文）
- [ ] 不含个人、队伍、学校、竞赛内部信息
- [ ] 未移除或篡改署名、许可与归属标识
- [ ] 涉及行为变更时，已同步更新文档与 `CHANGELOG.md`

## CLA 签署（必填，未填写不予合并）

```
I have read and agree to the CLA (CLA.md).
Contributor: <你的 GitHub 用户名>
Date: <YYYY-MM-DD>
```
