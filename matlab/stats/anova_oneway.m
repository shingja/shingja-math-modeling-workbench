% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [tbl, F_stat, p_val] = anova_oneway(X, groups)
% Input validation
arguments
    data (:,:) double
end
% ANOVA_ONEWAY  One-way analysis of variance.
%
%   [TBL, F_STAT, P_VAL] = ANOVA_ONEWAY(X, GROUPS)
%   X:      n×1 numeric vector of observations.
%   GROUPS: n×1 vector of group labels (categorical, cellstr, or integer).
%
%   TBL:    structure with fields:
%           .SS_between, .SS_within, .SS_total
%           .df_between, .df_within, .df_total
%           .MS_between, .MS_within
%   F_STAT: F-statistic.
%   P_VAL:  p-value from F-distribution.
%
%   Example:
%       x1 = randn(10,1) + 1;
%       x2 = randn(10,1) + 2;
%       x3 = randn(10,1) + 2.5;
%       X = [x1; x2; x3];
%       G = [ones(10,1); 2*ones(10,1); 3*ones(10,1)];
%       [tbl, F, p] = anova_oneway(X, G);
%
%   References:
%       Montgomery, D.C. (2019). Design and Analysis of Experiments, 10th ed.
%       《各类常用数学模型》第11章 方差分析

if iscategorical(groups)
    groups = cellstr(groups);
end
if iscellstr(groups)  %#ok<ISCLSTR>
    [~, ~, groups] = unique(groups);
end

group_ids = unique(groups);
k = length(group_ids);
n_total = length(X);

% Group statistics
group_means      = zeros(k, 1);
group_counts     = zeros(k, 1);
group_variances  = zeros(k, 1);

for g = 1:k
    mask = (groups == group_ids(g));
    group_counts(g) = sum(mask);
    group_means(g)  = mean(X(mask));
    group_variances(g) = var(X(mask));
end

grand_mean = mean(X);

% Sum of squares
SS_between = sum(group_counts .* (group_means - grand_mean).^2);
SS_within  = sum((group_counts - 1) .* group_variances);
SS_total   = SS_between + SS_within;

% Degrees of freedom
df_between = k - 1;
df_within  = n_total - k;
df_total   = n_total - 1;

% Mean squares
MS_between = SS_between / df_between;
MS_within  = SS_within  / df_within;

% F-statistic and p-value
F_stat = MS_between / MS_within;
p_val  = 1 - fcdf(F_stat, df_between, df_within);

% Output table
tbl = struct();
tbl.SS_between = SS_between;
tbl.SS_within  = SS_within;
tbl.SS_total   = SS_total;
tbl.df_between = df_between;
tbl.df_within  = df_within;
tbl.df_total   = df_total;
tbl.MS_between = MS_between;
tbl.MS_within  = MS_within;
tbl.group_means = group_means;
tbl.group_counts = group_counts;
tbl.grand_mean = grand_mean;
end

%% Self-test
function self_test()
% Input validation
arguments
    data (:,:) double
end
    % Test 3-group known-difference data
    rng(42, 'twister');
    x1 = randn(10,1) + 1;
    x2 = randn(10,1) + 3;
    x3 = randn(10,1) + 5;
    X = [x1; x2; x3];
    G = [ones(10,1); 2*ones(10,1); 3*ones(10,1)];
    [tbl, F, p] = anova_oneway(X, G);
    assert(F > 0, 'Test failed: F-stat should be positive.');
    assert(p < 0.01, 'Test failed: significant difference expected for well-separated groups.');
    disp('anova_oneway self-test passed.');
end
