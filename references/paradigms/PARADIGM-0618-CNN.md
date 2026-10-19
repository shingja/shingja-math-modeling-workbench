# PARADIGM-0618 CNN 卷积神经网络⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0618 |
| 类别/子类 | ⑥机器学习 / 深度学习 |
| 难度 | 高 |
| 适用题型关键词[] | CNN, 卷积神经网络, 卷积层, 池化层, 全连接, 特征提取, 图像分类, 图像识别, 深度学习, trainNetwork |
| confidence | high |
| source | LeCun et al. (1998) Proceedings of the IEEE; 培训模块 DL-cnn |

## 数学形式

**CNN 核心层公式**

**卷积层 (Convolutional Layer)**:

输入 $\mathbf{X} \in \mathbb{R}^{H \times W \times C_{in}}$, 卷积核 $\mathbf{K} \in \mathbb{R}^{k_h \times k_w \times C_{in} \times C_{out}}$, 偏置 $\mathbf{b} \in \mathbb{R}^{C_{out}}$:

$$\mathbf{Z}_{i,j,o} = \sum_{m=0}^{k_h-1} \sum_{n=0}^{k_w-1} \sum_{c=0}^{C_{in}-1} \mathbf{X}_{i+m, j+n, c} \cdot \mathbf{K}_{m,n,c,o} + b_o$$

输出尺寸 (valid padding): $H_{out} = \lfloor\frac{H - k_h + 2P}{S}\rfloor + 1$
same padding: $P = \lfloor k/2 \rfloor$, $H_{out} = H/S$

**激活函数 (ReLU)**:
$$\text{ReLU}(z) = \max(0, z), \quad \text{ReLU}'(z) = \begin{cases} 1 & z > 0 \\ 0 & z \leq 0 \end{cases}$$

**池化层 (Pooling Layer)**:

最大池化: $\mathbf{P}_{i,j,c} = \max_{m,n \in R_{i,j}} \mathbf{X}_{m,n,c}$

平均池化: $\mathbf{P}_{i,j,c} = \frac{1}{|R_{i,j}|} \sum_{m,n \in R_{i,j}} \mathbf{X}_{m,n,c}$

输出尺寸: $H_{out} = \lfloor\frac{H - p_h}{S_p}\rfloor + 1$

**全连接层**:
$$\mathbf{z} = \mathbf{W} \cdot \mathbf{x} + \mathbf{b}$$

**Softmax 分类层**:
$$\hat{y}_k = \frac{e^{z_k}}{\sum_{j=1}^{K} e^{z_j}}$$

**交叉熵损失 (Cross-Entropy Loss)**:
$$\mathcal{L} = -\frac{1}{N} \sum_{i=1}^{N} \sum_{k=1}^{K} y_{ik} \log(\hat{y}_{ik})$$

**Adam 优化器**:
$$\hat{m}_t = \frac{m_t}{1 - \beta_1^t}, \quad \hat{v}_t = \frac{v_t}{1 - \beta_2^t}$$
$$\theta_{t+1} = \theta_t - \eta \cdot \frac{\hat{m}_t}{\sqrt{\hat{v}_t} + \epsilon}$$

**Batch Normalization**:
$$\hat{x}_i = \frac{x_i - \mu_B}{\sqrt{\sigma_B^2 + \epsilon}}, \quad y_i = \gamma \hat{x}_i + \beta$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| filter_size | int | 3 | [1, 11] | 中 — 3x3 为标准; 大核 (7x7) 用于首层 |
| num_filters | int | 32 | [8, 2048] | 高 — 每层倍增 (32rarr;64rarr;128) 是通用策略 |
| pool_size | int | 2 | [2, 4] | 低 — 2x2 stride=2 为标准配置 |
| learning_rate | float | 0.001 | [1e-5, 0.1] | 极高 — 过大震荡不收敛, 过小收敛极慢 |
| mini_batch_size | int | 32 | [8, 512] | 中 — 影响梯度估计方差和 GPU 利用率 |
| max_epochs | int | 30 | [5, 300] | 中 — 配合 early stopping 使用 |
| L2_regularization | float | 0.0001 | [0, 0.1] | 中 — 防全连接层过拟合 |
| dropout_p | float | 0.5 | [0, 0.9] | 高 — 0.5 是全连接层最常用设置 |

| 输出 | 量纲 |
|------|------|
| class_labels | 类别标签 (1 to K) |
| softmax_scores | Kx1 概率向量, sum=1 |
| activations (中间层) | HxWxC 张量 (可视化用) |

**计算复杂度**: 前向/反向传播各约 $O(\sum_l k_l^2 \cdot C_{l-1} \cdot C_l \cdot H_l \cdot W_l)$ FLOPs。典型 ResNet-18 约 1.8 GFLOPs/样本。

## MATLAB 实现

**函数签名** (Deep Learning Toolbox):

```matlab
% 自定义 CNN 架构
layers = [
    imageInputLayer([64 64 3], 'Name', 'input', 'Normalization', 'zscore')
    
    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv1')
    batchNormalizationLayer('Name', 'bn1')
    reluLayer('Name', 'relu1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
    
    convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv2')
    batchNormalizationLayer('Name', 'bn2')
    reluLayer('Name', 'relu2')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')
    
    convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv3')
    batchNormalizationLayer('Name', 'bn3')
    reluLayer('Name', 'relu3')
    
    fullyConnectedLayer(128, 'Name', 'fc1')
    dropoutLayer(0.5, 'Name', 'dropout')
    fullyConnectedLayer(num_classes, 'Name', 'fc_out')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'output')
];

% 查看网络结构
analyzeNetwork(layers);

% 训练选项
options = trainingOptions('adam', ...
    'InitialLearnRate', 0.001, ...
    'MaxEpochs', 30, ...
    'MiniBatchSize', 32, ...
    'ValidationData', {X_val, Y_val}, ...
    'ValidationFrequency', 30, ...
    'Plots', 'training-progress', ...
    'Shuffle', 'every-epoch', ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 10);

% 训练
net = trainNetwork(X_train, Y_train, layers, options);

% 预测
[Y_pred, scores] = classify(net, X_test);

% 迁移学习 (使用预训练网络)
net_pretrained = googlenet;  % 或 resnet50, squeezenet
lgraph = layerGraph(net_pretrained);
lgraph = replaceLayer(lgraph, 'loss3-classifier', ...
    fullyConnectedLayer(num_classes, 'Name', 'fc_new'));
lgraph = replaceLayer(lgraph, 'output', ...
    classificationLayer('Name', 'output'));
options_transfer = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.0001, 'MaxEpochs', 10);
net_transfer = trainNetwork(X_train, Y_train, lgraph, options_transfer);

% 特征图可视化
act = activations(net, X_test(:,:,:,1), 'conv3');
figure; montage(mat2gray(act(:,:,1:16)));
```

**锚点工具箱函数**: `convolution2dLayer`, `trainNetwork`, `classify`, `activations` (Deep Learning Toolbox). 预训练网络: `googlenet`, `resnet50`, `squeezenet` (需 support packages).

## Python 备选

```python
import tensorflow as tf
from tensorflow.keras import layers, models

model = models.Sequential([
    layers.Input(shape=(64, 64, 3)),
    
    layers.Conv2D(32, (3, 3), padding='same', activation='relu'),
    layers.BatchNormalization(),
    layers.MaxPooling2D((2, 2)),
    
    layers.Conv2D(64, (3, 3), padding='same', activation='relu'),
    layers.BatchNormalization(),
    layers.MaxPooling2D((2, 2)),
    
    layers.Conv2D(128, (3, 3), padding='same', activation='relu'),
    layers.BatchNormalization(),
    
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.5),
    layers.Dense(num_classes, activation='softmax')
])

model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])
history = model.fit(X_train, y_train, 
                    validation_data=(X_val, y_val),
                    epochs=30, batch_size=32)
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 图像分类/识别 | CNN (自建或迁移学习) | CNN 是图像处理的"标准答案" |
| 样本量 n < 1000 (小样本) | 迁移学习 (ResNet-50) | 预训练特征 + 仅微调顶层 |
| 样本量 n > 50000 (大样本) | 从头训练 | 数据足够支撑全参数学习 |
| 输入为表格数据 (非网格) | 不适合 | CNN 前提是空间局部相关性; MLP/树模型更合适 |
| 时序信号 (1D 序列) | 1D-CNN | 用 conv1dLayer 替代 conv2dLayer |
| 图像分割 | U-Net / FCN | 全卷积网络 + 跳跃连接 |
| 轻量化部署 (移动端) | MobileNet / SqueezeNet | 深度可分离卷积大幅减少参数 |
| 可解释性要求高 | CNN + Grad-CAM | 但 CNN 仍是黑箱; 可考虑决策树 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 各类别样本 montage | 显示每类 5-10 个典型样本 |
| process | 网络结构图 | analyzeNetwork(layers) 自动生成 |
| process | 训练曲线 (Loss+Accuracy vs Epoch) | 双 y 轴, 训练/验证分开 |
| process | 特征图可视化 | 各卷积层输出前 N 个最活跃 feature maps |
| result | 混淆矩阵 | heatmap 标注查准率/查全率 |
| result | Grad-CAM 热力图 | 输入图像叠加重要区域的 heatmap |
| result | t-SNE 特征分布 | 全连接层输出在 2D 空间的可分离性 |

## 常见坑

1. **小样本过拟合**: 参数量百万级的 CNN 在小样本上记忆训练集而非学到泛化模式。$\to$ 使用迁移学习 + 数据增强 + 强 Dropout/L2 正则化。
2. **输入尺寸不匹配**: 预训练网络有固定输入尺寸 (ResNet-50: 224x224x3)。$\to$ 统一 resize, 保持宽高比或直接拉伸。
3. **梯度消失**: 极深网络底层梯度几乎为 0。$\to$ Batch Normalization + 残差连接 + ReLU (而非 sigmoid/tanh)。
4. **学习率过大**: CNN 对学习率敏感。$\to$ piecewise schedule: 每 N 个 epoch 衰减 0.1, 或使用 Adam 自适应。
5. **类别不平衡**: 若多数类主导, softmax 偏向多数类。$\to$ class weights 加权损失、过采样少数类、focal loss。
6. **图像预处理不一致**: 训练/测试时用不同的 Normalization 参数 (mu/sigma 应仅从训练集计算) $\to$ 测试性能显著差于训练。

## 失效条件/反例 (强制小节)

- **条件1: 样本量 n < 1000 且无法使用迁移学习** $\to$ **表现**: 经典 CNN 参数量 $10^5 \sim 10^7$。当 n < 1000, 样本-参数比 < 0.01, 训练集准确率快速逼近 100%, 验证集准确率在随机水平附近 (严重过拟合)。数据增强可增加等效样本量 10-100 倍但仍有上限。**应对**: (1) 优先迁移学习 $\to$ 冻结卷积基, 仅训练最后 1-2 个全连接层 (参数量降至 $10^3 \sim 10^4$); (2) 若非自然图像领域 (医学影像/遥感) 无法迁移, 使用轻量架构 (SqueezeNet, < 1M 参数) + 强数据增强; (3) 考虑放弃 CNN, 转向传统 CV 特征 (HOG/SIFT) + SVM, 小样本泛化更好。

- **条件2: 输入为非网格结构化数据 (tabular data, 表格数据)** $\to$ **表现**: CNN 的归纳偏置是平移不变性和局部感受野 $\to$ 基于空间/时间邻域结构。表格数据的特征列排列是任意的, 第 3 列和第 7 列没有"相邻"的物理意义。将表格 reshape 成 2D 网格后训练 CNN, 卷积核在无意义邻域上计算, 结果不优于 MLP, 且训练成本更高。**应对**: 使用 MLP、XGBoost/LightGBM、或随机森林 (PARADIGM-0601)。若必须用神经网络, 使用 featureInputLayer + fullyConnectedLayer 构建 MLP。

- **条件3: 类别严重不平衡 (最大类:最小类 > 50:1) 且使用标准交叉熵损失** $\to$ **表现**: 交叉熵损失对每个样本等权, 多数类主导梯度。模型学到"全部预测为多数类"即获低损失, 少数类 recall 趋近于 0。training accuracy 很高造成误导。**应对**: (1) classificationLayer 中使用 ClassWeights 参数增加少数类代价; (2) 过采样少数类 + 欠采样多数类; (3) 使用 Focal Loss 替代交叉熵; (4) 评估时使用 balanced accuracy 或 macro-F1。

## 文献

1. LeCun Y, Bottou L, Bengio Y, Haffner P (1998). "Gradient-based learning applied to document recognition." *Proceedings of the IEEE*, 86(11):2278-2324. DOI: [10.1109/5.726791](https://doi.org/10.1109/5.726791)
2. Krizhevsky A, Sutskever I, Hinton GE (2012). "ImageNet classification with deep convolutional neural networks." *NeurIPS*, 25:1097-1105.
3. He K, Zhang X, Ren S, Sun J (2016). "Deep residual learning for image recognition." *CVPR*, pp. 770-778. DOI: [10.1109/CVPR.2016.90](https://doi.org/10.1109/CVPR.2016.90)
4. Goodfellow I, Bengio Y, Courville A (2016). *Deep Learning.* MIT Press. ISBN: 978-0262035613

## 来源溯源

培训模块 DL-cnn; LeCun et al. (1998); MATLAB Deep Learning Toolbox 文档.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0601 (随机森林, 表格数据分类/回归) |
| 替代 | PARADIGM-0204 (LSTM, 时序序列分类与特征提取) |
| 组合 | PARADIGM-0504 (PCA, CNN 特征图的降维可视化) |
| 前置 | PARADIGM-0501 (数据预处理, 图像归一化/增强) |
