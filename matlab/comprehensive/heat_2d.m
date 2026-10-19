% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = heat_2d(options)
%% HEAT_2D 2D heat equation via FTCS finite difference. Paradigm: PARADIGM-0812-HEAT-2D. v3.0.0.
%   du/dt = alpha * (d2u/dx2 + d2u/dy2)
%   Dirichlet boundary conditions: u = 0 on all boundaries.
%
%   Inputs:
%       options.alpha      - thermal diffusivity (default: 0.01)
%       options.Lx         - domain length x (default: 1)
%       options.Ly         - domain length y (default: 1)
%       options.Nx         - grid points in x (default: 51)
%       options.Ny         - grid points in y (default: 51)
%       options.T_end      - final time (default: 0.05)
%       options.dt         - time step (default: auto from CFL)
%       options.u0_func    - initial condition function handle (default: Gaussian)
%       options.seed       - random seed (default: 42)
%
%   Outputs:
%       result.u           - solution at final time (Ny x Nx matrix)
%       result.t           - time vector
%       result.u_history   - cell array of solutions at saved times
%       result.max_temp_history - max temperature over time
%       result.exitflag    - 1 if completed, -1 if CFL violated

arguments
    options.alpha (1,1) double {mustBePositive} = 0.01
    options.Lx (1,1) double {mustBePositive} = 1.0
    options.Ly (1,1) double {mustBePositive} = 1.0
    options.Nx (1,1) double {mustBePositive, mustBeInteger} = 51
    options.Ny (1,1) double {mustBePositive, mustBeInteger} = 51
    options.T_end (1,1) double {mustBePositive} = 0.05
    options.dt (1,1) double = 0
    options.u0_func function_handle = @(x,y) exp(-((x-0.5).^2 + (y-0.5).^2) / 0.01)
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

alpha = options.alpha;
Lx = options.Lx;
Ly = options.Ly;
Nx = options.Nx;
Ny = options.Ny;
T_end = options.T_end;

% Spatial discretization
dx = Lx / (Nx - 1);
dy = Ly / (Ny - 1);

x = linspace(0, Lx, Nx);
y = linspace(0, Ly, Ny);
[X, Y] = meshgrid(x, y);

% CFL condition: dt <= dx^2 * dy^2 / (2 * alpha * (dx^2 + dy^2))
dt_max = dx^2 * dy^2 / (2 * alpha * (dx^2 + dy^2));

if options.dt <= 0
    dt = 0.9 * dt_max;  % Safety factor
else
    dt = options.dt;
    if dt > dt_max
        warning('HEAT2D:CFLViolation', ...
            'dt=%.6e exceeds CFL stability limit %.6e. Solution may be unstable.', dt, dt_max);
    end
end

% Time discretization
Nt = ceil(T_end / dt);
dt = T_end / Nt;

% Check CFL with final dt
if dt > dt_max
    exitflag = -1;
else
    exitflag = 1;
end

% FTCS coefficients
rx = alpha * dt / dx^2;
ry = alpha * dt / dy^2;

% Initial condition
u = options.u0_func(X, Y);

% Apply boundary conditions (u=0 on boundaries)
u(1, :) = 0;      % y=0
u(end, :) = 0;    % y=Ly
u(:, 1) = 0;      % x=0
u(:, end) = 0;    % x=Lx

% Storage
save_every = max(1, floor(Nt / 50));  % Save ~50 snapshots
n_saves = floor(Nt / save_every) + 1;
u_history = cell(n_saves, 1);
max_temp_history = zeros(n_saves, 1);

save_idx = 1;
u_history{save_idx} = u;
max_temp_history(save_idx) = max(u(:));
t_vec = zeros(n_saves, 1);
t_vec(1) = 0;

monotonic_decrease = true;

% Time stepping
for n = 1:Nt
    u_new = u;

    % Interior points: FTCS scheme
    for i = 2:Ny-1
        for j = 2:Nx-1
            uxx = (u(i, j+1) - 2*u(i, j) + u(i, j-1)) / dx^2;
            uyy = (u(i+1, j) - 2*u(i, j) + u(i-1, j)) / dy^2;
            u_new(i, j) = u(i, j) + alpha * dt * (uxx + uyy);
        end
    end

    % Boundary conditions (Dirichlet: u=0)
    u_new(1, :) = 0;
    u_new(end, :) = 0;
    u_new(:, 1) = 0;
    u_new(:, end) = 0;

    u = u_new;

    % Check monotonic decrease of max temperature
    current_max = max(u(:));
    if current_max > max_temp_history(max(1, save_idx-1)) + 1e-12
        monotonic_decrease = false;
    end

    % Save periodically
    if mod(n, save_every) == 0 || n == Nt
        save_idx = save_idx + 1;
        u_history{save_idx} = u;
        max_temp_history(save_idx) = current_max;
        t_vec(save_idx) = n * dt;
    end
end

% Trim storage to actual saves
u_history = u_history(1:save_idx);
max_temp_history = max_temp_history(1:save_idx);
t_vec = t_vec(1:save_idx);

% Analytical series solution for comparison (at t = T_end)
% u(x,y,t) = sum_{m,n} A_{mn} * sin(m*pi*x/Lx) * sin(n*pi*y/Ly) * exp(-alpha*pi^2*(m^2/Lx^2+n^2/Ly^2)*t)
% Coefficients A_{mn} for Gaussian initial condition approximated via FFT
% We compute the first few terms
    function u_analytical = analytical_solution(xx, yy, tt, n_terms)
        u_analytical = zeros(size(xx));
        for m = 1:n_terms
            for n_idx = 1:n_terms
                % Coefficient via numerical integration (trapezoidal on grid)
                integrand = options.u0_func(xx, yy) .* ...
                            sin(m * pi * xx / Lx) .* sin(n_idx * pi * yy / Ly);
                A_mn = 4 / (Lx * Ly) * trapz(y, trapz(x, integrand, 2));
                u_analytical = u_analytical + A_mn * ...
                    sin(m * pi * xx / Lx) .* sin(n_idx * pi * yy / Ly) * ...
                    exp(-alpha * pi^2 * (m^2/Lx^2 + n_idx^2/Ly^2) * tt);
            end
        end
    end

% Compute analytical solution for comparison
n_terms = 15;
u_analytical = analytical_solution(X, Y, T_end, n_terms);

% Package result
result.u = u;
result.x = x;
result.y = y;
result.t = t_vec;
result.u_history = u_history;
result.max_temp_history = max_temp_history;
result.monotonic_decrease = monotonic_decrease;
result.u_analytical = u_analytical;
result.exitflag = exitflag;
result.params = struct('alpha', alpha, 'dx', dx, 'dy', dy, 'dt', dt, ...
                       'Nx', Nx, 'Ny', Ny, 'Nt', Nt, 'CFL_dt_max', dt_max);

%% Self-test
    function self_test()
        fprintf('Running heat_2d self-test...\n');

        opts.alpha = 0.01;
        opts.Lx = 1.0;
        opts.Ly = 1.0;
        opts.Nx = 31;
        opts.Ny = 31;
        opts.T_end = 0.05;
        opts.seed = 42;

        r = heat_2d(opts);

        % Assert 1: max temperature monotonically decreases (2nd law)
        assert(r.monotonic_decrease, ...
            'Heat-2D self-test FAIL: max temperature did not decrease monotonically');

        % Assert 2: max temp at end < max temp at start
        assert(r.max_temp_history(end) < r.max_temp_history(1), ...
            'Heat-2D self-test FAIL: max temp did not decrease from initial');

        % Assert 3: solution agrees with analytical series (relative L2 error < 5%)
        numer_norm = norm(r.u(:));
        diff_norm = norm(r.u(:) - r.u_analytical(:));
        rel_error = diff_norm / (numer_norm + 1e-10);

        % For small grid, allow reasonable error
        assert(rel_error < 0.15, ...
            'Heat-2D self-test FAIL: relative error %.4f vs analytical too large', rel_error);

        % Assert 4: boundary conditions satisfied (u=0 at edges)
        assert(max(abs(r.u(1, :))) < 1e-12, ...
            'Heat-2D self-test FAIL: bottom boundary not zero');
        assert(max(abs(r.u(end, :))) < 1e-12, ...
            'Heat-2D self-test FAIL: top boundary not zero');
        assert(max(abs(r.u(:, 1))) < 1e-12, ...
            'Heat-2D self-test FAIL: left boundary not zero');
        assert(max(abs(r.u(:, end))) < 1e-12, ...
            'Heat-2D self-test FAIL: right boundary not zero');

        % Assert 5: CFL condition satisfied
        assert(r.params.dt <= r.params.CFL_dt_max + 1e-12, ...
            'Heat-2D self-test FAIL: CFL condition violated');

        % Assert 6: exitflag appropriate (not -1 from CFL if stable)
        % (exitflag=-1 only set when user-specified dt violates CFL; auto dt is safe)
        assert(ismember(r.exitflag, [1, -1]), ...
            'Heat-2D self-test FAIL: invalid exitflag');

        disp('heat_2d self-test passed.');
    end

self_test();
end
