# CHANGELOG v3.0.0 — 集百家之长 深度优化⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


> 2026-07-29 | 128/131 MATLAB coverage (97.7%) | 151 paradigm cards | 6 gates

## S1: 基线备份 (2026-07-28)
- 全量备份: `math-modeling.backup-v2.2.1-20260728-131003` (497 files)
- 基线: VERSION=2.2.1, 82 .m files, 89.9% coverage, 0 paradigm cards, 5 gates

## S2: 优化规划
- OPTIMIZATION_PLAN.md (244 lines): D1-D5 decisions + FIX-1/FIX-2 + risk matrix + rollback plan

## S3: 吸收审计
- 7 产出物: absorption_audit.md, dedup_map.json (34 identical pairs), paper_index_skeleton.md (~203 papers), new_algo_candidates.md (16 new algos), crosswalk_D_vs_newalgo.md (0 orphan), audit_b/c/d.md
- LEDGER-1: 10/23 papers upgraded via problem-statement analysis
- 教材源 B: 35 unique chapters, 34 (1).pdf duplicates all SHA-256 identical

## S4: 范式卡建设
- 151 paradigm cards (150 high+medium, 1 low): ①18 ②11 ③11 ④8 ⑤17 ⑥21 ⑦16 ⑧16 ⑨5 ⑩6 ⑪5 ⑫12
- INDEX.md (category + question-type dual view) + keyword_router.json (151 entries)
- tests/manifest.json (151 planned entries)

## S5: MATLAB 覆盖率冲刺
- v2.2.1: 82 .m files → v3.0.0-s5: 150 .m files (+68)
- 7-item validate: 0 pass → 129 pass (86%)
- Coverage: 89.9% → 97.7% (128/131 honest denominator)
- **P0 6 gaps**: PDE FTCS/CN, difference_eq, lemke_howson, inventory_eoq, reliability_weibull/fta
- **P1 3 gaps**: variational_shooting, system_dynamics, topsis_improved
- **New classes**: surrogate (6), robust (5), MCDM (12)
- **Self-test backfill**: ~55 existing files upgraded with %% Self-test
- **P1 low-difficulty** (10): AHP/EWM/outlier/distribution/DT/markov/bootstrap/SEIR/MABAC/PSO/MultiStart
- **P2 mid-difficulty** (16): GM11/ARIMA/GARCH/Prophet/AdaBoost/FP-Growth/SEIRS/SIR-ext/heat2d/chem/neuro/bilevel/DID/Cox/state_space/MANOVA
- **12 final missing** (12): fuzzy_eval/GRA/CRITIC/eps-constraint/MK-trend/Hurst/CA/NSGA3/VAR/reaction-diff/advection-diff/Moran-Kriging
- validate_m_files.py: 7-item static validator

## S6: Tide工程化
- templates/ (11): skeleton.m + 9 type templates + default_cfg.m
- figures/ (24): 20 plot functions + cb_palette + export + audit + style
- utils/ (6): numerical_diagnostics, solver_fallback_chain, seed_sensitivity, vif_check, export_results, apply_publication_style
- tests/property/ (31): 30 invariant tests + run_property_tests runner

## S7: 联合修正闭环
- joint_calibration_protocol.md (~2000 words, 8 sections)
- tools/joint_calibrate.m/.py: 4-component scoring (magnitude/goodness/stability/invariants)
- tools/handshake_validate.m/.py: 7-field completeness check
- tools/result_claim_bind.m/.py: SHA-256 bind/verify
- tools/model_ensemble_select.m/.py: 5-criterion selection
- gates/C1_joint_calibration_check.m: 5-dimension audit gate

## S8: Gloom 2026 规范对齐
- LaTeX template: main_2026.tex, style_2026.sty, 2 pages, 7 sections
- Word structure spec
- W1_writing_check.m (8 dimensions, 11 asserts)
- W2_format_check.m (10 dimensions, 17 asserts)
- generate_paper_numbers.m (JSON→LaTeX newcommand)
- writing_guidelines.md updated: 2026 page structure + S7 binding + MCM/ICM

## S9-10: 触发词/路由 + 版本发布
- SKILL.md: rewritten frontmatter (40+ triggers, negative boundaries)
- Routing table: 12 intent branches
- VERSION → 3.0.0
- CHANGELOG.md updated (Keep a Changelog format)
- README.md updated

## Key Metrics

| Metric | v2.2.1 | v3.0.0 |
|--------|--------|--------|
| Algorithms | 89 | 150+ |
| MATLAB .m files | 82 | 150 |
| MATLAB coverage | 89.9% | 97.7% |
| Paradigm cards | 0 | 151 |
| Gates | 5 | 6 |
| Figure functions | 0 | 24 |
| Property tests | 0 | 31 |
| Templates | 0 | 11 |
| Total .m files (all) | 82 | 222 |
| Validated pass | 0 | 170 |
