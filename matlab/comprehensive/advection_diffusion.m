% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [u_history, x, t, exitflag] = advection_diffusion(v, D, u0, L_x, T_end, options)
%% ADVECTIONDIFFUSION 1D Advection-Diffusion equation via upwind scheme.
%  Solves du/dt + v*du/dx = D*d^2u/dx^2 on [0, L_x] with periodic or
%  outflow BCs. Uses first-order upwind for advection and central
%  difference for diffusion (explicit FTCS-UPWIND).
%  Paradigm: PARADIGM-0707
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: LeVeque, R.J. (2002) Finite Volume Methods for Hyperbolic
%             Problems. Cambridge University Press. ISBN: 978-0521009249.
%             Morton, K.W. & Mayers, D.F. (2005) Numerical Solution of
%             Partial Differential Equations, 2nd Edition. Cambridge
%             University Press. ISBN: 978-0521607933.
%
%  Input:
%      v     - Advection velocity (scalar, > 0 = rightward, < 0 = leftward)
%      D     - Diffusion coefficient (scalar, >= 0 for pure advection)
%      u0    - Initial condition (function handle u0(x) or vector Nx x 1)
%      L_x   - Domain length
%      T_end - Final simulation time
%
%  Options:
%      options.Nx       - Spatial grid points (default: 101)
%      options.dt       - Time step (auto from CFL if empty)
%      options.save_every - Save solution every n steps (default: 10)
%      options.BC        - 'periodic' (default) | 'outflow' | 'dirichlet'
%      options.CFL       - CFL safety factor (default: 0.4)
%      options.seed      - RNG seed (default: 42)
%
%  Output:
%      u_history - Solution history (Nt_save x Nx)
%      x         - Spatial grid (1 x Nx)
%      t         - Time points saved (1 x Nt_save)
%      exitflag  - 1 = success, 0 = CFL warning, -1 = error

arguments
    v (1,1) double
    D (1,1) double {mustBeNonnegative}
    u0
    L_x (1,1) double {mustBePositive}
    T_end (1,1) double {mustBePositive}
    options.Nx (1,1) double {mustBeInteger, mustBePositive} = 101
    options.dt (1,1) double = []
    options.save_every (1,1) double {mustBeInteger, mustBePositive} = 10
    options.BC char {mustBeMember(options.BC, {'periodic','outflow','dirichlet'})} = 'periodic'
    options.CFL (1,1) double {mustBeInRange(options.CFL, 0.05, 0.49)} = 0.4
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

%% Spatial grid
dx = L_x / (options.Nx - 1);
x = linspace(0, L_x, options.Nx)';

%% Adaptive time step based on CFL conditions
% Advection CFL: |v| * dt / dx <= CFL
% Diffusion CFL: D * dt / dx^2 <= 0.5 * CFL
if isempty(options.dt)
    dt_adv = options.CFL * dx / (abs(v) + 1e-14);
    if D > 0
        dt_diff = options.CFL * dx^2 / (2 * D + 1e-14);
    else
        dt_diff = inf;
    end
    dt = min(dt_adv, dt_diff);
else
    dt = options.dt;
    % Check CFL
    cfl_adv = abs(v) * dt / dx;
    cfl_diff = D * dt / dx^2;
    if cfl_adv > 0.5
        exitflag = 0;
        warning('ADVECTIONDIFFUSION:CFLadv', ...
            'Advection CFL=%.4f > 0.5.', cfl_adv);
    end
    if D > 0 && cfl_diff > 0.5
        exitflag = 0;
        warning('ADVECTIONDIFFUSION:CFLdiff', ...
            'Diffusion CFL=%.4f > 0.5.', cfl_diff);
    end
end

Nt = ceil(T_end / dt);
dt = T_end / Nt;

C_adv = v * dt / dx;   % Courant number for advection
C_diff = D * dt / dx^2;  % Fourier number for diffusion

%% Initial condition
if isa(u0, 'function_handle')
    u = u0(x);
else
    u = u0(:);
    assert(length(u) == options.Nx, 'u0 vector must have Nx elements.');
end
u_initial = u;  % save for mass comparison

%% Pre-allocate storage
N_save = ceil(Nt / options.save_every) + 1;
u_history = zeros(N_save, options.Nx);
t = zeros(1, N_save);
u_history(1, :) = u';
t(1) = 0;
save_idx = 1;

%% Time-stepping loop
for n = 1:Nt
    u_new = u;

    %% Advection: first-order upwind
    % du/dt + v*du/dx: upwind uses u_i - u_{i-1} for v > 0,
    %                        u_{i+1} - u_i for v < 0
    adv = zeros(options.Nx, 1);

    if v > 0
        % Upwind from left
        for i = 2:options.Nx
            adv(i) = v * (u(i) - u(i-1)) / dx;
        end
        % Left boundary
        switch options.BC
            case 'periodic'
                adv(1) = v * (u(1) - u(end)) / dx;
            case 'outflow'
                adv(1) = 0;  % du/dx = 0 at inlet (diffusive)
            case 'dirichlet'
                adv(1) = v * (u(1) - 0) / dx;  % u(0) = 0
        end
    else  % v < 0
        % Upwind from right
        for i = 1:options.Nx-1
            adv(i) = v * (u(i+1) - u(i)) / dx;
        end
        % Right boundary
        switch options.BC
            case 'periodic'
                adv(options.Nx) = v * (u(1) - u(end)) / dx;
            case 'outflow'
                adv(options.Nx) = 0;
            case 'dirichlet'
                adv(options.Nx) = v * (0 - u(end)) / dx;
        end
    end

    %% Diffusion: central difference
    diff_u = zeros(options.Nx, 1);
    if D > 0
        for i = 2:options.Nx-1
            diff_u(i) = D * (u(i+1) - 2*u(i) + u(i-1)) / dx^2;
        end
        % Boundaries
        switch options.BC
            case 'periodic'
                diff_u(1) = D * (u(2) - 2*u(1) + u(end)) / dx^2;
                diff_u(options.Nx) = D * (u(1) - 2*u(options.Nx) + u(options.Nx-1)) / dx^2;
            case 'outflow'
                % Neumann: du/dx = 0 at boundaries
                diff_u(1) = D * 2 * (u(2) - u(1)) / dx^2;
                diff_u(options.Nx) = D * 2 * (u(options.Nx-1) - u(options.Nx)) / dx^2;
            case 'dirichlet'
                diff_u(1) = D * (u(2) - 2*u(1) + 0) / dx^2;
                diff_u(options.Nx) = D * (0 - 2*u(options.Nx) + u(options.Nx-1)) / dx^2;
        end
    end

    %% Euler update
    u_new = u + dt * (-adv + diff_u);

    % Clip to reasonable range
    u_new = max(min(u_new, 1e6), -1e6);
    u = u_new;

    %% Save
    if mod(n, options.save_every) == 0 || n == Nt
        save_idx = save_idx + 1;
        u_history(save_idx, :) = u';
        t(save_idx) = n * dt;
    end
end

% Trim
u_history = u_history(1:save_idx, :);
t = t(1:save_idx);

%% Validation
if any(isnan(u_history(:)))
    exitflag = -1;
    warning('ADVECTIONDIFFUSION:NaN', 'NaN values in solution.');
end

%% Self-test
function self_test()
    L = 10.0;
    Nx_test = 101;
    dx_test = L / (Nx_test - 1);
    x_test = linspace(0, L, Nx_test)';

    % Test 1: Pure advection (D=0, v=1, periodic BC)
    % Gaussian pulse should translate right at speed v
    x0_pulse = 2.0;
    sigma = 0.5;
    u0_pulse = @(x) exp(-(x - x0_pulse).^2 / (2 * sigma^2));

    T1 = 2.0;  % travel time: the pulse should move v*T = 2 units right

    [u_hist1, x1, t1, ef1] = advection_diffusion(1.0, 0.0, u0_pulse, ...
        L, T1, 'Nx', Nx_test, 'BC', 'periodic', 'save_every', 20, 'CFL', 0.4, 'seed', 42);

    assert(ef1 >= 0, 'Self-test 1: exitflag >= 0, got %d.', ef1);

    % Test 2: Mass conservation for pure advection with periodic BC
    mass_initial = sum(u_hist1(1, :)) * dx_test;
    mass_final = sum(u_hist1(end, :)) * dx_test;
    mass_error = abs(mass_final - mass_initial) / max(mass_initial, 1e-12);
    assert(mass_error < 0.05, ...
        'Self-test 2: mass not conserved, error=%.4f%%.', mass_error * 100);

    % Test 3: Wave translation (peak position should be at x0 + v*T, modulo L)
    [~, idx_initial] = max(u_hist1(1, :));
    [~, idx_final] = max(u_hist1(end, :));
    peak_shift = (idx_final - idx_initial) * dx_test;
    expected_shift = 1.0 * T1;  % v * T
    % Allow some error due to numerical diffusion
    shift_error = abs(peak_shift - expected_shift);
    assert(shift_error < 1.5, ...
        'Self-test 3: peak shift=%.3f differs from expected %.3f by %.3f.', ...
        peak_shift, expected_shift, shift_error);

    % Test 4: Advection-diffusion (D > 0) should spread the pulse
    [u_hist2, ~, ~, ef4] = advection_diffusion(1.0, 0.05, u0_pulse, ...
        L, 2.0, 'Nx', 81, 'BC', 'periodic', 'save_every', 20, 'CFL', 0.35, 'seed', 42);
    assert(ef4 >= 0, 'Self-test 4: advection-diffusion exitflag >= 0, got %d.', ef4);

    % With diffusion, the max should be lower than pure advection
    max_pure_advec = max(u_hist1(end, :));
    max_with_diff = max(u_hist2(end, :));
    assert(max_with_diff < max_pure_advec + 0.01, ...
        'Self-test 4: diffusion should reduce peak, pure=%.4f, with_diff=%.4f.', ...
        max_pure_advec, max_with_diff);

    % Test 5: Leftward advection (v < 0)
    [u_hist3, ~, ~, ef5] = advection_diffusion(-1.0, 0.0, u0_pulse, ...
        L, 1.0, 'Nx', Nx_test, 'BC', 'periodic', 'save_every', 20, 'CFL', 0.4, 'seed', 42);
    assert(ef5 >= 0, 'Self-test 5: leftward advection exitflag >= 0, got %d.', ef5);
    [~, idx_final3] = max(u_hist3(end, :));
    peak_pos3 = idx_final3 * dx_test;
    % Should be to the left of initial position (with wrap-around)
    assert(peak_pos3 < x0_pulse + 0.2 || peak_pos3 > L - 1.0, ...
        'Self-test 5: peak should shift left for v<0, peak at x=%.3f.', peak_pos3);

    % Test 6: All solution values are finite
    assert(all(isfinite(u_hist1(:))), 'Self-test 6: all values must be finite.');
    assert(all(isfinite(u_hist2(:))), 'Self-test 6: all values must be finite.');

    fprintf('ADVECTIONDIFFUSION self-test PASSED (6 tests, all assertions passed).\n');
end
end
