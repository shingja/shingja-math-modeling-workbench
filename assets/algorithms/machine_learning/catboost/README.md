# CatBoost Integration v2.2.0⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


## 算法来源

- **论文**: Prokhorenkova, L., Gusev, G., Vorobev, A., Dorogush, A.V., Gulin, A. (2018).
  *CatBoost: unbiased boosting with categorical features.* NeurIPS 2018.
  [arXiv:1706.09516](https://arxiv.org/abs/1706.09516)
- **包**: catboost ≥ 1.2 (Yandex, Apache 2.0 License)
- **收录日期**: 2026-07-27

## 安装

```bash
pip install catboost
```

MATLAB 环境配置:

```matlab
% 在 MATLAB 中配置 Python 环境
pyenv('Version', 'C:\Program Files\Python311\python.exe');  % 替换为实际 Python 路径
```

## 文件说明

| 文件 | 语言 | 用途 |
|------|:--:|------|
| `catboost_train.m` | MATLAB | 通过 pyenv 调用 Python CatBoost 训练 |
| `catboost_predict.m` | MATLAB | 通过 pyenv 调用 Python CatBoost 预测 |
| `catboost_demo.py` | Python | 纯 Python 分类+回归+分类特征示例 |

## 参数速查

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `iterations` | 500 | 树的数量 |
| `learning_rate` | 0.03 | 学习率, 越小越稳健但需要更多 iterations |
| `depth` | 6 | 树深度, 建议 4-10 |
| `l2_leaf_reg` | 3.0 | L2 正则化, 越大越保守 |
| `random_seed` | 42 | 随机种子, 保证可复现 |
| `early_stopping_rounds` | 50 | 早停轮数 |
| `cat_features` | [] | 分类特征索引 (0-based) |

## CatBoost vs XGBoost vs LightGBM

| 特性 | CatBoost | XGBoost | LightGBM |
|------|----------|---------|----------|
| 分类特征处理 | **原生支持, 自动编码** | 需手动 one-hot/label-encode | 需指定 categorical_feature |
| 默认参数 | 调优需求低, 默认效果好 | 需仔细调参 | 需调参 |
| 过拟合抵抗 | **强** (Ordered Boosting) | 中等 | 中等 (叶子数控制) |
| 训练速度 | 中等 | 快 (GPU优) | **最快** (GOSS采样) |
| 小数据表现 | **优秀** | 良好 | 可能过拟合 |
| GPU 支持 | ✅ | ✅ | ✅ |
| 适合场景 | 含大量分类特征/小样本/默认开箱即用 | GPU加速/大规模/精细调参 | 超大数据集/追求训练速度 |

## 竞赛建议

- 国赛数据处理题: CatBoost 为首选 (自动处理分类变量, 默认参数稳健)
- 数据含 ≥30% 分类特征: 优先 CatBoost
- 纯数值特征 + 大数据: 可考虑 LightGBM (更快)
- 需 GPU 训练 + 精细控制: XGBoost

## MATLAB 调用示例

```matlab
% 分类
X = randn(200, 10);
y = double(rand(200, 1) > 0.5);
model = catboost_train(X, y, 'TaskType', 'classification', 'Iterations', 100);
[y_pred, y_prob] = catboost_predict(model, X);

% 回归
y_reg = sum(X.^2, 2);
model = catboost_train(X, y_reg, 'TaskType', 'regression', 'Iterations', 100);
y_pred = catboost_predict(model, X);
```
