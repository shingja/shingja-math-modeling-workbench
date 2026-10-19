# PARADIGM-0606 感知机⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0606 |
| 类别/子类 | ⑥机器学习 / 线性分类 |
| 难度 | 低 |
| 适用题型关键词[] | 感知机, 线性分类, Rosenblatt, 线性可分, 二分类, 神经网络基础 |
| confidence | high |
| source | Rosenblatt (1958) Psychological Review |

## 数学形式

**模型:**
$$f(\mathbf{x}) = \text{sign}(\mathbf{w}^T\mathbf{x} + b)$$

**损失函数 (误分类点到超平面距离之和):**
$$L(\mathbf{w}, b) = -\sum_{i \in M} y_i(\mathbf{w}^T\mathbf{x}_i + b)$$

其中 $M$ 为误分类点集。

**随机梯度下降更新:**
$$\mathbf{w} \leftarrow \mathbf{w} + \eta \cdot y_i\mathbf{x}_i$$
$$b \leftarrow b + \eta \cdot y_i$$

**收敛定理 (Novikoff, 1962):**
若数据线性可分，感知机在有限步内收敛 (误分类次数 $\leq (R/\gamma)^2$，$R$ 为数据半径，$\gamma$ 为间隔)。

**与逻辑回归的区别:** 感知机用 sign 阈值 (无概率)，逻辑回归用 sigmoid + 对数似然。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| learning_rate (η) | double | 0.01 | (0, 1) | 中 — 影响收敛速度 |
| max_epochs | int | 1000 | [10, 10000] | 低 — 线性可分时自动收敛 |
| 时间复杂度 | — | — | O(n·p·epoch) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[w, b, converged, n_iters] = perceptron(X, y, learning_rate, max_epochs)
```

锚点: 自写-见S5:perceptron.m

```matlab
% 核心迭代
converged = false;
for epoch = 1:max_epochs
    n_errors = 0;
    for i = 1:n
        if y(i) * (w' * X(i,:)' + b) <= 0  % 误分类
            w = w + learning_rate * y(i) * X(i,:)';
            b = b + learning_rate * y(i);
            n_errors = n_errors + 1;
        end
    end
    if n_errors == 0
        converged = true;
        break;
    end
end
```

## Python 备选

```python
from sklearn.linear_model import Perceptron
p = Perceptron(eta0=0.01, max_iter=1000, random_state=42)
p.fit(X_train, y_train)
y_pred = p.predict(X_test)
```

## 选型决策树

- **感知机** — 教学/演示线性可分概念；简单二分类基线
- **逻辑回归 (PARADIGM-0609)** — 需要概率输出和良好校准
- **SVM (PARADIGM-0605)** — 需要最大间隔保证和核方法
- **多层感知机** — 非线性可分问题

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 散点图 (2D) | 类别标注 |
| result | 决策边界直线 + 误分类点标记 | w 的法向量方向 |
| process | 误分类数随 epoch 下降曲线 | 验证收敛 |

## 常见坑

1. **线性不可分 → 永不收敛**: 算法震荡不停止 → 设 max_epochs 并在不收敛时输出 warning
2. **学习率太大 → 震荡**: 学习率太大跳过最优解 → 使用递减学习率: $\eta_t = \eta_0 / (1 + t)$
3. **解不唯一**: 不同于 SVM 的最大间隔解，感知机收敛到哪个超平面取决于初始化和样本顺序

## 失效条件/反例 (强制小节)

- **条件1: 数据集线性不可分 (如 XOR 问题)** → 表现: 算法永远不收敛，epoch 到 max 后仍误分类。感知机无法学习 XOR — 需要隐藏层的多层网络。**应对**: 使用核感知机 (Kernel Perceptron) 或换用多层感知机/核 SVM
- **条件2: 类别重叠严重 (软间隔场景)** → 表现: 即使理论线性可分，噪声样本使决策边界摇摆不定，收敛的 w 对噪声极度敏感，泛化差。**应对**: 使用投票感知机 (Averaged Perceptron) 或直接改用逻辑回归/SVM

## 文献

1. Rosenblatt F. (1958). "The perceptron: A probabilistic model for information storage and organization in the brain." *Psychological Review*, 65(6):386-408. DOI: [10.1037/h0042519](https://doi.org/10.1037/h0042519)
2. Novikoff A.B.J. (1962). "On convergence proofs for perceptrons." *Proceedings of the Symposium on Mathematical Theory of Automata*, 12:615-622.
3. Minsky M. & Papert S. (1969). *Perceptrons*. MIT Press. ISBN: 978-0262631112

## 来源溯源

自写 perceptron.m; 经典机器学习课程

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0605 (SVM) |
| 替代 | PARADIGM-0609 (逻辑回归) |
| 组合 (核化) | PARADIGM-0605 (核SVM) |
