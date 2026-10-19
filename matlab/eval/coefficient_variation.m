% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [weights, cv_values, stats] = coefficient_variation(data, varargin)
%COEFFICIENT_VARIATION 变异系数法 — 客观赋权
%   [WEIGHTS, CV_VALUES, STATS] = COEFFICIENT_VARIATION(DATA)
%   基于指标变异程度确定权重。变异系数越大 → 指标区分度越高 → 权重越大。
%
%   Source: 郭亚军 (2007). 综合评价理论、方法及应用. 科学出版社. §4.3
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       data  - 原始数据矩阵 (n_objects × n_indicators)
%
%   可选参数:
%       'Direction'   - 指标方向向量 (1×n_indicators)
%                       +1 = 正向 (默认全部)
%                       -1 = 逆向 (自动取倒数/反向归一化)
%       'Normalize'   - 归一化方法 (默认: 'minmax')
%                       'minmax' | 'zscore' | 'vector' (向量归一化)
%       'HandleZero'  - 零值处理 (默认: 'add_epsilon', 加 1e-8)
%
%   输出:
%       weights   - 归一化权重 (1×n_indicators), 和为 1
%       cv_values - 各指标的变异系数 (1×n_indicators)
%       stats     - 结构体:
%           .mean     - 各指标均值
%           .std      - 各指标标准差
%           .range    - 各指标极差
%
%   示例:
%       data = [85 92 78; 76 88 82; 90 85 70; 65 78 88];
%       weights = coefficient_variation(data);

%% 依赖检查
% 仅使用 MATLAB 内置函数

[n_objects, n_indicators] = size(data);

%% 参数解析
p = inputParser;
p.addParameter('Direction', ones(1, n_indicators), ...
    @(v) isvector(v) && length(v) == n_indicators && all(abs(v) == 1));
p.addParameter('Normalize', 'minmax', ...
    @(v) any(strcmp(v, {'minmax', 'zscore', 'vector'})));
p.addParameter('HandleZero', 'add_epsilon', ...
    @(v) any(strcmp(v, {'add_epsilon', 'none'})));
p.parse(varargin{:});
opts = p.Results;

direction = opts.Direction(:)';

%% Step 1: 正向化处理
% 逆向指标取倒数或 minmax 反向
X = data;
for j = 1:n_indicators
    if direction(j) == -1
        % 逆向指标: 使用 max - x 进行正向化
        X(:, j) = max(data(:, j)) + min(data(:, j)) - data(:, j);
    end
end

%% Step 2: 归一化
switch opts.Normalize
    case 'minmax'
        % Min-Max 归一化到 [0, 1]
        X_min = min(X, [], 1);
        X_max = max(X, [], 1);
        range = X_max - X_min;
        range(range < 1e-10) = 1;  % 常数列防止除零
        X_norm = (X - X_min) ./ range;

    case 'zscore'
        % Z-score 标准化
        X_mean = mean(X, 1);
        X_std = std(X, 0, 1);
        X_std(X_std < 1e-10) = 1;
        X_norm = (X - X_mean) ./ X_std;

    case 'vector'
        % 向量归一化 (TOPSIS 常用)
        col_norm = sqrt(sum(X.^2, 1));
        col_norm(col_norm < 1e-10) = 1;
        X_norm = X ./ col_norm;
end

%% Step 3: 零值处理
if strcmp(opts.HandleZero, 'add_epsilon')
    X_norm = X_norm + 1e-8;
end

%% Step 4: 计算变异系数
col_mean = mean(X_norm, 1);
col_std = std(X_norm, 0, 1);

% CV = 标准差 / 均值 (对归一化后的数据)
cv_values = col_std ./ (abs(col_mean) + 1e-10);

% 若均值接近零 → 使用绝对标准差
zero_mean_idx = abs(col_mean) < 1e-6;
if any(zero_mean_idx)
    cv_values(zero_mean_idx) = col_std(zero_mean_idx);
end

%% Step 5: 归一化为权重
weights = cv_values / sum(cv_values);

%% 构建统计结构体
stats.mean = col_mean;
stats.std = col_std;
stats.range = max(X, [], 1) - min(X, [], 1);
stats.cv = cv_values;

%% 输出摘要
fprintf('\n=== 变异系数法 权重 ===\n');
fprintf('%-8s %-10s %-10s %-8s\n', '指标', '均值', '标准差', '权重');
fprintf('%s\n', repmat('-', 1, 40));
for j = 1:n_indicators
    fprintf('指标%-4d %10.4f %10.4f %8.4f\n', j, col_mean(j), col_std(j), weights(j));
end
fprintf('\n权重总和 = %.4f\n', sum(weights));
end

%% Self-test
function self_test()
    % Test with known variance data — one high variance, one low variance
    data = [1 10; 2 20; 3 30; 4 40; 5 50];
    weights = coefficient_variation(data);
    assert(length(weights) == 2, 'Test failed: weights should have 2 entries.');
    assert(abs(sum(weights) - 1.0) < 1e-6, 'Test failed: weights should sum to 1.');
    % Column 2 has higher variance than column 1 → higher weight
    assert(weights(2) > weights(1), 'Test failed: higher-variance column should get higher weight.');
    disp('coefficient_variation self-test passed.');
end
