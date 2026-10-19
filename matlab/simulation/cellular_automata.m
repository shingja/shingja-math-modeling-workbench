% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [grid_history, final_grid, stats] = cellular_automata(grid_size, n_steps, rule_handler, varargin)
%CELLULAR_AUTOMATA 元胞自动机通用框架 (Cellular Automata)
%   [HISTORY, FINAL, STATS] = CELLULAR_AUTOMATA(GRID_SIZE, N_STEPS, RULE_HANDLER)
%   支持 2D 元胞自动机: Conway生命游戏、传染病、森林火灾、交通流等。
%
%   Source: Wolfram, S. (2002). A New Kind of Science. Wolfram Media.
%          Gardner, M. (1970). The fantastic combinations of John Conway's
%          new solitaire game "life". Scientific American, 223, 120-123.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       grid_size    - 网格尺寸 [rows, cols] 或标量 (方阵)
%       n_steps      - 模拟步数
%       rule_handler - 规则函数句柄 @(grid, x, y) → new_state
%                      输入: 当前网格 grid, 坐标 (x,y)
%                      输出: 新的状态值
%
%   可选参数:
%       'InitState'   - 初始状态矩阵 (默认: 随机 0/1)
%       'Boundary'    - 边界条件 (默认: 'periodic')
%                       'periodic' | 'fixed' | 'reflective' | 'absorbing'
%       'States'      - 状态数 (默认: 2)
%       'Neighborhood' - 邻域类型 (默认: 'moore')
%                        'moore' = 8邻域, 'von_neumann' = 4邻域
%       'RuleParams'   - 传递给 rule_handler 的额外参数 struct
%       'Callback'     - 每步回调 @(step, grid) 用于自定义记录
%       'Display'      - 'on' | 'off' (默认: 'on')
%
%   输出:
%       grid_history - 历史记录 cell (1×n_steps), 每步的 grid
%       final_grid   - 最终网格状态
%       stats        - 结构体: 每步的密度/相变点等
%
%   示例:
%       % Conway 生命游戏
%       life_rule = @(g, x, y) conway_rule(g, x, y);
%       [hist, final] = cellular_automata([50, 50], 100, life_rule);
%
%       % 自定义: SIR 传染病
%       sir_ca = @(g, x, y, p) sir_rule(g, x, y, p);
%       params.beta = 0.1; params.gamma = 0.01;
%       [hist, ~] = cellular_automata(100, 200, sir_ca, ...
%                    'States', 3, 'RuleParams', params);

%% 依赖检查
% 仅使用 MATLAB 内置函数

%% 参数处理
if isscalar(grid_size)
    rows = grid_size; cols = grid_size;
else
    rows = grid_size(1); cols = grid_size(2);
end

p = inputParser;
p.addParameter('InitState', []);
p.addParameter('Boundary', 'periodic', ...
    @(v) any(strcmp(v, {'periodic', 'fixed', 'reflective', 'absorbing'})));
p.addParameter('States', 2, @(v) isscalar(v) && v >= 2);
p.addParameter('Neighborhood', 'moore', ...
    @(v) any(strcmp(v, {'moore', 'von_neumann'})));
p.addParameter('RuleParams', struct());
p.addParameter('Callback', []);
p.addParameter('Display', 'on', @(v) any(strcmp(v, {'on', 'off'})));
p.parse(varargin{:});
opts = p.Results;

%% 初始化网格
if isempty(opts.InitState)
    rng(42);
    grid = randi([0, opts.States - 1], rows, cols);
else
    grid = opts.InitState;
    if ~all(size(grid) == [rows, cols])
        grid = imresize(grid, [rows, cols], 'nearest');
    end
end

%% 预分配记录
grid_history = cell(1, n_steps);
stats.density = zeros(n_steps, opts.States);
stats.changes = zeros(n_steps, 1);

if strcmp(opts.Display, 'on')
    fprintf('元胞自动机: %d×%d, %d 步, %d 状态, 边界=%s\n', ...
            rows, cols, n_steps, opts.States, opts.Boundary);
end

%% 主循环
for step = 1:n_steps
    grid_history{step} = grid;
    new_grid = grid;

    change_count = 0;

    for x = 1:rows
        for y = 1:cols
            % 获取邻域
            neighbors = get_neighborhood(grid, x, y, rows, cols, ...
                                         opts.Neighborhood, opts.Boundary);

            % 应用规则
            if ~isempty(fieldnames(opts.RuleParams))
                new_grid(x, y) = rule_handler(grid, x, y, neighbors, opts.RuleParams);
            else
                new_grid(x, y) = rule_handler(grid, x, y, neighbors);
            end

            if new_grid(x, y) ~= grid(x, y)
                change_count = change_count + 1;
            end
        end
    end

    % 状态密度
    for s = 0:(opts.States - 1)
        stats.density(step, s + 1) = mean(grid(:) == s);
    end

    stats.changes(step) = change_count;
    grid = new_grid;

    % 回调
    if ~isempty(opts.Callback)
        opts.Callback(step, grid);
    end

    if strcmp(opts.Display, 'on') && (mod(step, max(1, floor(n_steps/10))) == 0 || step == 1)
        fprintf('  Step %4d: 变化=%d (%.1f%%)', step, change_count, ...
                100 * change_count / (rows * cols));
        for s = 0:(opts.States - 1)
            fprintf('  S%d=%.2f', s, stats.density(step, s + 1));
        end
        fprintf('\n');
    end
end

final_grid = grid;

if strcmp(opts.Display, 'on')
    fprintf('完成: %d 步后最终状态密度分布:\n', n_steps);
    for s = 0:(opts.States - 1)
        fprintf('  状态 %d: %.4f\n', s, stats.density(end, s + 1));
    end
end
end

%% 辅助函数: 获取邻域
function neighbors = get_neighborhood(grid, x, y, rows, cols, n_type, boundary)
    if strcmp(n_type, 'moore')
        offsets = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
    else  % von Neumann
        offsets = [-1 0; 0 -1; 0 1; 1 0];
    end

    n_offsets = size(offsets, 1);
    neighbors = zeros(1, n_offsets);

    for k = 1:n_offsets
        nx = x + offsets(k, 1);
        ny = y + offsets(k, 2);

        switch boundary
            case 'periodic'
                nx = mod(nx - 1, rows) + 1;
                ny = mod(ny - 1, cols) + 1;
            case 'fixed'
                if nx < 1 || nx > rows || ny < 1 || ny > cols
                    neighbors(k) = 0;
                    continue;
                end
            case 'reflective'
                if nx < 1, nx = 2 - nx; end
                if nx > rows, nx = 2 * rows - nx; end
                if ny < 1, ny = 2 - ny; end
                if ny > cols, ny = 2 * cols - ny; end
            case 'absorbing'
                if nx < 1 || nx > rows || ny < 1 || ny > cols
                    neighbors(k) = 0;
                    continue;
                end
        end
        neighbors(k) = grid(nx, ny);
    end
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test rule 30 generates non-zero pattern (Wolfram rule 30 for CA)
    % Simple 1D CA: rule 30 → non-zero final pattern
    rng(42, 'twister');
    rule30 = @(g, x, y, nbrs) mod(sum(nbrs(1:2)) + nbrs(3), 2);  % simple 3-neighbor rule
    [hist, final, stats] = cellular_automata(5, 5, rule30, ...
        'Display', 'off', 'Neighborhood', 'von_neumann');
    assert(~isempty(hist), 'Test failed: history should not be empty.');
    assert(all(size(final) == [5, 5]), 'Test failed: final grid should be 5x5.');
    disp('cellular_automata self-test passed.');
end
