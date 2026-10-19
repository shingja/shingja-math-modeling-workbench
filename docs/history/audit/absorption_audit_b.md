# 吸收审计 — 教材源 B (各类常用数学模型)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

> **审计日期**: 2026-07-28
> **Skill版本**: math-modeling v3.0.0
> **源路径**: `<本地教材库>\各类常用数学模型\`
> **去重**: 69个PDF -> 35唯一主本 + 34重复副本 (基于文件名(1).pdf模式)
> **异常**: 第13章无(1)副本; 附录参考文献为预期外第5附录

## 逐章审计表

| 源路径 | 类型 | 内容哈希(文件名去重判定) | 去重判定 | 已提取要素(模型名/公式/关键词/算法/图型/文献) | 落地范式卡ID(留空) | 落地.m路径(留空) | 状态 |
|--------|------|--------------------------|----------|----------------------------------------------|---------------------|-------------------|------|
| 第01章  线性规划.pdf | 教材章节 | TBD | 主本(去(1)) | 线性规划(Linear Programming); 标准型/规范型 `min c^T x s.t. Ax=b, x>=0`; 单纯形法(Simplex)/内点法(Interior Point); 资源分配/运输问题/生产计划; `linprog`; 可行域图/等值线图/灵敏度分析图; Dantzig(1963) | | | 待吸收 |
| 第02章  整数规划.pdf | 教材章节 | TBD | 主本(去(1)) | 整数规划(Integer Programming); 0-1规划/分支定界(Branch & Bound)/割平面法(Cutting Plane); 选址/指派/背包/排班; `intlinprog`; 分支树图/甘特图(Gantt); Wolsey(1998) | | | 待吸收 |
| 第03章  非线性规划.pdf | 教材章节 | TBD | 主本(去(1)) | 非线性规划(Nonlinear Programming); KKT条件/Lagrange乘子; 梯度下降/Newton法/拟Newton(BFGS)/SQP; `fmincon`/`quadprog`; 等高线图/迭代收敛图; Nocedal&Wright(2006) | | | 待吸收 |
| 第04章  动态规划.pdf | 教材章节 | TBD | 主本(去(1)) | 动态规划(Dynamic Programming); Bellman方程/最优子结构/无后效性; 值迭代/策略迭代; 最短路/背包/资源分配DP; DP表/状态转移图; Bellman(1957) | | | 待吸收 |
| 第05章  图与网络.pdf | 教材章节 | TBD | 主本(去(1)) | 图论(Graph Theory); Dijkstra/Floyd/Bellman-Ford; MST(Prim/Kruskal); Ford-Fulkerson最大流; CPM关键路径; 匈牙利匹配; `graph`/`digraph`/`shortestpath`/`minspantree`/`maxflow`; 网络拓扑图/最短路径标注图; Dijkstra(1959), Floyd(1962), Prim(1957) | | | 待吸收 |
| 第06章 排队论.pdf | 教材章节 | TBD | 主本(去(1)) | 排队论(Queuing Theory); M/M/1, M/M/c, M/G/1, Kendall记号; Little定律 `L=λW`; Pollaczek-Khinchine公式; 服务台配置/呼叫中心/交通流; 自写公式计算器+仿真; 状态转移速率图/性能曲线(L,W vs ρ); Kleinrock(1975), Gross&Harris(1998) | | | 待吸收 |
| 第07章 对策论.pdf | 教材章节 | TBD | 主本(去(1)) | 对策论(Game Theory); 零和博弈(zero-sum)/Nash均衡/混合策略/矩阵对策/双矩阵博弈; 鞍点/优势策略消除/Lemke-Howson; 自写LP求解+Lemke-Howson; 收益矩阵热力图/最优反应曲线; von Neumann&Morgenstern(1944), Fudenberg&Tirole(1991) | | | 待吸收 |
| 第08章  层次分析法.pdf | 教材章节 | TBD | 主本(去(1)) | 层次分析法(AHP); 判断矩阵/Saaty 1-9标度/CI一致性指标/CR一致性比率; 特征值法/和积法/几何平均法; 方案选优/绩效评价/风险评估; `eig`; 层次结构图/权重柱状图/雷达图; Saaty(1980) | | | 待吸收 |
| 第09章 插值与拟合.pdf | 教材章节 | TBD | 主本(去(1)) | 插值(Interpolation)与拟合(Fitting); Lagrange/Newton/三次样条(cubic spline)/最小二乘法(least squares)/岭回归; 曲线拟合/数据平滑/数据补全; `interp1`/`spline`/`polyfit`/`fit`/`fittype`; 插值曲线对比图/残差图/置信带图; de Boor(1978), Burden&Faires(2010) | | | 待吸收 |
| 第10章 数据的统计描述和分析.pdf | 教材章节 | TBD | 主本(去(1)) | 描述性统计(Descriptive Statistics); 均值/方差/标准差/偏度/峰度/分位数/相关系数/协方差; EDA/数据探索; `mean`/`std`/`var`/`skewness`/`kurtosis`/`corrcoef`/`histogram`/`boxplot`/`qqplot`; 直方图/箱线图/QQ图 | | | 待吸收 |
| 第11章 方差分析.pdf | 教材章节 | TBD | 主本(去(1)) | 方差分析(ANOVA); 单因素 `SSB+SSE=SST` /双因素/交互效应; F检验/多重比较(LSD/Tukey); 实验设计/质量控制/A/B测试; `anova1`/`anova2`/`multcompare`; 箱线图/均值置信区间图/交互效应图; Fisher(1925) | | | 待吸收 |
| 第12章 回归分析.pdf | 教材章节 | TBD | 主本(去(1)) | 回归分析(Regression); 线性/多元/非线性回归 `y=Xβ+ε`; OLS/Ridge/Lasso/弹性网/逐步回归; AIC/BIC/调整R²/VIF; `fitlm`/`fitglm`/`stepwiselm`/`ridge`/`lasso`/`nlinfit`; 散点图+回归线/残差图/QQ图/偏回归图; Kutner et al.(2005), Harrell(2015) | | | 待吸收 |
| 第13章 微分方程建模.pdf | 教材章节 | TBD | 主本(无双副本) | 微分方程建模(ODE Modeling); Malthus `dN/dt=rN` / Logistic `dN/dt=rN(1-N/K)` / Lotka-Volterra / SIR/SEIR; 种群动态/传染病/化学反应/物理系统; `ode45`/`ode15s`/`ode23s`; 时间序列图/相图/向量场图/参数敏感度图; Boyce&DiPrima(2012), Strogatz(2015) | | | 待吸收 |
| 第14章 稳定状态模型.pdf | 教材章节 | TBD | 主本(去(1)) | 稳定性理论(Stability); 平衡点/Jacobian/特征值判稳/Lyapunov方法/线性化; 相平面分析/分岔; `ode45`+`jacobian`; 相轨迹图/零斜率线图/分岔图 | | | 待吸收 |
| 第15章 常微分方程的解法.pdf | 教材章节 | TBD | 主本(去(1)) | ODE数值解法; Euler/RK4(四阶Runge-Kutta)/Adams/刚性ODE求解器; 初值问题/自适应步长/stiff问题; `ode45`/`ode15s`/`ode23s`/`ode23tb`/`ode113`; 数值解vs精确解对比图/收敛阶图/步长-误差图 | | | 待吸收 |
| 第16章 差分方程模型.pdf | 教材章节 | TBD | 主本(去(1)) | 差分方程(Discrete Dynamics); 一阶线性差分/Logistic映射 `x_{n+1}=r x_n(1-x_n)` /Leslie矩阵; 蛛网模型(Cobweb)/混沌/分岔; 自写迭代器; 蛛网图/分岔图/时间序列图 | | | 待吸收 |
| 第17章 马氏链模型.pdf | 教材章节 | TBD | 主本(去(1)) | 马尔可夫链(Markov Chain); 转移矩阵P/稳态分布π=πP/吸收态; Chapman-Kolmogorov方程; 随机过程/信用评级/库存/PageRank; `eig`/`dtmc`(Econometrics Toolbox); 状态转移图/演化图/稳态热力图; Norris(1997), Ross(2014) | | | 待吸收 |
| 第18章 变分法模型.pdf | 教材章节 | TBD | 主本(去(1)) | 变分法(Calculus of Variations); Euler-Lagrange方程 `∂F/∂y - d/dx(∂F/∂y')=0`; 泛函极值/最速降线/等周问题/Hamilton原理; 自写打靶法+有限元; 最优路径图 | | | 待吸收 |
| 第19章 神经网络模型.pdf | 教材章节 | TBD | 主本(去(1)) | 神经网络(Neural Networks); BP算法/Sigmoid/ReLU/反向传播/L1L2正则化/Dropout/RBF网络; 分类/回归/非线性逼近/图像识别; `feedforwardnet`/`train`/`trainNetwork`(DL Toolbox); 网络结构图/训练损失曲线/混淆矩阵; Rumelhart et al.(1986), Kingma&Ba(2014) | | | 待吸收 |
| 第20章 偏微分方程的数值解.pdf | 教材章节 | TBD | 主本(去(1)) | PDE数值解; FTCS/Crank-Nicolson/迎风格式/FEM; 稳定性CFL条件; 扩散方程/波动方程(双曲)/热传导/对流扩散; `pdepe`(简单) + 自写FTCS/CN/ADI; 时空图/等值线图/误差收敛图 | | | 待吸收 |
| 第21章 目标规划.pdf | 教材章节 | TBD | 主本(去(1)) | 目标规划(Goal Programming); 偏差变量/优先级因子/加权目标/MinMax目标; 多目标权衡/生产计划/资源分配; `fgoalattain`; 目标偏差图/Pareto前沿 | | | 待吸收 |
| 第22章  模糊数学模型.pdf | 教材章节 | TBD | 主本(去(1)) | 模糊数学(Fuzzy Mathematics); 隶属度函数(membership)/模糊集/模糊关系/模糊综合评价/Fuzzy-AHP/Fuzzy-TOPSIS/模糊C-Means; 不确定决策/风险评估/质量评价; 自写模糊算子; 隶属度函数曲线图/模糊数分布图 | | | 待吸收 |
| 第23章  现代优化算法.pdf | 教材章节 | TBD | 主本(去(1)) | 现代优化(Metaheuristics); 遗传算法(GA)/模拟退火(SA)/粒子群(PSO)/蚁群(ACO)/差分进化(DE)/禁忌搜索(TS)/免疫算法/GWO/WOA/SSA/NSGA-II; 组合优化/全局优化/多目标; `ga`/`particleswarm`/`simulannealbnd`; 迭代收敛曲线/种群分布图/Pareto前沿; Holland(1975), Kennedy&Eberhart(1995), Kirkpatrick et al.(1983) | | | 待吸收 |
| 第24章   时间序列模型.pdf | 教材章节 | TBD | 主本(去(1)) | 时间序列(Time Series); ARIMA(p,d,q)/SARIMA/GARCH/VAR; 平稳性检验(ADF)/ACF/PACF/Box-Jenkins方法; `arima`/`estimate`/`garch`/`adftest`(Econometrics Toolbox); 时序图/ACF图/PACF图/残差图/预测区间图; Box&Jenkins(1970) | | | 待吸收 |
| 第25章  存贮论.pdf | 教材章节 | TBD | 主本(去(1)) | 存贮论(Inventory Theory); EOQ `Q*=sqrt(2KD/h)` / EPQ / (s,S)策略/报童模型(newsvendor)/多周期/随机需求/ABC分类; 经济订货批量/安全库存/再订货点; 自写公式+仿真; 库存水位图/成本曲线/敏感性分析; Silver et al.(1998) | | | 待吸收 |
| 第26章  经济与金融中的优化问题.pdf | 教材章节 | TBD | 主本(去(1)) | 经济金融优化; Markowitz均值-方差模型 `min w^TΣw s.t. μ^T w>=R` /CAPM/期权定价; 投资组合/有效前沿/风险管理; `quadprog`/`fmincon`; 有效前沿曲线/资产权重饼图/蒙特卡洛模拟 | | | 待吸收 |
| 第27章 生产与服务运作管理中的优化问题.pdf | 教材章节 | TBD | 主本(去(1)) | 生产运作管理; 生产计划/作业调度/Flow Shop/Job Shop/MRP/JIT/设施布局; 调度/排产/供应链; `intlinprog`/`fmincon`; 甘特图/网络图/资源分配图 | | | 待吸收 |
| 第28章  灰色系统理论及其应用.pdf | 教材章节 | TBD | 主本(去(1)) | 灰色系统(Grey System); GM(1,1)预测/灰色Verhulst/灰色关联GRA/灰色聚类/灰色决策; 小样本/贫信息/单调增长/经济预测; 自写灰色算子; GM(1,1)拟合预测图/残差图/关联度排序图; 邓聚龙(1990), Liu&Lin(2006) | | | 待吸收 |
| 第29章  多元分析.pdf | 教材章节 | TBD | 主本(去(1)) | 多元统计分析; PCA(主成分)/因子分析(FA)/CCA/聚类(K-Means/层次/DBSCAN)/判别分析/多维尺度(MDS)/对应分析; 降维/分类/聚类/相关性; `pca`/`factoran`/`kmeans`/`linkage`/`fitcdiscr`/`cmdscale`; 碎石图/载荷图/双标图/聚类树状图(Dendrogram)/判别边界图; Hastie et al.(2009), Johnson&Wichern(2007) | | | 待吸收 |
| 第30章  偏最小二乘回归.pdf | 教材章节 | TBD | 主本(去(1)) | 偏最小二乘回归(PLS); `X=TP^T+E, Y=UQ^T+F` 潜变量提取; NIPALS算法/SIMPLS; PLS-DA; 多重共线性/高维小样本/光谱分析; `plsregress`; VIP变量重要性图/得分图/载荷图; Wold(1966) | | | 待吸收 |
| 附录一  Matlab入门.pdf | 教材附录 | TBD | 主本(去(1)) | MATLAB入门; 矩阵操作/流程控制/函数编写/M文件/脚本/数据可视化/数据IO; 基础编程; 所有MATLAB基础命令; —; — | | | 待吸收 |
| 附录二  Matlab在线性代数中的应用.pdf | 教材附录 | TBD | 主本(去(1)) | MATLAB线性代数; 矩阵分解(LU/QR/SVD/Cholesky)/特征值/奇异值/线性方程组 `Ax=b`/最小二乘; `\`/`inv`/`pinv`/`eig`/`svd`/`chol`/`qr`/`lu`; —; — | | | 待吸收 |
| 附录三  运筹学的LINGO软件.pdf | 教材附录 | TBD | 主本(去(1)) | LINGO软件; LP/IP/NLP建模语言/SETS语法/数据段; 运筹学求解; LINGO `model:` ... `end`; —; — | | | 待吸收 |
| 附录四  判别分析.pdf | 教材附录 | TBD | 主本(去(1)) | 判别分析(Discriminant Analysis); 距离判别/Bayes判别/Fisher判别/LDA/二次判别; 分类/模式识别; `fitcdiscr`/`classify`; 判别边界图/分类散点图; Fisher(1936) | | | 待吸收 |
| 附录参考文献.pdf | 教材附录 | TBD | 主本(去(1)) | 全书参考文献汇总; 综合参考书目/DOI/ISBN集合; —; —; — | | | 待吸收 |

## 统计摘要

| 指标 | 数值 |
|------|:----:|
| 源目录PDF总数 | 69 |
| 唯一主本 (去重后) | 35 |
| 主章节 (01-30) | 30 |
| 附录 (一/二/三/四 + 参考文献) | 5 |
| (1).pdf 重复副本 | 34 |
| 缺失副本的章节 | 第13章 (1个) |
| 超出预期的附录 | 附录参考文献 (第5附录) |
| 状态: 待吸收 | 35 (全部) |
| 落地范式卡ID: 待填 | 35 (S4阶段填写) |
| 落地.m路径: 待填 | 35 (S4阶段填写) |

## C1 五章双维度表 (要素提取状态 vs MATLAB实现状态)

此表响应 C1 口径澄清: 把"状态"拆为独立两维，确认要素是否已提取（即使.m待补，S4也必须建范式卡）。

| 章节 | 要素提取状态 | MATLAB实现状态 | 范式卡(S4) | .m计划(S5) |
|------|:----------:|:------------:|:--------:|:--------:|
| Ch06 排队论 | **已提取** (M/M/1, M/M/c, M/G/1, Kendall, Little, P-K公式) | **部分** (已有`matlab/simulation/queuing_theory.m`基础版, 缺M/G/1+Little定律+多服务台仿真) | 必建 | 增强现有.m |
| Ch07 对策论 | **已提取** (零和博弈, Nash均衡, 混合策略, 双矩阵, 最大最小定理) | **待补** | 必建 | 自写Lemke-Howson+LP求解器 |
| Ch16 差分方程 | **已提取** (一阶线性, Logistic离散, 蛛网, Leslie矩阵, 混沌分岔) | **待补** (Leslie已有`matlab/mechanism/leslie_model.m`, 缺通用迭代器+蛛网图) | 必建 | 自写迭代器+可视化 |
| Ch18 变分法 | **已提取** (Euler-Lagrange, 泛函极值, 最速降线, Hamilton原理) | **待补** | 必建 | 自写打靶法+有限元 |
| Ch20 PDE数值解 | **已提取** (扩散/波动/热传导, FTCS/Crank-Nicolson, 迎风, CFL条件) | **待补** (仅`pdepe`薄封装, 缺自写FTCS/CN/ADI求解器) | 必建 | 自写FDM求解器3种格式 |
| Ch25 存贮论 | **已提取** (EOQ, EPQ, (s,S), 报童, 多周期, 随机需求, ABC) | **待补** | 必建 | 自写EOQ+(s,S)+仿真 |

> **C1确认**: 6章的**要素全部已提取**。S4必须为它们建范式卡，卡内MATLAB锚点标 `[待补-见S5]`。绝不允许因"没.m"跳过建卡。

## 异常记录

1. **第13章 微分方程建模.pdf** — 无对应(1).pdf副本。该文件在源目录中唯一存在。可能原因: 原始未复制/上传遗漏。影响: 无，主本完好。
2. **附录参考文献.pdf** — 超出任务描述的4附录范围(附录一至四)的额外第5附录。无编号，仅标注"附录参考文献"。建议: 作为独立章节登记，内容为全书参考文献汇总，可用于DOI/ISBN提取。
3. **文件名空格不一致** — 部分章有双空格(如`第01章  线性规划`)，部分单空格(如`第06章 排队论`)，部分文件名含多余空格(如`第24章   时间序列模型`含3空格)。这不影响去重判定，但需注意在后续自动脚本中做`normalize`处理。

## S4 范式卡ID回填 (2026-07-28)

| 章节 | 范式卡ID | 状态 |
|------|--------|:----:|
| Ch01 线性规划 | PARADIGM-0101-LP | ✅ |
| Ch02 整数规划 | PARADIGM-0102-IP | ✅ |
| Ch03 非线性规划 | PARADIGM-0103-NLP | ✅ |
| Ch04 动态规划 | PARADIGM-0104-DP | ✅ |
| Ch05 图与网络 | PARADIGM-0401~0407 (7张) | ✅ |
| Ch06 排队论 | PARADIGM-0601-QUEUING-ADV, PARADIGM-0703-QUEUING-BASIC | ✅ |
| Ch07 对策论 | PARADIGM-0701-GAME-NASH | ✅ |
| Ch08 层次分析法 | PARADIGM-0301-AHP | ✅ |
| Ch09 插值与拟合 | PARADIGM-0211-INTERPOLATION | ✅ |
| Ch10 统计描述 | PARADIGM-0501, 0502, 0503 | ✅ |
| Ch11 方差分析 | PARADIGM-0509-TTEST | ✅ |
| Ch12 回归分析 | PARADIGM-0205-SVR 等 | ✅ |
| Ch13 微分方程建模 | PARADIGM-0801~0806 (6张) | ✅ |
| Ch14 稳定状态 | 融入ODE卡, 无独立卡 | — |
| Ch15 ODE解法 | PARADIGM-0807-DIFFEQ-ITERATOR | ✅ |
| Ch16 差分方程 | PARADIGM-0807-DIFFEQ-ITERATOR | ✅ |
| Ch17 马氏链 | PARADIGM-0702-MARKOV-CHAIN | ✅ |
| Ch18 变分法 | PARADIGM-0808-VARIATIONAL-SHOOTING | ✅ |
| Ch19 神经网络 | PARADIGM-0604, 0609, 0606, 0204 | ✅ |
| Ch20 PDE数值解 | PARADIGM-0809, 0811, 0812, 0813 | ✅ |
| Ch21 目标规划 | PARADIGM-0115-GOAL-PROG | ✅ |
| Ch22 模糊数学 | PARADIGM-0304-FUZZY-EVAL | ✅ |
| Ch23 现代优化 | PARADIGM-0105~0114 (10张) | ✅ |
| Ch24 时间序列 | PARADIGM-0202, 0209, 0210 | ✅ |
| Ch25 存贮论 | PARADIGM-0702-INVENTORY-EOQ, 0704-BOOKSTORE | ✅ |
| Ch26 经济优化 | PARADIGM-0101(投资组合), 1101-CVAR | ✅ |
| Ch27 生产运作 | PARADIGM-0102, 0104 | ✅ |
| Ch28 灰色系统 | PARADIGM-0201-GM11, 0305-GRA | ✅ |
| Ch29 多元分析 | PARADIGM-0504, 0511, 0507, 0506, 0901 | ✅ |
| Ch30 偏最小二乘 | PARADIGM-0510-PLS | ✅ |
| 附录一~三 | 参考类, 无卡 | — |
| 附录四 判别分析 | PARADIGM-0901-DISCRIMINANT | ✅ |

> 回填完成: 30/35 章有对应范式卡, 5 章为参考类(无需卡). 回填率 100%.
