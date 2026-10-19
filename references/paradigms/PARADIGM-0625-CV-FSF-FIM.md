# PARADIGM-0625 CV频域-边缘架构增强(FSF/FIM)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0625 |
| 类别/子类 | ⑥机器学习 / 计算机视觉·架构增强 |
| 难度 | 高 |
| 适用题型关键词[] | 频域融合, FSF, 傅里叶变换, FFT, 边缘检测, Sobel, 物理先验, 小目标检测, 特征增强, 注意力机制, 结构先验, 缺陷边界, YOLO颈部, 可学习频率掩码 |
| confidence | medium |
| source | PPFS-YOLO (Sensors 2026, 26(10), 3224) 独立重写 + CV 实战验证; 复盘: references/lessons/实战复盘_CV目标检测.md |

## 数学形式

**FSF 频域-空间融合** (注入检测颈部, 每尺度四步):

1. RFFT2: $\hat{F} = \mathcal{F}_r(F)$ — 实信号共轭对称, 频谱压缩至 H×(W/2+1)
2. 可学习逐通道频率掩码: $M_c = \sigma(\theta_c)$, 初始 $\sigma(1) \approx 0.73$
3. IRFFT2: $\tilde{F} = \mathcal{F}_r^{-1}(\hat{F} \odot M)$
4. 门控残差融合: $F_{out} = F + r \cdot G(F, \tilde{F})$, 门控 8x 压缩瓶颈, 初始残差缩放 r=0.1

参数极省: P3/P4/P5 三层掩码合计 448 标量; FSF 总参数约 135K(≈总参数 4.3%)。

**FIM 边缘引导监督** (物理先验):

$$G = \sqrt{(K_x * I)^2 + (K_y * I)^2}, \quad L_{phy} = \sum |E_{pred} - G| \odot w_{mask}, \quad w_{mask} = \begin{cases} 2.0 & G > 0.1 \\ 0.1 & G \le 0.1 \end{cases}$$

强边缘 2x / 弱边缘 0.1x 非均匀加权 — 引导模型学结构性损伤边界而非背景纹理。Sobel 核固定不参与梯度(纯物理先验)。

**动机**: 空间域下采样丢高频细节; 尖锐边界类损伤 = 频域高频能量, 弥散纹理类 = 中频环带, 正常表面 = DC 低频 — 频域先验可显式注入。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 注入位置 | — | 颈部 P3/P4/P5 | — | 高 — 注入骨干会破坏预训练权重加载 |
| 门控压缩比 | int | 8 | 4-16 | 低 |
| 初始残差缩放 r | float | 0.1 | 0.05-0.2 | 中 |
| 掩码初始化 | float | θ=1(σ≈0.73) | — | 中 |
| 边缘阈值 | float | 0.1 | — | 低 |
| 强/弱权重 | float | 2.0/0.1 | — | 低 |

## MATLAB 实现

MATLAB 无 YOLO 训练框架 → **Python 专属** (实战产物):

```python
# fsf_module.py: FrequencySpatialFusion(channels) — RFFT2→掩码→IRFFT2→门控
# fim_module.py: SobelEdgeExtractor / PhysicsPriorLoss (2x/0.1x 加权 L1)
# 注册进 ultralytics: inject_ppfs.py → tasks.FSFBlock = FSFBlock
# 训练: train_ppfs_yolo.py (yolov8n-ppfs.yaml, 120ep, lr0=0.001)
```

## Python 备选

torch.fft.rfft2/irfft2 原生实现; 备选注意力(SE/CBAM)无频域先验; FcaNet 频域通道注意力(相关文献)。

## 选型决策树

- 小目标占比 >50%(<1% 面积) 且边界清晰(机械缺陷类) → FSF 值得试
- 纹理弥散类目标(锈蚀/污渍) → 频域中频掩码 + FIM 弱监督, 增益有限(实战: 稀有类仍是瓶颈)
- 无 GPU 增量预算 → 只用延训+集成(0623/0624), FSF 是加分项非保底项
- 文献无代码时: 独立重写 + 参数/性能差异显式披露（与原文的参数量/性能差距逐项说明）

## 典型图型

- process: 频域能量分布示意(高频=结构边界/中频=弥散纹理/低频=背景), 边缘图 vs Sobel 先验对照
- result: 有无 FSF 的 PR 曲线对比, 小目标 AP 提升柱状图

## 常见坑

1. 论文声称 L_phy 入 loss 但训练脚本只有 box/cls/dfl 三项: 未集成必须写进局限性(实战诚实披露范例)
2. 自定义模块未注册进 ultralytics 就 torch.load → 反序列化失败: inject 后再加载权重
3. FSF 掩码写成 (H,W/2+1) 空间掩码但实现是逐通道标量: docstring 与实现不符会被审计抓
4. 预训练权重与自定义 YAML 不匹配 → 只加载公共层, FSF 层随机初始化(paper 必须写明)

## 失效条件/反例 (强制小节)

- 数据集无清晰边界特征(纯纹理分类): 频域先验增益≈0
- 骨干过小(YOLOv8n 3M): FSF 独立训练后 mAP 低于延训基线 — 架构增强收益 < 训练充分性收益(实战实证)
- 训练资源受限(BS=8/FP32): 与原论文(RTX3090×4/BS=64/AMP)的 +12.10pp 不可比, 必须按"注入方式/骨干/资源"三维度披露差异

## 文献

1. PPFS-YOLO: Frequency-Spatial Fusion for Port Container Damage Detection[J]. Sensors, 2026, 26(10): 3224.
2. Dosovitskiy A, et al. An Image is Worth 16x16 Words: Transformers for Image Recognition[C]. ICLR, 2021.

## 来源溯源

实战产物: `fsf_module.py` / `fim_module.py` / `inject_ppfs.py` / `yolov8n-ppfs.yaml`（本地留存）

## 关联范式卡

组合: PARADIGM-0623-CV-DET-BASELINE(宿主架构), PARADIGM-0624-CV-ENSEMBLE(作为多样性来源) | 前置: PARADIGM-0618-CNN
