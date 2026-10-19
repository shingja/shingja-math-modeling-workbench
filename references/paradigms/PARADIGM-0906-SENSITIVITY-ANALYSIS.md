# PARADIGM-0906-SENSITIVITY-ANALYSIS — 灵敏度分析Sobol/Morris/FAST⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0906-SENSITIVITY-ANALYSIS |
| 类别/子类 | ⑨综合经典 |
| 难度 | 中 |
| 适用题型关键词 | 全局灵敏度/参数重要性/不确定性量化 |
| confidence | medium |
| source | Saltelli(2002); Cukier(1973) |

## 数学形式
自写算法，核心公式见文献引用。灵敏度分析Sobol/Morris/FAST 的标准数学形式参考教材对应章节。

## 输入/输出/参数
文献参考: Saltelli et al.(2008) Global Sensitivity Analysis, Wiley. ISBN 978-0-470-05997-5

## MATLAB 实现
自写-见S5:sensitivity_analyze.m

## Python 备选
自写或调用 scipy/sklearn 对应函数。

## 选型决策树
灵敏度分析Sobol/Morris/FAST — 与替代方案的选择权衡见失效条件小节。

## 典型图型
灵敏度蛛网图/模型选择信息准则对比图/组合预测对比图/评价雷达图/不确定性瀑布图

## 常见坑
参见失效条件小节。

## 失效条件/反例 (强制)
1. Morris方法在非单调模型上不可靠; Sobol需大量采样(>1000×维数)导致计算爆炸→换FAST

## 文献
- Saltelli et al.(2008) Global Sensitivity Analysis, Wiley. ISBN 978-0-470-05997-5

## 来源溯源
教材/竞赛论文/开源实现

## 关联范式卡
组合/替代/前置 ID[]
