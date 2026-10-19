# PARADIGM-0624 CV集成与提交后处理(WBF/TTA/逐类阈值/Severity)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0624 |
| 类别/子类 | ⑥机器学习 / 计算机视觉·集成与后处理 |
| 难度 | 中 |
| 适用题型关键词[] | 目标检测, 模型集成, 加权框融合, WBF, TTA, 测试时增强, 多尺度推理, 置信度阈值, NMS, 后处理, 提交文件, 黑箱评估, top-k排序, 严重度 |
| confidence | high |
| source | CV 检测实战案例（已匿名化）; Solovyev et al. WBF (2021); 复盘: references/lessons/实战复盘_CV目标检测.md |

## 数学形式

**WBF 加权框融合** (多模型, IoU 阈值 τ=0.55):

1. 按 $c_i w_k$ 降序排序所有模型的预测框 (c=置信度, w=模型权重)
2. 与某簇代表框 $IoU \ge \tau$ → 并入该簇: 簇坐标与得分按 $c \cdot w$ 加权累加
3. 否则新建簇。簇融合框:

$$x = \frac{\sum_i x_i \cdot c_i w_{k(i)}}{\sum_i c_i w_{k(i)}}, \qquad C = \frac{\sum_i c_i \cdot c_i w_{k(i)}}{\sum_i c_i w_{k(i)}}$$

权重取各模型验证集 mAP50 比例（实战例: 多模型按精度层级递减分配）。

**Severity 排序** (竞赛要求"按严重度取 Top-K"):

$$S = c^{\gamma} \cdot A_{norm}, \qquad \gamma = 1.5 \;(\text{网格搜索} [1,2])$$

约束: 每图最多 K 框、每类至少 1 框、按 S 降序输出。

**逐类置信度阈值**: 按类分别标定（低置信类——小目标/少样本——降阈值补召回, 高置信类升阈值压虚警）。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| iou_thr(WBF) | float | 0.55 | 0.5-0.7 | 中 — 比 NMS 更宽容以容纳模型间定位偏差 |
| 模型权重 | list | mAP50 比例 | (0,1] | 中 — ±0.05 扰动覆盖率波动 <0.5pp |
| TTA 尺度 | list | [640, 960] | — | 高 — 小目标增益最大 |
| 逐类阈值 | dict | 按类 | (0,0.5) | 高 — 低置信类阈值（0.10 级）显著影响召回 |
| gamma | float | 1.5 | 1.0-2.0 | 低 — [1.4,1.6] 内排序精度变化 <1% |
| top_k | int | 4 | 赛题规定 | — |

## MATLAB 实现

MATLAB 无现成 WBF → 本卡为 **Python 专属**:

```python
# 实战产物 wbf_utils.py: wbf_fusion(dets_list, weights, iou_thr=0.55)
#   + top4_by_severity(dets, gamma=1.5)  (每类至少1个 + 严重度降序)
# 多尺度 TTA: model(img, imgsz=s, augment=True) for s in [640, 960]
```

## Python 备选

ensemble-boxes 库(WBF/NMS/SoftNMS); ultralytics 内置 augment=True TTA(翻转+多尺度)。

## 选型决策树

- 多模型可用且验证集指标接近 → WBF(信息无损, 优于 NMS 丢弃)
- 单模型 → 只做 TTA + 逐类阈值 + Severity
- 稀有类召回不足 → 降该类阈值(0.10 级) + 专项微调模型加入集成
- 赛题规定 Top-K 输出 → Severity 排序必须显式实现(集合迭代顺序≠排序, 实战 P0 教训)

## 典型图型

- result: 各方案检出框数/覆盖率对比柱状图、F1-置信度曲线(阈值选择依据)、贡献度雷达图、阈值扫描表

## 常见坑

1. "WBF" 写成 concat+按conf排序: 权重加载了没用 = 论文方法名与代码不符(实战 P0-3)
2. Top-K 选择用 set 后直接输出: 顺序随机 → 必须按 Severity 显式降序(实战 P0-4)
3. 阈值/γ 硬编码且扫描结果不参与选择: 写"网格搜索确定"要能被脚本复现(实战 P1: 参数表全硬编码)
4. 提交 CSV 无置信度列时, "按严重度排序"不可验证 → 输出前排序, 别依赖下游

## 失效条件/反例 (强制小节)

- 模型间定位偏差大(训练域差异大): IoU 0.55 聚不上 → 放宽 τ 或退化为 per-model NMS 后合并
- 权重严重偏离验证 mAP50 层级(如 0.10→0.30): 低质框增多 ~15% → 权重必须实证
- 全图无框(阈值全滤): 覆盖率先跌 — 低置信阈值兜底(conf=0.05 预筛, 后置逐类阈值)

## 文献

1. Solovyev R, Wang W, Gabruseva T. Weighted Boxes Fusion[J]. Image and Vision Computing, 2021, 107: 104117.
2. Redmon J, Divvala S, Girshick R, et al. You Only Look Once: Unified, Real-Time Object Detection[C]. IEEE CVPR, 2016: 779-788.

## 来源溯源

实战产物: `wbf_utils.py` / `final_update_all.py` / `best_params.json`（本地留存）

## 关联范式卡

组合: PARADIGM-0623-CV-DET-BASELINE(前置), PARADIGM-0625-CV-FSF-FIM(多样性来源) | 替代: 单模型NMS(无集成条件时)
