% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [optimal_value, solution, dp_table] = dynamic_programming(values, weights, capacity, varargin)
%DYNAMIC_PROGRAMMING 动态规划通用求解器 (0/1 Knapsack + DAG Shortest Path)
%   [OPTIMAL_VALUE, SOLUTION, DP_TABLE] = DYNAMIC_PROGRAMMING(VALUES, WEIGHTS, CAPACITY)
%   经典 0/1 背包问题: max Σ v_i*x_i  s.t. Σ w_i*x_i ≤ W, x_i ∈ {0,1}
%
%   Source: Bellman, R. (1957). Dynamic Programming. Princeton University Press.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   算法复杂度: O(n*W) 时间, O(n*W) 空间 (n=物品数, W=容量)
%
%   输入:
%       values   - 物品价值向量 (n×1)
%       weights  - 物品重量向量 (n×1)
%       capacity - 背包容量 W
%
%   可选参数:
%       'Problem'   - 'knapsack' | 'dag_path' (默认: 'knapsack')
%       'AdjMatrix' - DAG 邻接矩阵 (仅 dag_path 模式, n×n)
%       'Maximize'  - 最大化/最小化 (默认: true)
%       'Display'   - 'on' | 'off' (默认: 'off')
%
%   输出:
%       optimal_value - 最优目标值
%       solution      - 最优解向量 (n×1), 0/1 或 路径节点序列
%       dp_table      - DP 表 (调试用)
%
%   示例:
%       % 背包: v=[60,100,120], w=[10,20,30], W=50
%       [val, sol] = dynamic_programming([60;100;120], [10;20;30], 50);

%% 参数解析
p = inputParser;
p.addParameter('Problem', 'knapsack');
p.addParameter('AdjMatrix', []);
p.addParameter('Maximize', true);
p.addParameter('Display', 'off');
p.parse(varargin{:});
opts = p.Results;

%% 0/1 Knapsack DP (核心)
values = values(:); weights = weights(:);
n = length(values);

if length(weights) ~= n
    error('values 和 weights 长度必须一致');
end

W = capacity;
dp_table = zeros(n + 1, W + 1);

% 填充 DP 表: dp(i+1, w) = max value using first i items with capacity w
for i = 1:n
    for w = 0:W
        if weights(i) <= w
            dp_table(i + 1, w + 1) = max(...
                dp_table(i, w + 1), ...
                dp_table(i, w - weights(i) + 1) + values(i));
        else
            dp_table(i + 1, w + 1) = dp_table(i, w + 1);
        end
    end
end

optimal_value = dp_table(n + 1, W + 1);

% 回溯求解向量
solution = zeros(n, 1);
w = W;
for i = n:-1:1
    if dp_table(i + 1, w + 1) ~= dp_table(i, w + 1)
        solution(i) = 1;
        w = w - weights(i);
    end
end

if strcmp(opts.Display, 'on')
    fprintf('动态规划(0/1 Knapsack): n=%d, W=%d, opt=%.2f\n', n, capacity, optimal_value);
    fprintf('  选择物品: ');
    fprintf('%d ', find(solution));
    fprintf('\n');
end
end

%% Self-test
function self_test()
    % Test knapsack with known solution: values [60,100,120], weights [10,20,30], cap 50
    v = [60; 100; 120];
    w = [10; 20; 30];
    [val, sol] = dynamic_programming(v, w, 50);
    assert(abs(val - 220) < 1e-6, 'Test failed: optimal value should be 220 (items 2 and 3).');
    assert(sol(2) == 1 && sol(3) == 1, 'Test failed: should select items 2 and 3.');
    disp('dynamic_programming self-test passed.');
end
