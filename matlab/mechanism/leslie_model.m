% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [years, population, age_dist] = leslie_model(N0, L, n_years, varargin)
%LESLIE_MODEL Leslie 年龄结构种群矩阵模型
%   [YEARS, POPULATION, AGE_DIST] = LESLIE_MODEL(N0, L, N_YEARS)
%   N(t+1) = L * N(t), L 为 Leslie 矩阵 (仅第一行和次对角线非零)
%
%   Source: Leslie, P.H. (1945). On the Use of Matrices in Certain
%          Population Mathematics. Biometrika, 33(3), 183-212.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       N0      - 初始各年龄段种群向量 (m×1)
%       L       - Leslie 矩阵 (m×m)
%                 L(1,:) = 各年龄生育率
%                 L(i+1,i) = 各年龄存活率
%       n_years - 模拟年数
%
%   可选参数:
%       'Display' - 'on' | 'off' (默认: 'on')
%
%   输出:
%       years      - 年份向量 (0..n_years)
%       population - 各年总种群 (n_years+1 × 1)
%       age_dist   - 各年年龄分布 (n_years+1 × m)
%
%   示例:
%       % 3 年龄段: 幼年(0-1岁), 青年(1-2岁), 成年(2-3岁)
%       L = [0 2 3; 0.5 0 0; 0 0.8 0];  % 生育率+存活率
%       N0 = [100; 50; 30];
%       [years, pop] = leslie_model(N0, L, 20);

%% 依赖检查 (仅 MATLAB 内置)

m = length(N0);
if ~all(size(L) == [m, m])
    error('Leslie 矩阵必须是 %d×%d, 与初始向量 N0 维数匹配', m, m);
end

%% 参数解析
p = inputParser;
p.addParameter('Display', 'on');
p.parse(varargin{:});
opts = p.Results;

%% 迭代求解 (核心 ≤ 50 行)
years = (0:n_years)';
age_dist = zeros(n_years + 1, m);
population = zeros(n_years + 1, 1);

N = N0(:);
age_dist(1, :) = N';
population(1) = sum(N);

for t = 1:n_years
    N = L * N;
    age_dist(t + 1, :) = N';
    population(t + 1) = sum(N);
end

%% 主导特征值分析 (长期增长率)
eig_vals = eig(L);
lambda1 = max(abs(eig_vals));  % 谱半径 = 长期增长率

%% 输出
if strcmp(opts.Display, 'on')
    fprintf('Leslie: %d年模拟, 初种群=%.0f, 末种群=%.0f\n', ...
            n_years, population(1), population(end));
    fprintf('  主导特征值 λ1=%.4f ', lambda1);
    if lambda1 > 1.001
        fprintf('(持续增长)\n');
    elseif lambda1 < 0.999
        fprintf('(趋于灭绝)\n');
    else
        fprintf('(稳定种群)\n');
    end
end
end

%% Self-test
function self_test()
    % Test with 2-age known Leslie matrix
    L = [0 2; 0.5 0];
    N0 = [100; 50];
    [years, pop, age_dist] = leslie_model(N0, L, 5, 'Display', 'off');
    assert(length(years) == 6, 'Test failed: should have 6 time points (0..5).');
    assert(length(pop) == 6, 'Test failed: pop should have 6 entries.');
    % First step: L*N0 = [0*100+2*50=100; 0.5*100+0*50=50]
    assert(abs(pop(2) - 150) < 1e-6, 'Test failed: year 1 population should be 150.');
    disp('leslie_model self-test passed.');
end
n%% Reproducibility
rng(42, 'twister');
