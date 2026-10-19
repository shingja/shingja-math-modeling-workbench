% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [diag, exitflag] = numerical_diagnostics(A, b, x, opts)
% NUMERICAL_DIAGNOSTICS Condition number, residual, rank deficiency check. v3.0.0.
%   Input: A (matrix), b (RHS vector), x (computed solution).
%   Output: diag(struct), exitflag(0=OK, 1=warnings, -1=error).
arguments
    A (:,:) double
    b (:,1) double
    x (:,1) double
    opts.tol_cond (1,1) double = 1e12
    opts.tol_residual (1,1) double = 1e-6
    opts.tol_rank_deficiency (1,1) double = 0.1
    opts.verbose (1,1) logical = true
end

rng(42, 'twister');
exitflag = 0;
diag = struct();
warnings = {};

try
    %% 1. Matrix dimensions check
    [m, n] = size(A);
    diag.m = m;
    diag.n = n;
    diag.is_square = (m == n);
    if length(b) ~= m || length(x) ~= n
        exitflag = -1;
        diag.error = 'Dimension mismatch: A is %dx%d, b is %dx1, x is %dx1';
        return;
    end
    assert(m >= n, 'Underdetermined system: m=%d < n=%d', m, n);

    %% 2. Condition number
    if diag.is_square
        s = svd(A);
        diag.cond = s(1) / s(end);
        diag.singular_values = s;
    else
        [~, S_diag, ~] = svd(A, 'econ');
        svals = diag(S_diag);
        diag.cond = svals(1) / svals(end);
        diag.singular_values = svals;
    end
    if diag.cond > opts.tol_cond
        exitflag = 1;
        warnings{end+1} = sprintf('Ill-conditioned: cond=%.2e > tol=%.2e', ...
            diag.cond, opts.tol_cond);
    end
    diag.is_well_conditioned = (diag.cond <= opts.tol_cond);

    %% 3. Rank check
    rank_tol = max(size(A)) * eps(diag.singular_values(1));
    diag.rank = sum(diag.singular_values > rank_tol);
    diag.rank_deficient = (diag.rank < min(m, n));
    if diag.rank_deficient
        exitflag = 1;
        warnings{end+1} = sprintf('Rank deficient: rank=%d < min(m,n)=%d', ...
            diag.rank, min(m, n));
    end

    %% 4. Residual norm
    diag.residual = b - A * x;
    diag.residual_norm_2 = norm(diag.residual, 2);
    diag.residual_norm_inf = norm(diag.residual, Inf);
    diag.relative_residual = diag.residual_norm_2 / (norm(b, 2) + eps);
    if diag.residual_norm_2 > opts.tol_residual * (norm(b, 2) + 1)
        exitflag = 1;
        warnings{end+1} = sprintf('High residual: ||r||_2=%.2e > tol=%.2e', ...
            diag.residual_norm_2, opts.tol_residual);
    end
    diag.residual_acceptable = ...
        (diag.residual_norm_2 <= opts.tol_residual * (norm(b, 2) + 1));

    %% 5. Numerical null-space check
    if diag.rank < n
        [~, ~, V_mat] = svd(A, 'econ');
        null_basis = V_mat(:, diag.rank+1:end);
        diag.null_space_dim = size(null_basis, 2);
        diag.null_space_orthogonality = norm(A * null_basis, 'fro');
    else
        diag.null_space_dim = 0;
        diag.null_space_orthogonality = 0;
    end

    %% 6. Backward error estimate
    % ||Ax - b|| / (||A|| * ||x||)
    diag.backward_error = diag.residual_norm_2 / ...
        (norm(A, 'fro') * norm(x, 2) + eps);

    %% 7. Forward error bound
    if diag.is_well_conditioned
        diag.forward_error_bound = diag.cond * diag.backward_error;
    else
        diag.forward_error_bound = Inf;
    end

catch ME
    exitflag = -1;
    diag.error = ME.message;
    if isempty(warnings)
        warnings{1} = 'Computation failed.';
    end
end

diag.warnings = warnings;
diag.n_warnings = length(warnings);

if opts.verbose && exitflag == 1
    for i = 1:length(warnings)
        fprintf('[numerical_diagnostics] Warning: %s\n', warnings{i});
    end
end
if exitflag == 0 && opts.verbose
    fprintf('[numerical_diagnostics] All diagnostics OK.\n');
end

%% Self-test
function self_test()
    fprintf('=== numerical_diagnostics self-test ===\n');
    % Test 1: well-conditioned matrix
    A1 = eye(5);
    x_true = ones(5, 1);
    b1 = A1 * x_true;
    [d1, ef1] = numerical_diagnostics(A1, b1, x_true, ...
        struct('verbose', false));
    assert(ef1 == 0, 'Well-conditioned: exitflag should be 0');
    assert(abs(d1.cond - 1) < 1e-10, ...
        'Identity matrix cond should be ~1, got %.2e', d1.cond);
    assert(d1.rank == 5, 'Identity matrix rank should be 5');
    assert(d1.residual_norm_2 < 1e-10, 'Residual should be near zero');
    assert(~d1.rank_deficient, 'Identity should not be rank-deficient');
    fprintf('  Test 1 (well-conditioned) passed.\n');

    % Test 2: ill-conditioned matrix (Hilbert 5x5)
    A2 = hilb(5);
    x_true2 = ones(5, 1);
    b2 = A2 * x_true2;
    % Compute a deliberately perturbed solution to see the effect
    x_perturbed = A2 \ b2;
    [d2, ef2] = numerical_diagnostics(A2, b2, x_perturbed, ...
        struct('verbose', false));
    assert(d2.cond > 1e4, 'Hilbert(5) should be ill-conditioned, cond=%.2e', d2.cond);
    assert(ef2 == 1, 'Ill-conditioned: exitflag should be 1, got %d', ef2);
    assert(~d2.is_well_conditioned, 'Hilbert should be flagged ill-conditioned');
    fprintf('  Test 2 (ill-conditioned) passed.\n');

    disp('numerical_diagnostics self-test passed.');
end
end
