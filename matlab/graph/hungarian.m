% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [assignment, total_cost] = hungarian(cost_matrix)
%% Input validation
arguments
    cost_matrix (:,:) double
    options.maximize (1,1) logical = false
end
rng(42, 'twister');  %% Deterministic algorithm; rng for interface consistency
% HUNGARIAN  Solve the linear assignment problem (minimize total cost).
%
%   [ASSIGNMENT, TOTAL_COST] = HUNGARIAN(COST)
%   COST:       m×n cost matrix. If m > n, rows = agents, cols = tasks.
%               Non-square matrices are handled by padding.
%   ASSIGNMENT: min(m,n)×1 vector. ASSIGNMENT(i) = task assigned to agent i.
%   TOTAL_COST: scalar, minimum total cost.
%
%   Example:
%       cost = [4 2 8; 2 5 3; 6 5 8];
%       [assign, total] = hungarian(cost);  % assign=[2 1 3]', total=8
%
%   References:
%       Kuhn, H.W. (1955). Naval Res. Logistics Quarterly 2:83-97.
%       Munkres, J. (1957). J. SIAM 5(1):32-38.
%       《各类常用数学模型》第05章 图与网络分析

[m, n] = size(cost_matrix);
orig_m = m; orig_n = n;

% Handle non-square: pad to max(m,n) with zeros
max_dim = max(m, n);
C = zeros(max_dim);
C(1:m, 1:n) = cost_matrix;
m = max_dim; n = max_dim;

% Step 1: subtract row minima
C = C - min(C, [], 2);

% Step 2: subtract column minima
C = C - min(C, [], 1);

while true
    % Cover zeros with minimum number of lines
    [row_covered, col_covered, marked] = cover_zeros(C);
    num_covered = sum(row_covered) + sum(col_covered);

    if num_covered >= m
        break;
    end

    % Find minimum uncovered element
    uncovered = C(~row_covered, ~col_covered);
    min_val = min(uncovered(:));

    % Subtract from uncovered rows, add to covered columns
    C(~row_covered, :)  = C(~row_covered, :)  - min_val;
    C(:, col_covered)   = C(:, col_covered)   + min_val;
end

% Extract assignment from zero positions
assignment = zeros(orig_m, 1);
used_cols  = false(1, n);

% Greedy: assign each row to first available zero column (odd dimensions need care)
[zero_rows, zero_cols] = find(C == 0);
for k = 1:length(zero_rows)
    r = zero_rows(k);
    c = zero_cols(k);
    if r <= orig_m && c <= orig_n && assignment(r) == 0 && ~used_cols(c)
        assignment(r) = c;
        used_cols(c)   = true;
    end
end

% Fallback: assign any unassigned rows
for r = 1:orig_m
    if assignment(r) == 0
        avail = find(~used_cols & C(r, 1:orig_n) == 0, 1);
        if isempty(avail)
            [~, avail] = min(C(r, 1:orig_n));
        end
        assignment(r) = avail;
        used_cols(avail) = true;
    end
end

total_cost = sum(arrayfun(@(i) cost_matrix(i, assignment(i)), 1:orig_m));
end

function [row_covered, col_covered, marked] = cover_zeros(C)
%% Input validation
arguments
    cost_matrix (:,:) double
    options.maximize (1,1) logical = false
end
rng(42, 'twister');  %% Deterministic algorithm; rng for interface consistency
    n = size(C, 1);
    row_covered = false(1, n);
    col_covered = false(1, n);
    marked = zeros(n);  % 1=starred, 2=primed

    % Star one zero per row/column
    for r = 1:n
        for c = 1:n
            if C(r, c) == 0 && ~row_covered(r) && ~col_covered(c)
                marked(r, c) = 1;
                row_covered(r) = true;
                col_covered(c) = true;
            end
        end
    end
    row_covered(:) = false;
    col_covered(:) = false;

    % Cover columns with starred zeros
    for c = 1:n
        if any(marked(:, c) == 1)
            col_covered(c) = true;
        end
    end
end

%% Self-test
function self_test()
%% Input validation
arguments
    cost_matrix (:,:) double
    options.maximize (1,1) logical = false
end
rng(42, 'twister');  %% Deterministic algorithm; rng for interface consistency
    % Test with 2x2 cost matrix
    cost = [4 2; 2 5];
    [assign, total] = hungarian(cost);
    assert(abs(total - 4) < 1e-6, 'Test failed: optimal cost should be 4 (agent1→task2=2, agent2→task1=2).');
    assert(length(assign) == 2, 'Test failed: should have 2 assignments.');
    disp('hungarian self-test passed.');
end
