% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [u_history, x, t, cfl_max] = pde_ftcs(u0, D, dx, dt, n_steps, options)
%% PDEFTCS  1D diffusion PDE via FTCS (Forward Time Central Space)
%  Solves ∂u/∂t = D·∂²u/∂x² with explicit finite difference.
%  Paradigm: PARADIGM-0809
%  Category: Mechanism
%  Version: v3.0.0
%  Reference: LeVeque, R.J. (2007) Finite Difference Methods for
%             Ordinary and Partial Differential Equations. SIAM.
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
%      options.seed       - RNG seed (not used here, included for API consistency)
%
%  Output:
%      u_history - Solution history (nx × n_steps+1), column j = step j-1
%      x         - Spatial grid vector
%      t         - Time vector
%      cfl_max   - CFL number D·dt/dx² (must be ≤ 0.5 for stability)

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

%% Validate boundary condition strings
bc_left_valid = any(strcmp(options.bc_left, {'dirichlet', 'neumann'}));
bc_right_valid = any(strcmp(options.bc_right, {'dirichlet', 'neumann'}));
assert(bc_left_valid, 'bc_left must be ''dirichlet'' or ''neumann''.');
assert(bc_right_valid, 'bc_right must be ''dirichlet'' or ''neumann''.');

%% CFL stability check
cfl_max = D * dt / (dx^2);
if cfl_max > 0.5
    warning('PDEFTCS:CFLViolation', ...
        'CFL = %.4f > 0.5. Solution may be unstable. Reduce dt or increase dx.', cfl_max);
end

%% Grid setup
nx = length(u0);
x = (0:nx-1)' * dx;
t = (0:n_steps)' * dt;

%% Preallocate history matrix
u_history = zeros(nx, n_steps + 1);
u_history(:, 1) = u0;
u_cur = u0;

%% Diffusion coefficient alpha = D * dt / dx^2
alpha = D * dt / (dx^2);

%% Main time-stepping loop (FTCS scheme)
for step = 1:n_steps
    u_next = u_cur;

    % Interior points: central difference in space
    % u_i^{n+1} = u_i^n + D·dt·(u_{i+1}^n - 2u_i^n + u_{i-1}^n) / dx^2
    for i = 2:(nx - 1)
        d2u_dx2 = (u_cur(i+1) - 2*u_cur(i) + u_cur(i-1)) / (dx^2);
        u_next(i) = u_cur(i) + D * dt * d2u_dx2;
    end

    % Left boundary
    switch options.bc_left
        case 'dirichlet'
            u_next(1) = options.bc_val_L;
        case 'neumann'
            % Zero-flux: du/dx=0 at boundary → u(1) = u(2)
            d2u_dx2_left = (u_cur(3) - 2*u_cur(2) + u_cur(1)) / (dx^2);
            u_next(1) = u_cur(1) + D * dt * d2u_dx2_left;
    end

    % Right boundary
    switch options.bc_right
        case 'dirichlet'
            u_next(nx) = options.bc_val_R;
        case 'neumann'
            d2u_dx2_right = (u_cur(nx) - 2*u_cur(nx-1) + u_cur(nx-2)) / (dx^2);
            u_next(nx) = u_cur(nx) + D * dt * d2u_dx2_right;
    end

    u_cur = u_next;
    u_history(:, step + 1) = u_cur;
end

%% Save results (cross-platform): save(fullfile(pwd, 'pde_ftcs_results.mat'), 'u_history', 'x', 't');

%% Numerical sanity check: ensure no NaN/Inf in final solution
assert(all(isfinite(u_history(:, end))), ...
    'PDEFTCS:NumericalFailure', ...
    'Final solution contains NaN or Inf. CFL = %.4f may be too large.', cfl_max);

%% Check mass conservation (approximate, for zero-flux boundaries)
final_mass = sum(u_history(:, end)) * dx;
initial_mass = sum(u0) * dx;
mass_change = abs(final_mass - initial_mass) / max(abs(initial_mass), 1e-10);
if mass_change > 0.1
    warning('PDEFTCS:MassLoss', ...
        'Mass change of %.2f%% detected. Check boundary conditions.', mass_change * 100);
end

%% Self-test
function self_test()
    % Known heat equation solution on [0,L] with Dirichlet BC u(0)=u(L)=0,
    % initial condition u(x,0) = sin(pi*x/L).
    % Analytical: u(x,t) = sin(pi*x/L) * exp(-D*pi^2*t/L^2)
    L = 1.0;
    D_test = 0.1;
    nx_test = 51;
    dx_test = L / (nx_test - 1);
    dt_test = 0.5 * dx_test^2 / D_test;  % CFL = 0.5 exactly
    n_steps_test = 20;

    x_test = linspace(0, L, nx_test)';
    u0_test = sin(pi * x_test / L);

    [u_hist, ~, t_vec, cfl] = pde_ftcs(u0_test, D_test, dx_test, dt_test, ...
        n_steps_test, bc_left='dirichlet', bc_right='dirichlet');

    % Compare with analytical solution at final time
    t_final = t_vec(end);
    u_analytical = sin(pi * x_test / L) * exp(-D_test * pi^2 * t_final / L^2);

    % Check accuracy at interior point x = L/2
    mid_idx = ceil(nx_test / 2);
    err = abs(u_hist(mid_idx, end) - u_analytical(mid_idx));
    assert(err < 0.01, ...
        'Self-test failed: FTCS error %.6f exceeds tolerance at x=L/2.', err);

    % Verify CFL condition is reported
    assert(abs(cfl - 0.5) < 1e-10, ...
        'Self-test failed: CFL number %.6f not as expected.', cfl);

    disp('PDEFTCS self-test passed.');
end
end
