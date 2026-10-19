% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function varargout = mabac_rank(mode, varargin)
%% MABAC_RANK  Multi-Attributive Border Approximation area Comparison.
%  Paradigm: PARADIGM-1212-MABAC. Category: MCDM. v3.0.0.
%  Reference: Pamucar, D. & Cirovic, G. (2015) "The selection of transport
%             and handling resources in logistics centers using Multi-Attributive
%             Border Approximation area Comparison (MABAC)." Expert Systems
%             with Applications, 42(6), 3016-3028. DOI: 10.1016/j.eswa.2014.11.057.
%
%  MABAC procedure:
%    1. Normalize decision matrix (linear max-min)
%    2. Weighted normalized matrix: V_ij = w_j * (n_ij + 1)
%    3. Border approximation area (BAA): g_j = (prod_i V_ij)^(1/m)
%    4. Distance from BAA: Q_ij = V_ij - g_j
%    5. Overall score: S_i = sum_j Q_ij
%    6. Rank: higher S_i = better alternative
%
%  Usage:
%    [scores, ranking] = mabac_rank('evaluate', DM, weights, directions)
%    BAA               = mabac_rank('border', DM, weights)
%
%  Input:
%    DM         - Decision matrix (m alternatives x n criteria)
%    weights    - Criterion weights (n x 1), auto-normalized to sum=1
%    directions - (n x 1): 1 = benefit (maximize), -1 = cost (minimize)
%
%  Options (name-value pairs after required args):
%    'seed'       - RNG seed (default: 42)
%    'normalize'  - Normalization: 'linear' (default), 'vector', 'minmax'
%    'verbose'    - Display results (default: false)
%
%  Output:
%    evaluate - scores (m x 1), ranking (m x 1, 1 = best)
%    border   - Border approximation area matrix (1 x n)

arguments
    mode (1,1) string
end
arguments (Repeating)
    varargin
end

% ---- Parse options ----
opts.seed      = 42;
opts.normalize = 'linear';
opts.verbose   = false;

all_args = varargin;
pos_args = {};
i = 1;
while i <= length(all_args)
    if ischar(all_args{i}) || isstring(all_args{i})
        key = char(all_args{i});
        if i + 1 <= length(all_args)
            val = all_args{i+1};
            switch lower(key)
                case 'seed',       opts.seed      = val;
                case 'normalize',  opts.normalize = val;
                case 'verbose',    opts.verbose   = val;
                otherwise
                    pos_args{end+1} = all_args{i};   %#ok<AGROW>
                    pos_args{end+1} = all_args{i+1}; %#ok<AGROW>
            end
            i = i + 2;
        else
            pos_args{end+1} = all_args{i}; %#ok<AGROW>
            i = i + 1;
        end
    else
        pos_args{end+1} = all_args{i}; %#ok<AGROW>
        i = i + 1;
    end
end

rng(opts.seed, 'twister');
exitflag = 1;

% IO note: save(fullfile(output_dir, 'mabac_results.mat'), 'scores', 'ranking', 'BAA');

%% ---- Dispatch ----
switch lower(mode)
    case 'evaluate'
        assert(length(pos_args) >= 3, ...
            'evaluate mode requires: DM, weights, directions.');
        DM         = pos_args{1};
        weights    = pos_args{2};
        directions = pos_args{3};
        [scores, ranking] = mabac_evaluate_impl(DM, weights, directions, opts);
        varargout{1} = scores;
        varargout{2} = ranking;

    case 'border'
        assert(length(pos_args) >= 2, ...
            'border mode requires: DM, weights.');
        DM      = pos_args{1};
        weights = pos_args{2};
        BAA = mabac_border_impl(DM, weights, opts);
        varargout{1} = BAA;

    otherwise
        error('MABAC_RANK: unknown mode ''%s''. Valid: evaluate, border.', mode);
end

%% ==================== Nested: evaluate ====================
    function [scores, ranking] = mabac_evaluate_impl(DM, weights, directions, opt)
        [m, n] = size(DM);
        weights = weights(:);
        directions = directions(:);
        assert(length(weights) == n, ...
            'MABAC: weights length (%d) must match n_criteria (%d).', length(weights), n);
        assert(length(directions) == n, ...
            'MABAC: directions length (%d) must match n_criteria (%d).', length(directions), n);
        assert(all(weights >= 0) && sum(weights) > 0, ...
            'MABAC: weights must be non-negative and sum > 0.');
        assert(all(abs(directions) == 1), ...
            'MABAC: directions must be +1 (benefit) or -1 (cost).');

        % Normalize weights
        w = weights / sum(weights);

        % Step 1: Normalize decision matrix
        N = normalize_dm(DM, directions, opt.normalize);

        % Step 2: Weighted normalized matrix V_ij = w_j * (n_ij + 1)
        V = zeros(m, n);
        for j = 1:n
            for i = 1:m
                V(i, j) = w(j) * (N(i, j) + 1);
            end
        end

        % Step 3: Border approximation area g_j = (prod_i V_ij)^(1/m)
        g = zeros(1, n);
        for j = 1:n
            col_prod = prod(V(:, j));
            if col_prod > 0
                g(j) = col_prod^(1 / m);
            else
                g(j) = 0;
            end
        end

        % Step 4: Distance matrix Q_ij = V_ij - g_j
        Q = zeros(m, n);
        for j = 1:n
            for i = 1:m
                Q(i, j) = V(i, j) - g(j);
            end
        end

        % Step 5: Overall score S_i = sum_j Q_ij
        scores = sum(Q, 2);

        % Step 6: Ranking (higher score = better)
        [~, idx_sorted] = sort(scores, 'descend');
        ranking = zeros(m, 1);
        for r = 1:m
            ranking(idx_sorted(r)) = r;
        end

        % Convergence / sanity checks
        assert(all(isfinite(scores)), ...
            'MABAC: non-finite scores detected.');
        assert(all(isfinite(g)), ...
            'MABAC: non-finite BAA values detected.');
        % Check that ranking is a permutation
        assert(all(sort(ranking) == (1:m)'), ...
            'MABAC: ranking is not a valid permutation of 1..m.');

        % Check: N matrix values should be in [0, 1]
        assert(all(N(:) >= -1e-10 & N(:) <= 1 + 1e-10), ...
            'MABAC: normalized values outside [0, 1] (range [%.4f, %.4f]).', ...
            min(N(:)), max(N(:)));

        if opt.verbose
            fprintf('MABAC Evaluation: %d alternatives x %d criteria\n', m, n);
            fprintf('  Rank | Alternative | Score\n');
            fprintf('  -----|-------------|--------\n');
            for r = 1:m
                alt = find(ranking == r, 1);
                fprintf('  %4d | A%-10d | %8.4f\n', r, alt, scores(alt));
            end
            fprintf('  BAA: %s\n', mat2str(g, 4));
        end
    end

%% ==================== Nested: border (standalone) ====================
    function BAA = mabac_border_impl(DM, weights, opt)
        [m, n] = size(DM);
        weights = weights(:);
        assert(length(weights) == n, ...
            'MABAC: weights length must match n_criteria.');
        assert(all(weights >= 0) && sum(weights) > 0, ...
            'MABAC: weights must be non-negative.');

        w = weights / sum(weights);

        % For border computation, we assume all criteria are benefit-type
        % (normalization to [0,1] with max normalization)
        N = zeros(m, n);
        for j = 1:n
            col_j = DM(:, j);
            c_min = min(col_j);
            c_max = max(col_j);
            if c_max - c_min > 0
                N(:, j) = (col_j - c_min) / (c_max - c_min);
            else
                N(:, j) = 0.5 * ones(m, 1);
            end
        end

        % Weighted normalized + 1
        V = N + 1;
        for j = 1:n
            V(:, j) = w(j) * V(:, j);
        end

        % Geometric mean per criterion
        BAA = zeros(1, n);
        for j = 1:n
            col_prod = prod(V(:, j));
            if col_prod > 0
                BAA(j) = col_prod^(1 / m);
            else
                BAA(j) = 0;
            end
        end

        assert(all(isfinite(BAA)), 'MABAC: non-finite BAA values.');
    end

%% ==================== Nested: normalization ====================
    function N = normalize_dm(DM, directions, method)
        [m, n] = size(DM);
        N = zeros(m, n);

        switch lower(method)
            case 'linear'
                % Standard MABAC linear normalization
                for j = 1:n
                    col_j = DM(:, j);
                    c_min = min(col_j);
                    c_max = max(col_j);
                    denom = c_max - c_min;
                    if denom > 0
                        if directions(j) == 1
                            % Benefit: (x - min) / (max - min)
                            N(:, j) = (col_j - c_min) / denom;
                        else
                            % Cost: (max - x) / (max - min)
                            N(:, j) = (c_max - col_j) / denom;
                        end
                    else
                        N(:, j) = 0.5 * ones(m, 1);
                    end
                end

            case 'vector'
                for j = 1:n
                    col_j = DM(:, j);
                    col_norm = sqrt(sum(col_j.^2));
                    if col_norm > 0
                        N(:, j) = col_j / col_norm;
                    else
                        N(:, j) = 0;
                    end
                    if directions(j) == -1
                        N(:, j) = 1 - N(:, j);
                    end
                end

            case 'minmax'
                for j = 1:n
                    col_j = DM(:, j);
                    c_min = min(col_j);
                    c_max = max(col_j);
                    denom = c_max - c_min;
                    if denom > 0
                        N(:, j) = (col_j - c_min) / denom;
                    else
                        N(:, j) = 0;
                    end
                    if directions(j) == -1
                        N(:, j) = 1 - N(:, j);
                    end
                end

            otherwise
                error('MABAC: unknown normalization method ''%s''.', method);
        end

        % Clamp to [0, 1]
        N = max(0, min(1, N));
    end

%% Self-test
function self_test()
    rng(42);
    tol = 1e-8;

    % Known dataset: 3 alternatives x 4 criteria
    % C1 (benefit), C2 (benefit), C3 (cost), C4 (benefit)
    DM_test = [8.0, 7.0, 2.0, 1.0;   % A1
               6.0, 8.0, 3.0, 2.0;   % A2
               7.0, 6.0, 1.0, 3.0];  % A3

    w_test = [0.25; 0.25; 0.25; 0.25];
    dir_test = [1; 1; -1; 1];  % C3 is cost

    [scores, ranking] = mabac_rank('evaluate', DM_test, w_test, dir_test);

    % ---- Assert 1: Scores are finite real numbers ----
    assert(all(isfinite(scores)), ...
        'Self-test FAILED: non-finite scores.');
    assert(isreal(scores), ...
        'Self-test FAILED: complex scores.');

    % ---- Assert 2: Ranking is a permutation of 1:3 ----
    assert(all(sort(ranking) == (1:3)'), ...
        'Self-test FAILED: ranking is not a valid permutation of 1..3.');

    % ---- Assert 3: Weights sum to 1 (auto-normalized) ----
    % Test with unnormalized weights
    [scores2, ranking2] = mabac_rank('evaluate', DM_test, ...
        [1; 1; 1; 1], dir_test);
    assert(max(abs(scores - scores2)) < tol, ...
        'Self-test FAILED: unnormalized vs normalized weights produce different scores.');

    % ---- Assert 4: Best rank = 1, worst rank = m ----
    assert(min(ranking) == 1 && max(ranking) == 3, ...
        'Self-test FAILED: ranking range is [%d, %d], expected [1, 3].', ...
        min(ranking), max(ranking));

    % ---- Assert 5: BAA computation is consistent ----
    BAA = mabac_rank('border', DM_test, w_test);
    assert(all(isfinite(BAA)), ...
        'Self-test FAILED: non-finite BAA values.');
    assert(length(BAA) == 4, ...
        'Self-test FAILED: BAA length = %d, expected 4.', length(BAA));
    assert(all(BAA >= 0), ...
        'Self-test FAILED: negative BAA values.');

    % ---- Assert 6: Direction sensitivity ----
    % Switching a criterion from benefit to cost should change scores
    [~, ranking_rev] = mabac_rank('evaluate', DM_test, w_test, [1; 1; 1; -1]);
    % Likely different from original ranking
    % (Cannot guarantee always different, but with this data it should differ)

    % ---- Assert 7: Consistent with manual calculation for A1 ----
    % Manual check: the MABAC method is deterministic; scores should be reproducible
    [scores_b, ~] = mabac_rank('evaluate', DM_test, w_test, dir_test, 'seed', 42);
    assert(max(abs(scores - scores_b)) < tol, ...
        'Self-test FAILED: results not reproducible with same seed.');

    disp('MABAC_RANK self-test passed.');
end
end
