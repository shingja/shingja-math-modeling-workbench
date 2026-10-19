% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [basis, coeff, reconstructed, energy] = pod_deim(snapshots, options)
%% POD_DEIM  Proper Orthogonal Decomposition for model reduction
%  Paradigm: SURROGATE-005 | Category: ⑩ | Version: v3.0.0
%  Reference: Chatterjee (2000) "An introduction to the proper orthogonal
%             decomposition." Current Science 78(7):808-817.
%
%  Functions:
%    pod_basis(snapshots, energy_frac)   -> basis (truncated POD modes)
%    pod_reconstruct(basis, coeff)       -> reconstructed field

arguments
    snapshots (:, :) double            % [n_space x n_snapshots] data matrix
    options.seed (1,1) double = 42
    options.energy_frac (1,1) double {mustBeInRange(options.energy_frac, 0, 1)} = 0.999
    options.max_modes (1,1) double = -1  % max modes to keep (-1 = auto from energy)
    options.center (1,1) logical = true % subtract mean before SVD
end

rng(options.seed, 'twister');

%% --- pod_basis: compute truncated POD basis ---
[n_space, n_snap] = size(snapshots);
assert(n_space >= 1 && n_snap >= 2, 'POD:TooFewSnapshots', ...
    'Need at least 2 snapshots with positive spatial dimension.');

% Center data (subtract mean)
if options.center
    snapshot_mean = mean(snapshots, 2);
    X = snapshots - snapshot_mean;
else
    X = snapshots;
    snapshot_mean = zeros(n_space, 1);
end

% SVD decomposition
[U, S, ~] = svd(X, 'econ');
singular_values = diag(S);

% Energy fraction: keep modes that explain `energy_frac` of total variance
total_energy = sum(singular_values.^2);
cum_energy   = cumsum(singular_values.^2);
energy_ratio = cum_energy / total_energy;

% Determine truncation rank
r_energy = find(energy_ratio >= options.energy_frac, 1, 'first');
if isempty(r_energy)
    r_energy = length(singular_values);
end

if options.max_modes > 0
    r = min(r_energy, options.max_modes);
else
    r = r_energy;
end
r = max(r, 1);  % at least 1 mode

% Truncated basis
basis = U(:, 1:r);

% Energy captured
energy = struct();
energy.singular_values = singular_values;
energy.cumulative_ratio = energy_ratio;
energy.n_modes = r;
energy.energy_captured = energy_ratio(r);
energy.total_energy = total_energy;

% Numerical sanity
assert(energy.energy_captured >= options.energy_frac - 1e-10 || r == length(singular_values), ...
    'POD:InsufficientEnergy', 'Captured %.4f of energy, target was %.4f.', ...
    energy.energy_captured, options.energy_frac);

% Orthogonality check
ortho_check = basis' * basis;
assert(norm(ortho_check - eye(r), 'fro') < 1e-10, ...
    'POD:NonOrthogonal', 'POD basis is not orthonormal.');

%% --- Compute coefficients for input snapshots ---
coeff = basis' * X;

%% --- pod_reconstruct ---
reconstructed = basis * coeff;
if options.center
    reconstructed = reconstructed + snapshot_mean;
end

% Reconstruction error check
recon_error = norm(snapshots - reconstructed, 'fro') / norm(snapshots, 'fro');
assert(recon_error < 0.1 || r == min(n_space, n_snap), ...
    'POD:LargeReconError', 'Reconstruction relative error = %.4e.', recon_error);

%% Self-test
function self_test()
    fprintf('  Running pod_deim self-test...\n');
    rng(42);
    % Create known rank-2 matrix: 10x10 with 2 modes
    u1 = sin(linspace(0, pi, 10))';
    u2 = cos(linspace(0, pi, 10))';
    v1 = linspace(0, 1, 8);
    v2 = linspace(1, 0, 8);
    snapshots_mat = u1 * v1 + u2 * v2;  % 10 x 8, rank 2 exactly

    [basis, coeff, recon, energy] = pod_deim(snapshots_mat, ...
        'energy_frac', 0.999);

    % Should capture 2 modes for rank-2 matrix
    assert(energy.n_modes <= 3, ...
        'Self-test: expected <=3 modes for rank-2 matrix, got %d.', energy.n_modes);

    % Energy captured should be ~1.0
    assert(energy.energy_captured > 0.999, ...
        'Self-test: energy captured = %.6f, expected > 0.999.', energy.energy_captured);

    % Reconstruction error should be tiny
    recon_err = norm(snapshots_mat - recon, 'fro') / norm(snapshots_mat, 'fro');
    assert(recon_err < 1e-12, ...
        'Self-test: reconstruction error = %.2e too large.', recon_err);

    % Basis should be orthonormal
    ortho_err = norm(basis' * basis - eye(energy.n_modes), 'fro');
    assert(ortho_err < 1e-10, 'Self-test: basis not orthonormal.');

    fprintf('  pod_deim self-test PASSED (modes=%d, energy=%.4f%%).\n', ...
        energy.n_modes, energy.energy_captured*100);
end
end
