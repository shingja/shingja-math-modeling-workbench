# PARADIGM-0815 Hodgkin-Huxley/FitzHugh-Nagumo神经元⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0815 |
| 类别/子类 | ⑧机理建模与PDE / 神经动力学 |
| 难度 | 高 |
| 适用题型关键词[] | Hodgkin-Huxley, FitzHugh-Nagumo, 神经元, 动作电位, 兴奋性, 神经计算, ode15s, Izhikevich |
| confidence | medium |
| source | Izhikevich (2007) MIT Press |

## 数学形式

**Hodgkin-Huxley (HH) 四维模型:**
$$C_m \frac{dV}{dt} = I_{\text{ext}} - \bar{g}_{Na}m^3h(V-E_{Na}) - \bar{g}_K n^4(V-E_K) - \bar{g}_L(V-E_L)$$

门控变量动力学 ($x \in \{m, h, n\}$):
$$\frac{dx}{dt} = \alpha_x(V)(1-x) - \beta_x(V)x$$

其中速率函数:
$$\alpha_m(V) = 0.1\frac{25-V}{\exp((25-V)/10)-1}, \quad \beta_m(V) = 4e^{-V/18}$$
$$\alpha_h(V) = 0.07e^{-V/20}, \quad \beta_h(V) = \frac{1}{\exp((30-V)/10)+1}$$
$$\alpha_n(V) = 0.01\frac{10-V}{\exp((10-V)/10)-1}, \quad \beta_n(V) = 0.125e^{-V/80}$$

**FitzHugh-Nagumo (FHN) 二维简化:**
$$\frac{dv}{dt} = v - \frac{v^3}{3} - w + I$$
$$\frac{dw}{dt} = \varepsilon(v + a - bw)$$

- $v$ — 膜电位 (快变量)
- $w$ — 恢复变量 (慢变量)
- $\varepsilon \ll 1$ → 时间尺度分离 (产生弛豫振荡)

**Izhikevich 模型 (平衡生物真实性与计算效率):**
$$\frac{dv}{dt} = 0.04v^2 + 5v + 140 - u + I$$
$$\frac{du}{dt} = a(bv - u)$$
若 $v \geq 30$ mV: $v \leftarrow c, \quad u \leftarrow u + d$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| I_ext | double | 10 μA/cm² | [0,50] | 极高 — 决定发放模式 |
| g_Na/g_K/g_L | double | 120/36/0.3 mS/cm² | — | 极高 |
| epsilon (FHN) | double | 0.08 | (0,0.2) | 高 — 控制振荡周期 |
| solver | str | 'ode15s' | — | 极高 — HH 高度刚性 |

## MATLAB 实现

```matlab
% Hodgkin-Huxley
function dydt = hh_ode(t, y, I_ext)
    V = y(1); m = y(2); h = y(3); n = y(4);
    
    % 门控速率
    am = 0.1*(25-V)/(exp((25-V)/10)-1);
    bm = 4*exp(-V/18);
    ah = 0.07*exp(-V/20);
    bh = 1/(exp((30-V)/10)+1);
    an = 0.01*(10-V)/(exp((10-V)/10)-1);
    bn = 0.125*exp(-V/80);
    
    % 离子电流
    INa = 120 * m^3 * h * (V - 115);
    IK = 36 * n^4 * (V + 12);
    IL = 0.3 * (V - 10.613);
    
    dydt = [
        (I_ext - INa - IK - IL);   % dV/dt
        am*(1-m) - bm*m;            % dm/dt
        ah*(1-h) - bh*h;            % dh/dt
        an*(1-n) - bn*n             % dn/dt
    ];
end

[t, y] = ode15s(@(t,y) hh_ode(t,y,10), [0,100], [-65;0.05;0.6;0.32]);
V = y(:,1);
plot(t, V); xlabel('t (ms)'); ylabel('V (mV)');
```

锚点: `ode15s` (MATLAB内置)

## Python 备选

```python
from scipy.integrate import solve_ivp
# Brian2 (专业神经模拟)
from brian2 import *
```

## 选型决策树

- **Hodgkin-Huxley** — 需要详细的离子通道动力学，精确模拟动作电位形状
- **FitzHugh-Nagumo** — 定性理解兴奋性 (教学、相平面分析、分岔)
- **Izhikevich** — 大规模网络仿真 (生物真实 + 计算高效)
- **Integrate-and-Fire** — 极简模型，皮层网络 (10^4-10^5 神经元)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | 动作电位 V(t) (spike train) | 展示阈下/阈上响应 |
| result | FHN 相平面 (v-w) + nullcline | 展示极限环 |
| result | 频率-电流 (f-I) 曲线 | 神经元增益 |

## 常见坑

1. **HH 模型的刚性**: 门控变量在 spike 期间变化极快 (0.1ms) 而静息缓慢 (10ms) → ode45 步长过小 → 必须用 ode15s
2. **初始条件的瞬态**: 门控变量需要几 ms 达到稳态 → burn-in 时间 (丢弃前 ~10ms)
3. **Izhikevich 参数集**: a,b,c,d 选择决定神经元类型 (RS,FS,IB,CH...), 选错则发放模式完全错误

## 失效条件/反例 (强制小节)

- **条件1: HH 模型用于大型网络 (N > 1000 神经元)** → 表现: 每神经元 4 ODE × 突触耦合 → 4000+ 维刚性 ODE，ode15s 的 BDF 对高维刚性系统 Jacobian 分解 O(N³) 不可行。**应对**: 降阶为 Izhikevich (2D) 或 LIF (1D) 模型，或使用专门的大规模神经模拟器 (Brian2/NEURON/NEST)
- **条件2: FHN 不能产生 bursting (簇发放)** → 表现: FHN 是二维系统，不能产生慢波调制下的簇发放模式 (需要通过分岔机制在静息和发放间切换，需要至少 3 维)。**应对**: 使用 Hindmarsh-Rose 模型 (3D) 或 Izhikevich (有 bursting 参数集)

## 文献

1. Izhikevich E.M. (2007). *Dynamical Systems in Neuroscience: The Geometry of Excitability and Bursting*. MIT Press. ISBN: 978-0262090438
2. Hodgkin A.L. & Huxley A.F. (1952). "A quantitative description of membrane current and its application to conduction and excitation in nerve." *J Physiology*, 117(4):500-544. DOI: [10.1113/jphysiol.1952.sp004764](https://doi.org/10.1113/jphysiol.1952.sp004764)

## 来源溯源

ode15s; 神经动力学教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0807 (ODE迭代器) |
| 替代 | PARADIGM-0810 (SIR扩展, 生物动力学共用ODE方法) |
