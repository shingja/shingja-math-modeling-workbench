# math-modeling v3.0.0 发布说明⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


> 2026-07-29 | 从 82 .m / 89.9% → 222+ 文件 / 97.7% / 6 门禁 + 联合校准闭环

## 核心升级

| 能力 | v2.2.1 | v3.0.0 |
|------|--------|--------|
| 算法库 | 9类89算法 | **12类150+算法** |
| MATLAB覆盖 | 89.9% | **97.7%** |
| 门禁 | 5道 | **6道** (新增C1联合校准) |
| 范式卡 | 0 | **151张** |
| 图表函数 | ~5 | **24 + 出版级样式** |
| 属性测试 | 0 | **31 不变量测试** |
| 题型模板 | 0 | **9 类起手模板** |
| 论文模板 | v2.x (旧) | **2026官方规范对齐** |

## 新能力一览

- **联合校准闭环**: Linger×Tide双向握手 + calibration_score 收敛判定 + C1 门禁
- **结果-主张绑定**: SHA-256 哈希防篡改, `result_claim_bind --verify`
- **多模型选优**: AIC/BIC/CV/calibration 四准则选优
- **出版级可视化**: 24图表函数 + 色觉友好色板 + 300DPI SVG+PNG + figure_audit
- **151 张范式卡**: 数学形式 + 伪代码 + 适用条件 + 失效陷阱
- **触发词升级**: 40+ 中英文触发词 + 负面边界 (纯前端/数据库/翻译不触发)

## 迁移指南

- **旧项目无需迁移**: v2.2.1 文件全部保留于 `*.backup-v2.2.1-*`
- **新项目起步**: `matlab/templates/skeleton.m`
- **论文**: `tools/latex/assets/templates/cumcm/main_2026.tex`
- **查算法**: `references/paradigms/INDEX.md` 或 `keyword_router.json`

## 回滚

```bash
# 删除 v3.0.0 新增目录
rm -rf matlab/templates matlab/figures matlab/utils matlab/tests/property
rm -rf matlab/surrogate matlab/robust matlab/mcdm matlab/comprehensive matlab/evaluation
rm -rf references/paradigms tools/joint_calibrate* tools/handshake_validate* 
rm -rf tools/result_claim_bind* tools/model_ensemble_select* tools/generate_paper_numbers*
rm -rf gates/C1_* gates/W1_* gates/W2_*
# 恢复备份
cp -r math-modeling.backup-v2.2.1-20260728-131003/* math-modeling/
# 恢复版本
echo "2.2.1" > VERSION
```

## 致谢

- 2026 CUMCM 官方规范
- skill-creator 触发词最佳实践
- nature-skills 论文润色能力
