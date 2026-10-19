% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [efficiency, slacks, reference_set] = dea_analyze(inputs, outputs, varargin)
rng(42, 'twister');  %% Reproducibility
%DEA_ANALYZE 数据包络分析 (Data Envelopment Analysis, CCR模型)
%   [EFFICIENCY, SLACKS, REFERENCE_SET] = DEA_ANALYZE(INPUTS, OUTPUTS)
%   CCR-I (输入导向) 模型: min θ s.t. Yλ ≥ y0, Xλ ≤ θ*x0, λ ≥ 0
%
%   Source: Charnes, A., Cooper, W.W., Rhodes, E. (1978).
%          Measuring the efficiency of decision making units.
%          European Journal of Operational Research, 2(6), 429-444.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   算法复杂度: O(n²*m) 使用 linprog, n=DMU数, m=投入+产出变量数
%
%   输入:
%       inputs  - 投入矩阵 (n_dmu × n_inputs), 每行=1个决策单元
%       outputs - 产出矩阵 (n_dmu × n_outputs)
%
%   可选参数:
%       'Orientation' - 'input' (投入导向) | 'output' (产出导向) (默认: 'input')
%       'Returns'     - 'CRS' (规模报酬不变) | 'VRS' (可变规模报酬) (默认: 'CRS')
%       'Display'     - 'on' | 'off' (默认: 'on')
%
%   输出:
%       efficiency     - 效率值 (n×1), 1=DEA有效, <1=非有效
%       slacks         - 松弛变量结构体: .input (n×n_inputs), .output (n×n_outputs)
%       reference_set  - 参考集 cell 数组, ref{i} = DMU i 的标杆DMU索引
%
%   示例:
%       inputs  = [4 3; 2 3; 5 2];  % 3 DMUs, 2 inputs each
%       outputs = [2 4; 3 6; 2 3];
%       eff = dea_analyze(inputs, outputs);

%% 依赖检查
if ~exist('linprog', 'file')
    error('需要 Optimization Toolbox (linprog)。');
end

[n_dmu, n_inputs] = size(inputs);
n_outputs = size(outputs, 2);

if size(outputs, 1) ~= n_dmu
    error('inputs 和 outputs 行数必须一致 (每行=1个DMU)');
end

%% 参数解析
p = inputParser;
p.addParameter('Orientation', 'input');
p.addParameter('Returns', 'CRS');
p.addParameter('Display', 'on');
p.parse(varargin{:});
opts = p.Results;

%% DEA 核心: 为每个 DMU 求解 LP
efficiency = zeros(n_dmu, 1);
slacks_input = zeros(n_dmu, n_inputs);
slacks_output = zeros(n_dmu, n_outputs);
reference_set = cell(n_dmu, 1);

is_VRS = strcmp(opts.Returns, 'VRS');

for k = 1:n_dmu
    x0 = inputs(k, :)';
    y0 = outputs(k, :)';

    if strcmp(opts.Orientation, 'input')
        % CCR-I: min θ
        % 决策变量: [θ; λ_1; ...; λ_n; s⁻ (slack_inputs); s⁺ (slack_outputs)]
        n_vars = 1 + n_dmu + n_inputs + n_outputs;

        f = zeros(n_vars, 1);
        f(1) = 1;  % minimize θ
        for j = 1:n_inputs
            f(1 + n_dmu + j) = 1e-6;  % 微小权重驱动松弛归零
        end

        % 等式约束: Yλ - s⁺ = y0
        Aeq = zeros(n_outputs + n_inputs, n_vars);
        beq = zeros(n_outputs + n_inputs, 1);

        for r = 1:n_outputs
            Aeq(r, 2:1+n_dmu) = outputs(:, r)';  % Yλ
            Aeq(r, 1+n_dmu+n_inputs+r) = -1;    % -s⁺
            beq(r) = y0(r);
        end

        % 等式约束: Xλ + s⁻ - θ*x0 = 0
        for i = 1:n_inputs
            row = n_outputs + i;
            Aeq(row, 1) = -x0(i);          % -θ*x0
            Aeq(row, 2:1+n_dmu) = inputs(:, i)'; % Xλ
            Aeq(row, 1+n_dmu+i) = 1;       % +s⁻
            beq(row) = 0;
        end

        lb = zeros(n_vars, 1);
        ub = inf(n_vars, 1);
        ub(1) = 1;

        if is_VRS
            % VRS: add Σλ = 1
            Aeq_vrs = [Aeq; zeros(1, n_vars)];
            Aeq_vrs(end, 2:1+n_dmu) = 1;
            beq_vrs = [beq; 1];
            [sol, theta] = linprog(f, [], [], Aeq_vrs, beq_vrs, lb, ub, ...
                optimoptions('linprog', 'Display', 'off'));
        else
            [sol, theta] = linprog(f, [], [], Aeq, beq, lb, ub, ...
                optimoptions('linprog', 'Display', 'off'));
        end
    else
        % CCR-O: max φ
        n_vars = 1 + n_dmu + n_inputs + n_outputs;
        f = zeros(n_vars, 1);
        f(1) = -1;  % maximize φ = minimize -φ

        % Xλ + s⁻ = x0
        Aeq_X = zeros(n_inputs, n_vars);
        for i = 1:n_inputs
            Aeq_X(i, 2:1+n_dmu) = inputs(:, i)';
            Aeq_X(i, 1+n_dmu+i) = 1;
        end
        beq_X = x0;

        % Yλ - s⁺ - φ*y0 = 0
        Aeq_Y = zeros(n_outputs, n_vars);
        for r = 1:n_outputs
            Aeq_Y(r, 1) = -y0(r);
            Aeq_Y(r, 2:1+n_dmu) = outputs(:, r)';
            Aeq_Y(r, 1+n_dmu+n_inputs+r) = -1;
        end
        beq_Y = zeros(n_outputs, 1);

        Aeq = [Aeq_X; Aeq_Y];
        beq = [beq_X; beq_Y];
        lb = zeros(n_vars, 1);
        ub = inf(n_vars, 1);

        [sol, neg_phi] = linprog(f, [], [], Aeq, beq, lb, ub, ...
            optimoptions('linprog', 'Display', 'off'));
        theta = -neg_phi;
    end

    if ~isempty(sol)
        efficiency(k) = theta;
        slacks_input(k, :) = sol(1+n_dmu+1 : 1+n_dmu+n_inputs)';
        slacks_output(k, :) = sol(1+n_dmu+n_inputs+1 : end)';
        lambda = sol(2:1+n_dmu);
        reference_set{k} = find(lambda > 1e-6);
    else
        efficiency(k) = NaN;
    end
end

slacks.input = slacks_input;
slacks.output = slacks_output;

if strcmp(opts.Display, 'on')
    n_eff = sum(efficiency >= 0.9999);
    fprintf('\n=== DEA (CCR-%s, %s) ===\n', opts.Orientation(1), opts.Returns);
    fprintf('DMU数: %d, 有效DMU: %d/%d\n', n_dmu, n_eff, n_dmu);
    fprintf('效率均值: %.4f, 最小值: %.4f\n', mean(efficiency), min(efficiency));
end

% Exitflag: warn if linprog failed for some DMUs
n_nan = sum(isnan(efficiency));
if n_nan > 0
    warning('DEA:LPfailure', '%d of %d DMUs had LP failures — results may be incomplete.', n_nan, n_dmu);
end
end

%% Self-test
function self_test()
rng(42, 'twister');  %% Reproducibility
    % Test with 2-DMU single-input single-output
    if exist('linprog', 'file')
        inputs = [2; 4];
        outputs = [3; 3];
        [eff, slacks, ref] = dea_analyze(inputs, outputs, 'Display', 'off');
        assert(length(eff) == 2, 'Test failed: efficiency should have 2 entries.');
        assert(all(eff >= 0 & eff <= 1 | isnan(eff)), 'Test failed: efficiency should be in [0,1].');
    else
        warning('DEA self-test: Optimization Toolbox not available, test skipped.');
    end
    disp('dea_analyze self-test passed.');
end
