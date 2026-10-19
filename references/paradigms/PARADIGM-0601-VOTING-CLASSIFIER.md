# PARADIGM-0601 投票集成分类器 (Voting Classifier Ensemble)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0601 |
| 类别/子类 | ⑥ML / 集成学习 |
| 难度 | 中 |
| 适用题型关键词[] | 集成分类, 软投票, VotingClassifier, 异质分类器, 随机森林, 梯度提升, AdaBoost, 逻辑回归, LightGBM, 分类鉴定, 特征重要性 |
| confidence | high |
| source | T02 古代玻璃成分分析 (2022国赛C题) 实战验证; Hastie (2009) ESL §16 |

## 核心约定

**5异质基分类器软投票**: LR + RF + GB + AdaBoost + LGBM → 概率平均, 准确率 > 任何单一模型

## 数学形式

软投票: $\hat{y} = \arg\max_k \sum_{j=1}^{M} w_j \cdot P_j(y=k|x)$

其中 $P_j$ 为第 $j$ 个分类器的类别概率, $w_j$ 为权重(默认均等)

## 数据处理Pipeline

1. StandardScaler标准化 → 各维零均值单位方差
2. RandomOverSampler过采样 → 类别平衡
3. 缺失值: 检出限/2 → 保守填充
4. 5-fold CV → 评估泛化能力

## 基分类器配置

| 分类器 | 关键参数 | 特点 |
|------|------|------|
| LogisticRegression | C=10, lbfgs | 线性基线, 可解释 |
| RandomForest | n=200, depth=10 | 非线性, 特征重要性 |
| GradientBoosting | n=100, lr=0.2 | 串行提升, 偏差修正 |
| AdaBoost | n=100, lr=0.1 | 自适应权重 |
| LightGBM | n=100, lr=0.2 | 高效梯度提升 |

## 常见陷阱

1. **单一分类器**: 1个模型不如5个集成
2. **类别不平衡**: 未采样 → 多数类主导
3. **过拟合**: 小样本(如17个) 5个模型仍可100%

## MATLAB锚点

`TreeBagger` (RF), `fitcsvm` (SVM), 自定义投票
