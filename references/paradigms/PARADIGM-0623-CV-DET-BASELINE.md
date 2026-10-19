# PARADIGM-0623 CV目标检测基线+分阶段延训⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0623 |
| 类别/子类 | ⑥机器学习 / 计算机视觉·目标检测 |
| 难度 | 中 |
| 适用题型关键词[] | 计算机视觉, 目标检测, YOLO, 图像识别, 缺陷检测, 损伤检测, 目标定位, 边界框, mAP, 图像分类, 深度学习竞赛, 数据集标注, ultralytics |
| confidence | high |
| source | CV 检测实战案例（已匿名化）; Ultralytics YOLOv8 (Jocher et al. 2023); 复盘: references/lessons/实战复盘_CV目标检测.md |

## 数学形式

**YOLOv8 损失** (三加权项):

$$\mathcal{L} = \lambda_{box} \mathcal{L}_{CIoU} + \lambda_{cls} \mathcal{L}_{BCE} + \lambda_{dfl} \mathcal{L}_{DFL}, \quad \lambda_{box}{=}7.5, \lambda_{cls}{=}0.5, \lambda_{dfl}{=}1.5$$

**CIoU** (Complete IoU, Zheng 2020):

$$\mathcal{L}_{CIoU} = 1 - IoU + \frac{\rho^2(b, b^{gt})}{c^2} + \alpha v, \quad v = \frac{4}{\pi^2}\left(\arctan\frac{w^{gt}}{h^{gt}} - \arctan\frac{w}{h}\right)^2$$

**mAP@0.5:0.95**: IoU 阈值 0.5~0.95 步长 0.05 的 AP 均值; mAP50 测粗定位, mAP50-95 测精定位(小目标题目尤其严苛)。

**分阶段学习率衰减延训** (实战最大单一增益, 相对 +52%):

- 阶段一(初训): lr=0.001, AdamW(β₁=0.937, β₂=0.999), cos_lr, warmup 5ep, 30ep → 快速逼近
- 阶段二(延训): lr=0.0005(50%), patience 50, resume 续训 → 精细收敛; 诊断依据: 30ep 处 loss 仍在下降 + mAP 无平台 = 未收敛

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| epochs | int | 30→200 | 30-300 | 极高 — 实战 30→200ep: mAP50 相对 +52% |
| lr0 | float | 0.001 / 0.0005 | 1e-4~1e-2 | 高 — 延训期必须降半 |
| imgsz | int | 640 | 640/960/1280 | 高 — 960 TTA 覆盖率+~1pp; 1280 需 6GB+ 显存 |
| batch | int | 8 (4GB VRAM) | 4-64 | 中 — 受显存硬约束 |
| box/cls/dfl | float | 7.5/0.5/1.5 | — | 低 |
| seed | int | 42 | 任意 | 中 — 复现必需 |
| 模型规模 | — | YOLOv8n 3.0M/8.1GFLOPs | n/s/m | 高 — 4GB 显存只能用 n/s |

## MATLAB 实现

MATLAB 无原生 YOLOv8 训练器 → 本卡为 **Python 专属** (ultralytics):

```python
from ultralytics import YOLO
model = YOLO("yolov8n.pt")
model.train(data="data.yaml", epochs=200, imgsz=640, batch=8,
            device="cuda:0" if torch.cuda.is_available() else "cpu",
            optimizer="AdamW", lr0=0.0005, lrf=0.005, cos_lr=True,
            warmup_epochs=5, patience=50, box=7.5, cls=0.5, dfl=1.5,
            close_mosaic=15, seed=42)
# 延训: 从 best.pt 加载后同样配置续训; 或 resume=True 从 last.pt
```

## Python 备选

ultralytics (YOLOv8/YOLO11); 备选 mmdetection (Faster R-CNN 两阶段, 精度略高速度慢); detectron2。

## 选型决策树

- 硬件 ≥8GB 显存 → YOLOv8s/m + 1280 分辨率
- 硬件 4GB → YOLOv8n + 640, 靠延训+集成补性能 ("充分训练小模型 > 浅度训练大模型")
- 小目标占比高(>50% <1% 面积) → P2 检测头(yolov8n-p2.yaml)或 960+ TTA
- 需要分割 → YOLOv8-seg; 需要分类 → 本卡基线检测结果推导(见 0624/复盘§三)

## 典型图型

- raw: 训练集类别分布柱状图+饼图、bbox 面积/宽高比分箱
- process: epoch 曲线(mAP50/mAP50-95、三项 loss)、验证集 PR 曲线、混淆矩阵
- result: 检测框可视化(val_batch_pred/labels 对照)、模型对比柱状图

## 常见坑

1. 训练不足即停: 看曲线——loss 未平台、mAP 未回落就延训(实战: 短训基线明显欠拟合)
2. 论文叙事与 args.yaml 不符: 写"两阶段 lr"必须与训练配置逐字段一致(实战审计 P1-3)
3. 路径硬编码绝对盘符: 换机器/迁移目录即失效 → ROOT=__file__ 相对布局
4. amp 在旧卡不可用 → amp=False 显式声明
5. 训练 CSV 是部分 epoch(如 160/200): 引用"最佳 epoch"必须以完整 results.csv 为准

## 失效条件/反例 (强制小节)

- 训练集无负样本: 二分类不可直接训练 → 检测推导法或外部负样本(复盘§三)
- 类别极端不平衡(稀有类占比很低且全为微小目标): 标准损失下稀有类梯度贡献不足 → 逐类阈值+专项微调(0624 卡)
- 目标面积跨 4 个数量级: 单一尺度检测头小目标漏检 → P2 头/多尺度 TTA

## 文献

1. Jocher G, Chaurasia A, Qiu J. Ultralytics YOLOv8[EB/OL]. https://github.com/ultralytics/ultralytics, 2023.
2. Zheng Z, Wang P, Liu W, et al. Distance-IoU Loss: Faster and Better Learning for Bounding Box Regression[C]. AAAI, 2020: 12993-13000.

## 来源溯源

实战产物: train_yolov8n_extend.py / train_yolov8s.py 等（本地留存）

## 关联范式卡

组合: PARADIGM-0624-CV-ENSEMBLE(集成后处理), PARADIGM-0625-CV-FSF-FIM(架构增强), PARADIGM-0622(数据关联分析) | 前置: PARADIGM-0618-CNN(卷积网络基础)
