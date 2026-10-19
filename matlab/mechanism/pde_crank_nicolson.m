% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [u_history, x, t, cfl_max] = pde_crank_nicolson(u0, D, dx, dt, n_steps, options)
%% PDECRANKNICOLSON  1D diffusion PDE via Crank-Nicolson (implicit)
%  Solves ∂u/∂t = D·∂²u/∂x² with unconditionally stable Crank-Nicolson.
%  Paradigm: PARADIGM-0809
%  Category: Mechanism
%  Version: v3.0.0
%  Reference: Crank, J. & Nicolson, P. (1947) Proc. Cambridge Phil. Soc.
%             LeVeque, R.J. (2007) Finite Difference Methods. SIAM.
%
%  Input:
%      u0       - Initial condition vector (nx × 1)
%      D        - Diffusion coefficient (scalar > 0)
%      dx       - Spatial step size
%      dt       - Time step size
%      n_steps  - Number of time steps
%
%  Options:
%      options.bc_left   - Left boundary type: 'dirichlet' (default) | 'neumann'
%      options.bc_right  - Right boundary type: 'dirichlet' (default) | 'neumann'
%      options.bc_val_L  - Left boundary value (default: 0)
%      options.bc_val_R  - Right boundary value (default: 0)
%      options.seed       - RNG seed (not used here, for API consistency)
%
%  Output:
%      u_history - Solution history (nx × n_steps+1)
%      x         - Spatial grid vector
%      t         - Time vector
%      cfl_max   - CFL number (informational — CN is unconditionally stable)

arguments
    u0 (:, 1) double
    D (1,1) double {mustBePositive}
    dx (1,1) double {mustBePositive}
    dt (1,1) double {mustBePositive}
    n_steps (1,1) double {mustBeInteger, mustBePositive}
    options.bc_left char = 'dirichlet'
    options.bc_right char = 'dirichlet'
    options.bc_val_L (1,1) double = 0
    options.bc_val_R (1,1) double = 0
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

bc_left_valid = any(strcmp(options.bc_left, {'dirichlet', 'neumann'}));
bc_right_valid = any(strcmp(options.bc_right, {'dirichlet', 'neumann'}));
assert(bc_left_valid, 'bc_left must be ''dirichlet'' or ''neumann''.');
assert(bc_right_valid, 'bc_right must be ''dirichlet'' or ''neumann''.');

%% CFL number (informational only — Crank-Nicolson is unconditionally stable)
cfl_max = D * dt / (dx^2);

%% Grid setup
nx = length(u0);
x = (0:nx-1)' * dx;
t = (0:n_steps)' * dt;

%% Preallocate history
u_history = zeros(nx, n_steps + 1);
u_history(:, 1) = u0;
u_cur = u0;

%% Parameter alpha = D*dt/(2*dx^2)
alpha = D * dt / (2 * dx^2);

%% Assemble tridiagonal system for interior points
% Crank-Nicolson: (I - A) u^{n+1} = (I + A) u^n
% where A has -alpha on sub/super-diagonal and +2*alpha on diagonal
n_int = nx - 2;
diag_lo = -alpha * ones(n_int - 1, 1);
diag_main = (1 + 2 * alpha) * ones(n_int, 1);
diag_hi = -alpha * ones(n_int - 1, 1);

%% Main time-stepping loop
for step = 1:n_steps
    % Build RHS: (I + A_explicit) on interior points
    rhs = zeros(n_int, 1);
    for k = 1:n_int
        i = k + 1;  % global index for interior point
        rhs(k) = alpha * u_cur(i-1) + (1 - 2*alpha) * u_cur(i) + alpha * u_cur(i+1);
    end

    % Adjust RHS for boundary conditions
    switch options.bc_left
        case 'dirichlet'
            rhs(1) = rhs(1) + alpha * options.bc_val_L;
        case 'neumann'
            % Zero-flux: u(0) = u(1), reflected in rhs
            rhs(1) = rhs(1) + alpha * u_cur(1);
    end

    switch options.bc_right
        case 'dirichlet'
            rhs(end) = rhs(end) + alpha * options.bc_val_R;
        case 'neumann'
            rhs(end) = rhs(end) + alpha * u_cur(nx);
    end

    % Solve tridiagonal system via Thomas algorithm (tridiag)
    u_int = tridiag_solve(diag_lo, diag_main, diag_hi, rhs);

    % Assemble full solution vector
    u_next = u_cur;
    u_next(2:nx-1) = u_int;

    % Apply boundary conditions
    switch options.bc_left
        case 'dirichlet'
            u_next(1) = options.bc_val_L;
        case 'neumann'
            u_next(1) = u_next(2);
    end

    switch options.bc_right
        case 'dirichlet'
            u_next(nx) = options.bc_val_R;
        case 'neumann'
            u_next(nx) = u_next(nx-1);
    end

    u_cur = u_next;
    u_history(:, step + 1) = u_cur;
end

%% Save results (cross-platform): save(fullfile(pwd, 'pde_cn_results.mat'), 'u_history', 'x', 't');

%% Numerical sanity check
assert(all(isfinite(u_history(:, end))), ...
    'PDECRANKNICOLSON:NumericalFailure', ...
    'Final solution contains NaN or Inf.');

%% Check convergence: mass conservation
final_mass = sum(u_history(:, end)) * dx;
initial_mass = sum(u0) * dx;
mass_change = abs(final_mass - initial_mass) / max(abs(initial_mass), 1e-10);
if mass_change > 0.1
    warning('PDECRANKNICOLSON:MassLoss', ...
        'Mass change of %.2f%% detected.', mass_change * 100);
end

%% Nested function: Thomas algorithm for tridiagonal solve
function x_sol = tridiag_solve(a, b, c, d)
    % Thomas algorithm: solve [b(1) c(1) 0 ...; a(1) b(2) c(2) ...] * x = d
    n_t = length(d);
    c_star = zeros(n_t - 1, 1);
    d_star = zeros(n_t, 1);

    % Forward sweep
    c_star(1) = c(1) / b(1);
    d_star(1) = d(1) / b(1);
    for i = 2:n_t
        denom = b(i) - a(i-1) * c_star(i-1);
        if i < n_t
            c_star(i) = c(i) / denom;
        end
        d_star(i) = (d(i) - a(i-1) * d_star(i-1)) / denom;
    end

    % Back substitution
    x_sol = zeros(n_t, 1);
    x_sol(n_t) = d_star(n_t);
    for i = n_t-1:-1:1
        x_sol(i) = d_star(i) - c_star(i) * x_sol(i+1);
    end
end

%% Self-test
function self_test()
    % Compare Crank-Nicolson with FTCS at small dt for consistency.
    % Heat equation on [0,L] with Dirichlet BC.
    L = 1.0;
    D_test = 0.1;
    nx_test = 51;
    dx_test = L / (nx_test - 1);

    % Use small dt for high accuracy
    dt_test = 0.1 * dx_test^2 / D_test;  % CFL = 0.1
    n_steps_test = 50;

    x_test = linspace(0, L, nx_test)';
    u0_test = sin(pi * x_test / L);

    % Crank-Nicolson solution
    [u_cn, ~, ~, ~] = pde_crank_nicolson(u0_test, D_test, dx_test, dt_test, ...
        n_steps_test, bc_left='dirichlet', bc_right='dirichlet');

    % FTCS solution at same resolution
    [u_ftcs, ~, ~, ~] = pde_ftcs(u0_test, D_test, dx_test, dt_test, ...
        n_steps_test, bc_left='dirichlet', bc_right='dirichlet');

    % Both should agree with analytical solution to within tolerance
    t_final = n_steps_test * dt_test;
    u_analytical = sin(pi * x_test / L) * exp(-D_test * pi^2 * t_final / L^2);

    err_cn = max(abs(u_cn(:, end) - u_analytical));
    err_ftcs = max(abs(u_ftcs(:, end) - u_analytical));

    assert(err_cn < 0.005, ...
        'Self-test failed: Crank-Nicolson max error %.6f exceeds tolerance.', err_cn);
    assert(err_ftcs < 0.005, ...
        'Self-test failed: FTCS max error %.6f exceeds tolerance.', err_ftcs);

    % Crank-Nicolson should be more accurate than FTCS (or at least comparable)
    assert(err_cn <= err_ftcs * 2, ...
        'Self-test failed: CN error %.6f significantly worse than FTCS error %.6f.', ...
        err_cn, err_ftcs);

    disp('PDECRANKNICOLSON self-test passed.');
end
end
