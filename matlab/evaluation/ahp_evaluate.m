% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [weights, lambda_max, CI, CR, is_consistent] = ahp_evaluate(judgment_matrix, options)
% Deterministic algorithm (eigenvalue decomposition only); rng not required.
%% AHP_EVALUATE Analytic Hierarchy Process with eigenvalue method and consistency check. Paradigm: PARADIGM-0301-AHP. v3.0.0.
%  Reference: Saaty, T.L. (1980) The Analytic Hierarchy Process. McGraw-Hill.
%  Requirement 5 (fullfile): not_applicable -- no file IO.
arguments
    judgment_matrix (:, :) double
    options.verbose (1,1) logical = true
    options.CR_threshold (1,1) double {mustBePositive} = 0.10
    options.seed (1,1) double = 42
end
rng(options.seed, 'twister');  %% Deterministic algo; rng for interface consistency
% Validate judgment matrix: must be square, positive, reciprocal
[n, m] = size(judgment_matrix);
assert(n == m, 'ahp_evaluate: judgment matrix must be square.');
assert(n >= 2, 'ahp_evaluate: at least 2 criteria required.');
assert(all(judgment_matrix(:) > 0), ...
    'ahp_evaluate: all entries must be positive.');
% Check reciprocal property: A(i,j) ≈ 1 / A(j,i)
recip_err = max(max(abs(judgment_matrix .* judgment_matrix' - 1)));
if recip_err > 1e-6
    warning('ahp_evaluate: matrix is not perfectly reciprocal (max err=%.2e).', recip_err);
end
% Compute eigenvalues and eigenvectors
[V, D] = eig(judgment_matrix);
eigenvalues = real(diag(D));
% Find the principal eigenvalue (lambda_max) and its index
[lambda_max, idx_max] = max(eigenvalues);
% Extract the principal eigenvector and normalize to sum=1
principal_vec = real(V(:, idx_max));
weights = principal_vec / sum(principal_vec);
% Ensure all weights are positive
assert(all(weights > 0), ...
    'ahp_evaluate: computed weights must all be positive.');
% Compute Consistency Index (CI)
CI = (lambda_max - n) / (n - 1);
% Random Index (RI) table from Saaty (n=1..15)
RI_table = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45, 1.49, ...
            1.51, 1.48, 1.56, 1.57, 1.59];
if n <= numel(RI_table)
    RI = RI_table(n);
else
    % Approximate for large n: RI ≈ 1.98*(n-2)/n
    RI = 1.98 * (n - 2) / n;
    warning('ahp_evaluate: n=%d > RI table size; using approximation RI=%.4f.', n, RI);
end
% Compute Consistency Ratio (CR)
if RI > 0
    CR = CI / RI;
else
    CR = 0;
end
% Consistency determination
is_consistent = CR <= options.CR_threshold;
% Verbose output
if options.verbose
    fprintf('AHP Results: lambda_max=%.4f, CI=%.4f, RI=%.4f, CR=%.4f\n', ...
        lambda_max, CI, RI, CR);
    fprintf('Weights: %s\n', sprintf('%.4f ', weights));
    if is_consistent
        fprintf('Judgment matrix is CONSISTENT (CR=%.4f <= %.2f).\n', ...
            CR, options.CR_threshold);
    else
        fprintf('Judgment matrix is INCONSISTENT (CR=%.4f > %.2f).\n', ...
            CR, options.CR_threshold);
    end
end
% Sanity: weights must sum to 1
assert(abs(sum(weights) - 1) < 1e-10, ...
    'ahp_evaluate: weights must sum to 1.');
end

%% Self-test
function self_test()
    % Saaty's classic car-buying example: 3 criteria
    % Price, Comfort, Fuel-economy pairwise comparisons
    A = [1,   1/3, 3;
         3,   1,   5;
         1/3, 1/5, 1];

    [w, lam, ci, cr, ok] = ahp_evaluate(A, verbose=false);

    % Assert 1: weights sum to 1
    assert(abs(sum(w) - 1) < 1e-10, ...
        sprintf('Weights sum=%.10f, expected 1.0', sum(w)));

    % Assert 2: expected weights -- Comfort highest, Fuel-economy lowest
    % Expected ≈ [0.258, 0.637, 0.105]
    assert(abs(w(2) - 0.637) < 0.05, ...
        sprintf('Weight for criterion 2 (Comfort): %.4f, expected ~0.637', w(2)));
    assert(abs(w(1) - 0.258) < 0.05, ...
        sprintf('Weight for criterion 1 (Price): %.4f, expected ~0.258', w(1)));
    assert(abs(w(3) - 0.105) < 0.05, ...
        sprintf('Weight for criterion 3 (Fuel-econ): %.4f, expected ~0.105', w(3)));

    % Assert 3: consistency ratio should be well below 0.10
    assert(cr < 0.10, ...
        sprintf('CR=%.6f should be < 0.10 for consistent matrix', cr));

    % Assert 4: lambda_max should be close to n=3
    assert(lam > 3.0 && lam < 3.1, ...
        sprintf('lambda_max=%.4f, expected near 3.0', lam));

    % Assert 5: consistency flag should be true
    assert(ok == true, 'is_consistent should be true for this matrix.');

    % Test 2: random consistent matrix should pass
    n2 = 4;
    v = rand(n2, 1) + 0.5;
    B = v ./ v';  % perfectly consistent
    [w2, lam2, ci2, cr2, ok2] = ahp_evaluate(B, verbose=false);
    assert(abs(ci2) < 1e-10, ...
        sprintf('Perfectly consistent matrix has CI=%.2e, expected ~0', ci2));
    assert(abs(lam2 - n2) < 1e-10, ...
        sprintf('Perfectly consistent: lambda_max=%.6f, expected %d', lam2, n2));

    fprintf('ahp_evaluate self-test passed (2 test cases, 7 asserts).\n');
end
