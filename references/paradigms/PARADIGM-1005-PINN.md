# PARADIGM-1005-PINN 物理信息神经网络⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1005-PINN |
| 类别/子类 | ⑩代理模型 / 物理融合 |
| 难度 | 高 |
| 适用题型关键词[] | PDE求解, 物理约束, 逆问题, 数据同化, 连续时间模型 |
| confidence | medium |
| source | 论文2019_PINN / 题解反推_PhysicsML类 |

## 数学形式

**核心思想**: 将物理定律 (PDE/ODE) 作为正则化项嵌入神经网络损失函数。

对于 PDE: $\mathcal{N}[u](x, t) = 0$ (微分算子作用), 边界条件 $\mathcal{B}[u](x, t) = 0$, 初始条件 $u(x, 0) = g(x)$:

$$\mathcal{L}_{\text{total}} = \mathcal{L}_{\text{data}} + \mathcal{L}_{\text{physics}} + \mathcal{L}_{\text{boundary}}$$

$$\mathcal{L}_{\text{data}} = \frac{1}{N_d} \sum_{i=1}^{N_d} |u_{\text{NN}}(x_d^i, t_d^i) - u_{\text{obs}}^i|^2$$

$$\mathcal{L}_{\text{physics}} = \frac{1}{N_f} \sum_{j=1}^{N_f} |\mathcal{N}[u_{\text{NN}}](x_f^j, t_f^j)|^2$$

$$\mathcal{L}_{\text{boundary}} = \frac{1}{N_b} \sum_{k=1}^{N_b} |\mathcal{B}[u_{\text{NN}}](x_b^k, t_b^k)|^2$$

**自动微分**: 使用 Autodiff 计算 $\frac{\partial u_{\text{NN}}}{\partial t}, \frac{\partial^2 u_{\text{NN}}}{\partial x^2}$ 等微分算子。

| 变量 | 含义 |
|------|------|
| $N_d$ | 观测数据点 (可选) |
| $N_f$ | 配点 (collocation points) |
| $N_b$ | 边界/初始配点 |
| $\mathcal{N}$ | PDE 微分算子 |
| $u_{\text{NN}}$ | 神经网络近似 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 网络深度 | int | 4-8 | 2-20 | 高—深则易训练难, 浅则表达不足 |
| 每层宽度 | int | 20-50 | 10-200 | 中 |
| $N_f$ (配点数) | int | 10000 | 1000-50000 | 高—覆盖不足则 PDE 约束弱 |
| $\lambda_{\text{physics}}$ | float | 1.0 | 0.1-10 | 高—平衡数据项和物理项 |
| 优化器 | enum | Adam+L-BFGS | Adam/SGD/L-BFGS | 中—L-BFGS 二阶加速关键 |
| 激活函数 | enum | tanh | tanh/sin/swish | 中—需至少 2 阶可导 |

**时间复杂度**: 单次迭代 $O(N_f \cdot (\#\text{layers} \cdot \text{width}^2))$
**训练时间**: 几分钟到几小时, 取决于 PDE 复杂度和配点数

## MATLAB 实现

```matlab
% PINN 实现 (Deep Learning Toolbox 可选)
% Python备选-见S5

% MATLAB 方案: 用 trainNetwork + 自定义损失层
% 或利用 dlarray + dlgradient 手动实现 Autodiff + 训练循环
% 但 MATLAB 的 Autodiff 生态不如 PyTorch/TensorFlow 成熟
% 推荐: Python (PyTorch/TensorFlow) 实现 PINN
```

**推荐策略**: **Python备选-见S5** (PyTorch 或 TensorFlow)
**MATLAB 备选**: Deep Learning Toolbox + `dlarray`/`dlgradient` + `adamupdate` (需手工构建训练循环)

## Python 备选 (推荐)

```python
import torch
import torch.nn as nn
import numpy as np

class PINN(nn.Module):
    def __init__(self, layers):
        super().__init__()
        self.net = nn.Sequential()
        for i in range(len(layers)-1):
            self.net.append(nn.Linear(layers[i], layers[i+1]))
            self.net.append(nn.Tanh())
    
    def forward(self, x, t):
        return self.net(torch.cat([x, t], dim=1))

# 计算 PDE 残差 (Burgers方程示例)
def pde_residual(model, x, t):
    x.requires_grad_(True); t.requires_grad_(True)
    u = model(x, t)
    u_t = torch.autograd.grad(u, t, grad_outputs=torch.ones_like(u), 
                               create_graph=True)[0]
    u_x = torch.autograd.grad(u, x, grad_outputs=torch.ones_like(u), 
                               create_graph=True)[0]
    u_xx = torch.autograd.grad(u_x, x, grad_outputs=torch.ones_like(u), 
                                create_graph=True)[0]
    # Burgers: u_t + u*u_x - nu*u_xx = 0
    return u_t + u * u_x - nu * u_xx

# DeepXDE 高级封装 (推荐)
import deepxde as dde
```

备选: `DeepXDE` (推荐, 基于 TensorFlow/PyTorch/PaddlePaddle), `NVIDIA Modulus`

## 选型决策树

- **PDE 已知 + 稀疏/噪声观测 + 需求解全时空** → PINN (免网格, 连续解)
- **PDE 已知 + 无观测 (正向问题)** → 传统数值解法 (FEM/FDM) 更成熟; PINN 仅在复杂几何/自由边界有优势
- **仅数据无物理** → 标准 NN (MLP/LSTM/CNN), 不需要 PINN
- **反问题 (从观测推断 PDE 参数)** → PINN 天然优势 (参数作为可学习变量)
- **高维 PDE ($d > 3$)** → PINN 免于网格维数灾难, 是强有力的替代, 但训练难度大
- **传统数值解法够用 ($d \leq 2$) + 不涉及学习/逆问题 + 网格易生成** → **传统数值解更划算**, 不要为 PINN 而 PINN

## 典型图型

- **raw**: 配点分布 (collocation + boundary), 观测数据点
- **process**: 训练损失曲线 (total/data/physics/boundary 分别), 预测解演化图 (多帧)
- **result**: PINN 解 vs 传统数值解对比图 (2D热力图 或 1D剖面), 绝对误差分布

## 常见坑

1. **训练不收敛 (loss plateau)**: 多看各损失分量 — data 已收敛但 physics 未收敛 → 调整 $\lambda_{\text{physics}}$ 或重新平衡
2. **PDE 刚度大**: 一阶与二阶导数量级差异巨大 → 损失不平衡, 导致 physics 梯度主导, 学习失效 → 动态权重平衡 (Learning Rate Annealing)
3. **高阶导数的计算图爆炸**: 二阶以上导数 Autodiff 内存开销巨大 → 适度控制网络深度
4. **因果违背**: 时间相关 PDE 用 PINN 同时训练所有时刻, 后期解可能在前而不满足初始条件 → 时序自适应采样

## 失效条件/反例 (强制小节)

- **条件1**: PDE 已知 + 低维 ($d \leq 2$) + 网格可轻松生成 + 不需要数据融合/逆问题 → PINN 训练耗时远大于传统数值解, 精度通常也不如 FEM/FDM (PINN 一般 $10^{-3}$, FEM 可 $10^{-6}$)。**替代**: 传统数值解 (FDM/FEM/FVM via `pdepe`/`ode45`), **不要为 PINN 而 PINN**
- **条件2**: 无观测数据 + 正向 PDE 问题 → PINN 此时等效于用 NN 解 PDE, 缺乏监督信号, 尤其是解含尖角/激波/间断时 PINN 难以捕获高频特征 (光谱偏差)。**替代**: 传统数值法 (WENO/FVM for 激波)
- **条件3**: 深度学习框架不可用 (竞赛环境无 PyTorch/TF) → PINN 核心依赖 Autodiff, MATLAB 虽有 `dlarray` 但生态不成熟, 实现成本高且调试困难。**替代**: 若竞赛无 DL 环境, 改用传统数值法或 Kriging 代理
- **条件4**: PDE 含多尺度/高频特征 (激波, 湍流) → PINN 的光谱偏差 (spectral bias) 导致优先学习低频分量, 高频特征需要远多于配点数的迭代才能捕获, 收敛极慢。**替代**: 多尺度 PINN/Fourier 特征网络, 或传统 WENO/FVM

## 文献

1. Raissi, M., Perdikaris, P., & Karniadakis, G. E. (2019). Physics-informed neural networks: A deep learning framework for solving forward and inverse problems involving nonlinear partial differential equations. *Journal of Computational Physics*, 378, 686-707. DOI: [10.1016/j.jcp.2018.10.045](https://doi.org/10.1016/j.jcp.2018.10.045)
2. Lu, L., Meng, X., Mao, Z., & Karniadakis, G. E. (2021). DeepXDE: A deep learning library for solving differential equations. *SIAM Review*, 63(1), 208-228. DOI: [10.1137/19M1274067](https://doi.org/10.1137/19M1274067)

## 来源溯源

- 论文三元组: Raissi 2019, PINN, physics-informed neural networks + automatic differentiation
- 开源仓库: [DeepXDE](https://github.com/lululxvi/deepxde), [NVIDIA Modulus](https://github.com/NVIDIA/modulus)

## 关联范式卡

组合: PARADIGM-1006-POD-DEIM (降阶 + PINN), PARADIGM-0618-CNN (CNN+物理约束)
替代: 传统数值解 (FDM/FEM/FVM, `pdepe`/`ode45`), PARADIGM-1001-GPR (GPR+PDE核)
前置: DL 基础 (PARADIGM-0618-CNN)
