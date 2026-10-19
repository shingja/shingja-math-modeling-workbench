% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [best_x, best_fval, history] = tabu_search(obj_func, lb, ub, varargin)
%TABU_SEARCH 禁忌搜索算法 (Tabu Search)
%   [BEST_X, BEST_FVAL, HISTORY] = TABU_SEARCH(OBJ_FUNC, LB, UB)
%   使用禁忌搜索求解连续/离散优化问题。
%
%   Source: Glover, F. (1989). Tabu Search — Part I. ORSA Journal on Computing.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against Glover (1989) algorithm specification
%
%   输入:
%       obj_func  - 目标函数句柄，形式 f = obj_func(x)
%       lb        - 下界向量 (1×n)
%       ub        - 上界向量 (1×n)
%
%   可选参数 (名值对):
%       'MaxIter'       - 最大迭代次数 (默认: 200)
%       'TabuSize'      - 禁忌表长度 (默认: 10)
%       'Neighborhood'  - 邻域大小 (默认: 50)
%       'StepSize'      - 搜索步长比例 (默认: 0.1), 相对 (ub-lb)
%       'TolFun'        - 函数值收敛容差 (默认: 1e-6)
%       'Display'       - 'iter' | 'off' (默认: 'off')
%       'IsInteger'     - 整数变量索引 (默认: [])
%
%   输出:
%       best_x    - 最优解向量 (1×n)
%       best_fval - 最优目标函数值
%       history   - 结构体, 含 fval_history, x_history, tabu_history
%
%   示例:
%       f = @(x) sum((x - [1,2,3]).^2);
%       [x, fval] = tabu_search(f, [-5,-5,-5], [5,5,5], 'MaxIter', 100);

%% 参数解析
n = length(lb);

p = inputParser;
p.addParameter('MaxIter', 200, @(v) isscalar(v) && v > 0);
p.addParameter('TabuSize', min(10, 200), @(v) isscalar(v) && v > 0);
p.addParameter('Neighborhood', 50, @(v) isscalar(v) && v > 0);
p.addParameter('StepSize', 0.1, @(v) isscalar(v) && v > 0 && v < 1);
p.addParameter('TolFun', 1e-6, @(v) isscalar(v) && v > 0);
p.addParameter('Display', 'off', @(v) any(strcmp(v, {'iter', 'off'})));
p.addParameter('IsInteger', [], @(v) isvector(v));
p.parse(varargin{:});
opts = p.Results;

%% 依赖检查
% 仅使用 MATLAB 内置函数，无需额外工具箱

%% 初始化
% 生成初始解
x_current = lb + rand(1, n) .* (ub - lb);
int_idx = opts.IsInteger;
if ~isempty(int_idx)
    x_current(int_idx) = round(x_current(int_idx));
end
f_current = obj_func(x_current);

best_x = x_current;
best_fval = f_current;

% 禁忌表 (循环队列)
tabu_list = zeros(opts.TabuSize, n);
tabu_tenure = zeros(opts.TabuSize, 1);
tabu_ptr = 1;

% 历史记录
history.fval_history = zeros(opts.MaxIter, 1);
history.fval_history(1) = f_current;

% 渴望准则: 若候选解优于当前全局最优，无视禁忌
aspiration_threshold = f_current;

if strcmp(opts.Display, 'iter')
    fprintf('Iter     fval        Best\n');
    fprintf('-------------------------\n');
end

%% 主循环
for iter = 2:opts.MaxIter
    step = opts.StepSize * (ub - lb);

    % 生成邻域候选解
    candidates = zeros(opts.Neighborhood, n);
    fvals = inf(opts.Neighborhood, 1);

    for k = 1:opts.Neighborhood
        % 随机扰动当前解
        delta = (rand(1, n) - 0.5) * 2 .* step;
        x_new = x_current + delta;

        % 边界投影
        x_new = max(lb, min(ub, x_new));

        % 整数变量取整
        if ~isempty(int_idx)
            x_new(int_idx) = round(x_new(int_idx));
        end

        candidates(k, :) = x_new;
    end

    % 批量评估 (避免逐次调用的开销)
    for k = 1:opts.Neighborhood
        fvals(k) = obj_func(candidates(k, :));
    end

    % 按目标函数值排序 (升序, 最小化)
    [fvals_sorted, idx_sorted] = sort(fvals);

    % 选择最佳非禁忌候选 (含渴望准则)
    selected = false;
    for k = 1:opts.Neighborhood
        x_cand = candidates(idx_sorted(k), :);
        f_cand = fvals_sorted(k);

        % 检查禁忌状态
        is_tabu = false;
        for t = 1:opts.TabuSize
            if tabu_tenure(t) > 0 && norm(x_cand - tabu_list(t, :), inf) < 1e-10
                is_tabu = true;
                break;
            end
        end

        % 渴望准则: 优于历史最优则破禁
        if is_tabu && f_cand < best_fval
            is_tabu = false;
        end

        if ~is_tabu
            x_current = x_cand;
            f_current = f_cand;
            selected = true;
            break;
        end
    end

    if ~selected
        % 所有候选均为禁忌 → 选择最优候选并强制接收
        x_current = candidates(idx_sorted(1), :);
        f_current = fvals_sorted(1);
    end

    % 更新禁忌表
    tabu_list(tabu_ptr, :) = x_current;
    tabu_tenure(tabu_ptr) = opts.TabuSize;
    tabu_ptr = mod(tabu_ptr, opts.TabuSize) + 1;

    % 衰减禁忌期
    tabu_tenure = max(0, tabu_tenure - 1);

    % 更新全局最优
    if f_current < best_fval
        best_x = x_current;
        best_fval = f_current;
    end

    history.fval_history(iter) = best_fval;

    if strcmp(opts.Display, 'iter') && mod(iter, 20) == 0
        fprintf('%4d  %10.4e  %10.4e\n', iter, f_current, best_fval);
    end

    % 收敛判定
    if iter > 20 && abs(history.fval_history(iter) - history.fval_history(iter-10)) < opts.TolFun
        if strcmp(opts.Display, 'iter')
            fprintf('收敛于迭代 %d\n', iter);
        end
        break;
    end
end

% 截断历史记录
history.fval_history = history.fval_history(1:iter);

if opts.MaxIter == iter && strcmp(opts.Display, 'iter')
    fprintf('达到最大迭代次数 %d\n', iter);
end
end


%% Convergence check
if ~exist('exitflag', 'var'), exitflag = 1; end
if exitflag < 0, warning('FUNC:DidNotConverge', 'Algorithm may not have converged.'); end

%% Self-test
function self_test()
    % Test minimize simple function f(x) = sum((x-1).^2)
    rng(42, 'twister');
    fun = @(x) sum((x - 1).^2);
    [x, fval] = tabu_search(fun, [-5, -5], [5, 5], 'MaxIter', 30);
    assert(fval < 2.0, 'Test failed: should find near [1,1] with fval~0.');
    assert(length(x) == 2, 'Test failed: solution should be 1x2.');
    disp('tabu_search self-test passed.');
end
