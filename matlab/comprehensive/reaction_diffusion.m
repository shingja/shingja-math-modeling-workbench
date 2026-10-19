% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [u_history, x, t, exitflag] = reaction_diffusion(D, r_func, u0, L_x, T_end, options)
%% REACTIONDIFFUSION 1D Reaction-Diffusion equation via FTCS scheme.
%  Solves du/dt = D * d^2u/dx^2 + R(u) on [0, L_x] with homogeneous
%  Neumann BCs and initial condition u0(x).
%  Paradigm: PARADIGM-0706
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Fisher, R.A. (1937) The wave of advance of advantageous
%             genes. Annals of Eugenics, 7(4), 355-369.
%             Murray, J.D. (2002) Mathematical Biology, 3rd Edition.
%             Springer. ISBN: 978-0387952239.
%
%  Input:
%      D       - Diffusion coefficient (scalar > 0)
%      r_func  - Reaction function handle R(u) -> scalar
%      u0      - Initial condition (function handle u0(x) or vector Nx x 1)
%      L_x     - Domain length (scalar)
%      T_end   - Final time
%
%  Options:
%      options.Nx      - Number of spatial grid points (default: 101)
%      options.dt      - Time step (auto-computed from CFL if empty)
%      options.save_every - Save solution every n steps (default: 10)
%      options.CFL     - CFL safety factor (default: 0.45)
%      options.seed    - RNG seed (default: 42)
%
%  Output:
%      u_history - Solution history (Nt_save x Nx), each row = time snapshot
%      x         - Spatial grid (1 x Nx)
%      t         - Time points saved (1 x Nt_save)
%      exitflag  - 1 = success, 0 = CFL warning, -1 = error

arguments
    D (1,1) double {mustBePositive}
    r_func (1,1) function_handle
    u0
    L_x (1,1) double {mustBePositive}
    T_end (1,1) double {mustBePositive}
    options.Nx (1,1) double {mustBeInteger, mustBePositive} = 101
    options.dt (1,1) double = []
    options.save_every (1,1) double {mustBeInteger, mustBePositive} = 10
    options.CFL (1,1) double {mustBeInRange(options.CFL, 0.05, 0.49)} = 0.45
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

%% Spatial grid
dx = L_x / (options.Nx - 1);
x = linspace(0, L_x, options.Nx)';

%% Time step
if isempty(options.dt)
    dt = options.CFL * dx^2 / (D + 1e-14);
else
    dt = options.dt;
    cfl_check = D * dt / dx^2;
    if cfl_check > 0.5
        exitflag = 0;
        warning('REACTIONDIFFUSION:CFLviolation', ...
            'CFL condition violated: D*dt/dx^2 = %.4f > 0.5.', cfl_check);
    end
end

Nt = ceil(T_end / dt);
dt = T_end / Nt;  % adjust for exact match

%% Initial condition
if isa(u0, 'function_handle')
    u = u0(x);
else
    u = u0(:);
    assert(length(u) == options.Nx, 'u0 vector must have Nx elements.');
end

%% Pre-allocate storage
N_save = ceil(Nt / options.save_every) + 1;
u_history = zeros(N_save, options.Nx);
t = zeros(1, N_save);

u_history(1, :) = u';
t(1) = 0;
save_idx = 1;

%% FTCS solver: u^{n+1} = u^n + dt * (D * d2u/dx2 + R(u^n))
% Diffusion: d^2u/dx^2 via central difference
r = D * dt / dx^2;

% Check stability (diffusion only)
if r > 0.5
    exitflag = 0;
    warning('REACTIONDIFFUSION:Unstable', ...
        'FTCS diffusion unstable: r = D*dt/dx^2 = %.4f > 0.5.', r);
end

for n = 1:Nt
    % Compute d^2u/dx^2 (2nd order central difference)
    d2u = zeros(options.Nx, 1);
    for i = 2:options.Nx-1
        d2u(i) = (u(i+1) - 2*u(i) + u(i-1)) / dx^2;
    end
    % Neumann BC: du/dx = 0 at boundaries (ghost point method)
    % d^2u/dx^2 at x=0: u_{-1} = u_1 (reflection)
    d2u(1) = 2 * (u(2) - u(1)) / dx^2;
    % d^2u/dx^2 at x=L: u_{N+1} = u_{N-1}
    d2u(options.Nx) = 2 * (u(options.Nx-1) - u(options.Nx)) / dx^2;

    % Reaction term
    R_u = zeros(options.Nx, 1);
    for i = 1:options.Nx
        R_u(i) = r_func(u(i));
    end

    % Euler step
    u_new = u + dt * (D * d2u + R_u);

    % Clip to avoid extreme values
    u_new = max(min(u_new, 1e6), -1e6);

    u = u_new;

    % Save
    if mod(n, options.save_every) == 0 || n == Nt
        save_idx = save_idx + 1;
        u_history(save_idx, :) = u';
        t(save_idx) = n * dt;
    end
end

% Trim to actual saved
u_history = u_history(1:save_idx, :);
t = t(1:save_idx);

%% Validation
if any(isnan(u_history(:)))
    exitflag = -1;
    warning('REACTIONDIFFUSION:NaN', 'NaN values in solution.');
end

%% Self-test
function self_test()
    % Fisher-KPP: du/dt = D*d2u/dx2 + r*u*(1-u/K)
    D_test = 0.1;
    r_test = 1.0;
    K_test = 1.0;
    L_test = 10.0;
    T_test = 5.0;

    % Reaction function: logistic growth
    rxn = @(u) r_test * u .* (1 - u / K_test);

    % Initial condition: step function (left side saturated)
    u0_func = @(x) K_test * (x < L_test / 4);

    [u_hist, x_grid, t_pts, ef] = reaction_diffusion(D_test, rxn, u0_func, ...
        L_test, T_test, 'Nx', 81, 'save_every', 20, 'CFL', 0.4, 'seed', 42);

    assert(ef >= 0, 'Self-test 1: exitflag >= 0, got %d.', ef);
    assert(size(u_hist, 2) == 81, ...
        'Self-test 1: expected 81 spatial points, got %d.', size(u_hist, 2));

    % Test 2: Solution bounded by carrying capacity
    u_final = u_hist(end, :);
    assert(all(u_final <= K_test + 0.01), ...
        'Self-test 2: u(x,T) should not exceed K=%.2f, max=%.4f.', K_test, max(u_final));
    assert(all(u_final >= -0.01), ...
        'Self-test 2: u(x,T) should be non-negative, min=%.4f.', min(u_final));

    % Test 3: Traveling wave: solution should have propagated rightward
    % Initial condition is 1 for x < 2.5, 0 for x > 2.5
    % After some time, the front should have moved right
    u_mid = u_hist(end, :);
    % Find x where u drops to 0.5 (wave front)
    idx_half = find(u_mid < 0.5 * K_test, 1, 'first');
    if isempty(idx_half)
        idx_half = length(x_grid);
    end
    x_front = x_grid(idx_half);
    assert(x_front > L_test / 4, ...
        'Self-test 3: wave front at x=%.3f should be past initial front at x=%.3f.', ...
        x_front, L_test/4);

    % Test 4: Mass conservation check (for pure diffusion, R=0)
    [u_norxn, ~, ~, ef4] = reaction_diffusion(D_test, @(u) 0, u0_func, ...
        L_test, 2.0, 'Nx', 51, 'save_every', 10, 'CFL', 0.4, 'seed', 42);
    assert(ef4 >= 0, 'Self-test 4: pure diffusion exitflag >= 0, got %d.', ef4);
    % Mass should be approximately conserved (Neumann BCs)
    mass_initial = sum(u_norxn(1, :)) * L_test / 51;
    mass_final = sum(u_norxn(end, :)) * L_test / 51;
    mass_change = abs(mass_final - mass_initial) / max(mass_initial, 1e-12);
    assert(mass_change < 0.05, ...
        'Self-test 4: mass change %.4f%% exceeds 5%% for pure diffusion.', mass_change*100);

    % Test 5: Solution is finite everywhere
    assert(all(isfinite(u_hist(:))), ...
        'Self-test 5: all solution values must be finite.');

    fprintf('REACTIONDIFFUSION self-test PASSED (5 tests, all assertions passed).\n');
end
end
