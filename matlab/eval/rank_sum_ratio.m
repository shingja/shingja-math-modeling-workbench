% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [rsr, ranks, probit, classifications] = rank_sum_ratio(data, varargin)
%RANK_SUM_RATIO 秩和比法 (Rank Sum Ratio, RSR)
%   [RSR, RANKS, PROBIT, CLASSIFICATIONS] = RANK_SUM_RATIO(DATA)
%   中国统计学家田凤调提出的综合评价方法。基于秩转换的非参数统计。
%
%   Source: 田凤调 (1993). 秩和比法及其应用. 中国统计出版社.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       data  - 原始数据矩阵 (n_objects × n_indicators)
%               - 方案评价: 行=方案, 列=指标
%               - 指标方向由 'Direction' 参数指定
%
%   可选参数:
%       'Direction'   - 指标方向向量 (1×n_indicators)
%                       +1 = 高优指标 (越大越好)
%                       -1 = 低优指标 (越小越好)
%                       (默认: 全部 +1)
%       'Weights'     - 指标权重 (1×n_indicators, 默认: 等权)
%       'NumClasses'  - 分档数 (默认: 5, 通常 3/4/5)
%       'ClassLabels' - 分档标签 cell (默认: {'差', '较差', '中等', '良好', '优秀'})
%
%   输出:
%       rsr            - RSR 值 (n_objects×1), 越大越优
%       ranks          - 各指标秩次 (n_objects×n_indicators)
%       probit         - 概率单位 Probit 值
%       classifications - 分档结果结构体
%           .class_label  - 每对象的分类标签
%           .thresholds   - 各档 RSR 阈值
%
%   示例:
%       data = [85 92 78; 76 88 82; 90 85 70; 65 78 88];
%       % 指标1、2高优, 指标3低优
%       rsr = rank_sum_ratio(data, 'Direction', [1, 1, -1]);

%% 依赖检查
% 仅使用 MATLAB 内置函数

[n_objects, n_indicators] = size(data);

%% 参数解析
p = inputParser;
p.addParameter('Direction', ones(1, n_indicators), ...
    @(v) isvector(v) && length(v) == n_indicators && all(abs(v) == 1));
p.addParameter('Weights', ones(1, n_indicators) / n_indicators, ...
    @(v) isvector(v) && length(v) == n_indicators && abs(sum(v) - 1) < 1e-10);
p.addParameter('NumClasses', 5, @(v) isscalar(v) && v >= 3 && v <= 7);
p.addParameter('ClassLabels', {'差', '较差', '中等', '良好', '优秀'}, @iscell);
p.parse(varargin{:});
opts = p.Results;

direction = opts.Direction(:)';
weights = opts.Weights(:)';

%% Step 1: 编秩 (Ranking)
ranks = zeros(n_objects, n_indicators);

for j = 1:n_indicators
    col = data(:, j);
    [~, ~, r] = unique(col);
    r_tied = tiedrank_adjusted(col);

    if direction(j) == 1
        % 高优指标: 值越大秩次越高
        ranks(:, j) = r_tied;
    else
        % 低优指标: 值越小秩次越高 (逆序编秩)
        ranks(:, j) = n_objects + 1 - r_tied;
    end
end

%% Step 2: 计算 WRSR (加权秩和比)
if abs(sum(weights) - 1) > 1e-10
    weights = weights / sum(weights);
end

rsr = sum(ranks .* weights, 2) / n_objects;

%% Step 3: 确定 RSR 分布 → Probit
% 按 RSR 升序排列, 计算累计频率
[rsr_sorted, sort_idx] = sort(rsr);
n = n_objects;

% 计算频率 (使用中位秩: (i-0.375)/(n+0.25) 或 (i-0.5)/n)
p = ((1:n)' - 0.5) / n;

% 修正: 最大组用 1-1/(4n)
p(end) = 1 - 1 / (4 * n);

% Probit = norminv(p) + 5 (标准正态分位数 + 5)
probit_sorted = norminv(p) + 5;

% 还原为原始顺序
probit = zeros(n_objects, 1);
probit(sort_idx) = probit_sorted;

%% Step 4: 线性回归 RSR = a + b*Probit
X_reg = [ones(n, 1), probit_sorted];
b = X_reg \ rsr_sorted;
rsr_fitted = X_reg * b;
R2 = 1 - sum((rsr_sorted - rsr_fitted).^2) / sum((rsr_sorted - mean(rsr_sorted)).^2);

%% Step 5: 分档
% 按 RSR 值等距或等频分档
num_class = opts.NumClasses;
class_labels = opts.ClassLabels;

% 使用分位数分档
prctile_edges = linspace(0, 100, num_class + 1);
prctile_edges = prctile_edges(2:end-1);  % 提取内部阈值
thresholds = prctile(rsr, prctile_edges);

% 分配类别
class_id = ones(n_objects, 1);
for c = 2:num_class
    class_id(rsr >= thresholds(c-1)) = c;
end

% 构建分类结果
class_label = cell(n_objects, 1);
for i = 1:n_objects
    class_label{i} = class_labels{class_id(i)};
end

classifications.class_id = class_id;
classifications.class_label = class_label;
classifications.thresholds = thresholds;
classifications.labels = class_labels;
classifications.R2 = R2;

%% 输出摘要
fprintf('\n=== 秩和比法 (RSR) 结果 ===\n');
fprintf('拟合优度 R² = %.4f\n', R2);
fprintf('\n分档阈值:\n');
for c = 1:num_class
    if c == 1
        fprintf('  %s: RSR < %.4f (%d 个)\n', class_labels{c}, thresholds(1), sum(class_id == c));
    elseif c == num_class
        fprintf('  %s: RSR ≥ %.4f (%d 个)\n', class_labels{c}, thresholds(end), sum(class_id == c));
    else
        fprintf('  %s: %.4f ≤ RSR < %.4f (%d 个)\n', ...
                class_labels{c}, thresholds(c-1), thresholds(c), sum(class_id == c));
    end
end
end

%% 辅助函数: 处理结的秩 (tied rank, 取平均秩)
function r = tiedrank_adjusted(x)
    % equivalent to tiedrank from Statistics Toolbox
    % but implemented without dependency
    n = length(x);
    [~, sort_idx] = sort(x);
    r = zeros(n, 1);
    i = 1;
    while i <= n
        j = i;
        while j < n && x(sort_idx(j)) == x(sort_idx(j+1))
            j = j + 1;
        end
        % 平均秩
        avg_rank = (i + j) / 2;
        for k = i:j
            r(sort_idx(k)) = avg_rank;
        end
        i = j + 1;
    end
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test with 3-alternative 2-criterion problem
    data = [8 9; 6 7; 9 5];
    [rsr, ranks, probit, cl] = rank_sum_ratio(data, 'Direction', [1, 1]);
    assert(length(rsr) == 3, 'Test failed: RSR should have 3 entries.');
    assert(size(ranks, 1) == 3, 'Test failed: ranks should have 3 rows.');
    disp('rank_sum_ratio self-test passed.');
end
