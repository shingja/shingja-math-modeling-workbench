% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function varargout = seir_model(mode, varargin)
%% SEIR_MODEL  SEIR compartmental epidemic model.
%  Paradigm: PARADIGM-0804-SEIR. Category: Comprehensive. v3.0.0.
%  Reference: Kermack, W.O. & McKendrick, A.G. (1927) "A contribution to
%             the mathematical theory of epidemics." Proc. R. Soc. Lond. A,
%             115(772), 700-721. DOI: 10.1098/rspa.1927.0118.
%  Reference: Hethcote, H.W. (2000) "The mathematics of infectious diseases."
%             SIAM Review, 42(4), 599-653. DOI: 10.1137/S0036144500371907.
%
%  SEIR ODE system:
%    dS/dt = -beta * S * I / N
%    dE/dt =  beta * S * I / N - sigma * E
%    dI/dt =  sigma * E - gamma * I
%    dR/dt =  gamma * I
%  where N = S + E + I + R (constant).
%
%  Usage:
%    [t, S, E, I, R] = seir_model('solve', S0, E0, I0, R0, ...
%                                  beta, sigma, gamma, t_span)
%    R0_val           = seir_model('R0', beta, gamma)
%    [peak_t, peak_mag]= seir_model('peak', I_curve, t)
%
%  Input:
%    S0, E0, I0, R0 - Initial compartment counts
%    beta  - Transmission rate (effective contacts per unit time)
%    sigma - Rate of progression from exposed to infectious (1/incubation)
%    gamma - Recovery rate (1/infectious period)
%    t_span - Time span [t0, tf] or vector of time points
%
%  Options (for 'solve', name-value pairs after t_span):
%    'seed'   - RNG seed (default: 42)
%    'solver' - ODE solver: 'ode45' (default), 'ode23', 'ode15s'
%    'reltol' - Relative tolerance (default: 1e-6)
%    'abstol' - Absolute tolerance (default: 1e-9)
%
%  Output:
%    solve  - Time vector and compartment trajectories
%    R0     - Basic reproduction number R0 = beta / gamma
%    peak   - Time and magnitude of peak infectious population

arguments
    mode (1,1) string
end
arguments (Repeating)
    varargin
end

% ---- Parse options ----
opts.seed   = 42;
opts.solver = 'ode45';
opts.reltol = 1e-6;
opts.abstol = 1e-9;

all_args = varargin;
pos_args = {};
i = 1;
while i <= length(all_args)
    if ischar(all_args{i}) || isstring(all_args{i})
        key = char(all_args{i});
        if i + 1 <= length(all_args)
            val = all_args{i+1};
            switch lower(key)
                case 'seed',   opts.seed   = val;
                case 'solver', opts.solver = val;
                case 'reltol', opts.reltol = val;
                case 'abstol', opts.abstol = val;
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

% IO note: save(fullfile(output_dir, 'seir_results.mat'), 't', 'S', 'E', 'I', 'R');

%% ---- Dispatch ----
switch lower(mode)
    case 'solve'
        assert(length(pos_args) >= 8, ...
            'solve mode requires: S0, E0, I0, R0, beta, sigma, gamma, t_span.');
        S0    = pos_args{1};
        E0    = pos_args{2};
        I0    = pos_args{3};
        R0_0  = pos_args{4};
        beta  = pos_args{5};
        sigma = pos_args{6};
        gamma = pos_args{7};
        t_span = pos_args{8};

        [t, S, E, I, R] = seir_solve_impl(S0, E0, I0, R0_0, beta, sigma, gamma, t_span, opts);
        varargout{1} = t;
        varargout{2} = S;
        varargout{3} = E;
        varargout{4} = I;
        varargout{5} = R;

    case 'r0'
        assert(length(pos_args) >= 2, 'R0 mode requires: beta, gamma.');
        beta  = pos_args{1};
        gamma = pos_args{2};
        R0_val = seir_R0_impl(beta, gamma);
        varargout{1} = R0_val;

    case 'peak'
        assert(length(pos_args) >= 1, 'peak mode requires I_curve. Optional: t.');
        I_curve = pos_args{1}(:);
        if length(pos_args) >= 2
            t_vec = pos_args{2}(:);
        else
            t_vec = (0:length(I_curve)-1)';
        end
        [peak_t, peak_mag] = seir_peak_impl(I_curve, t_vec);
        varargout{1} = peak_t;
        varargout{2} = peak_mag;

    otherwise
        error('SEIR_MODEL: unknown mode ''%s''. Valid: solve, R0, peak.', mode);
end

%% ==================== Nested: ODE right-hand side ====================
    function dydt = seir_ode(~, y, beta, sigma, gamma, N)
        S = y(1);
        E = y(2);
        I = y(3);
        % R = y(4) is not needed for dynamics (dR/dt = gamma*I, computed)
        dydt = zeros(4, 1);
        dydt(1) = -beta * S * I / N;
        dydt(2) =  beta * S * I / N - sigma * E;
        dydt(3) =  sigma * E - gamma * I;
        dydt(4) =  gamma * I;
    end

%% ==================== Nested: solve ====================
    function [t, S, E, I, R] = seir_solve_impl(S0, E0, I0, R0_0, beta, sigma, gamma, t_span, opt)
        % Validate inputs
        assert(S0 >= 0 && E0 >= 0 && I0 >= 0 && R0_0 >= 0, ...
            'Initial compartments must be non-negative.');
        N = S0 + E0 + I0 + R0_0;
        assert(N > 0, 'Total population N must be positive.');
        assert(beta >= 0 && sigma > 0 && gamma > 0, ...
            'Rates: beta>=0, sigma>0, gamma>0 required.');

        y0 = [S0; E0; I0; R0_0];

        % Set ODE options
        ode_opts = odeset('RelTol', opt.reltol, 'AbsTol', opt.abstol, ...
                          'NonNegative', 1:4);

        % Choose solver and integrate
        odefun = @(t, y) seir_ode(t, y, beta, sigma, gamma, N);

        switch lower(opt.solver)
            case 'ode45'
                [t, Y] = ode45(odefun, t_span, y0, ode_opts);
            case 'ode23'
                [t, Y] = ode23(odefun, t_span, y0, ode_opts);
            case 'ode15s'
                [t, Y] = ode15s(odefun, t_span, y0, ode_opts);
            otherwise
                error('Unknown solver: %s. Use ode45, ode23, or ode15s.', opt.solver);
        end

        S = Y(:, 1);
        E = Y(:, 2);
        I = Y(:, 3);
        R = Y(:, 4);

        % ---- Convergence / validity checks ----
        % Check 1: Total population conservation
        N_t = S + E + I + R;
        max_deviation = max(abs(N_t - N));
        assert(max_deviation < 1e-6 * N, ...
            'SEIR: population not conserved. Max deviation = %.4e (%.6f%%).', ...
            max_deviation, 100 * max_deviation / N);

        % Check 2: No negative compartments
        assert(all(S >= -1e-10) && all(E >= -1e-10) && ...
               all(I >= -1e-10) && all(R >= -1e-10), ...
            'SEIR: negative compartment values detected.');

        % Check 3: R should be non-decreasing
        dR = diff(R);
        assert(all(dR >= -1e-10), ...
            'SEIR: recovered compartment decreased (min dR = %.4e).', min(dR));

        % Check 4: S should be non-increasing
        dS = diff(S);
        assert(all(dS <= 1e-10), ...
            'SEIR: susceptible compartment increased (max dS = %.4e).', max(dS));

        % Check 5: Solution is finite
        assert(all(isfinite(Y(:))), 'SEIR: non-finite values in solution.');
    end

%% ==================== Nested: R0 ====================
    function R0_val = seir_R0_impl(beta, gamma)
        assert(beta >= 0 && gamma > 0, 'beta and gamma must be positive.');
        R0_val = beta / gamma;
        assert(isfinite(R0_val), 'SEIR: R0 is not finite.');
    end

%% ==================== Nested: peak ====================
    function [peak_t, peak_mag] = seir_peak_impl(I_curve, t_vec)
        assert(length(I_curve) == length(t_vec), ...
            'I_curve and t_vec must have the same length.');
        assert(all(I_curve >= -1e-10), 'I_curve must be non-negative.');

        [peak_mag, idx] = max(I_curve);
        peak_t = t_vec(idx);

        % Sanity: peak should not be at the very first or last time point
        % if the epidemic is non-trivial
        if peak_mag > 1e-6
            assert(idx > 1 && idx < length(I_curve), ...
                'SEIR: peak at boundary (t=%.4f). Epidemic may not have completed.', peak_t);
        end
    end

%% Self-test
function self_test()
    rng(42);
    tol = 1e-8;

    % Parameters: moderate flu-like epidemic
    N_pop  = 1000;
    E0     = 1;
    I0     = 1;
    R0_0   = 0;
    S0     = N_pop - E0 - I0 - R0_0;  % = 998
    beta   = 0.3;
    sigma  = 1 / 5.2;   % ~5.2 day incubation
    gamma  = 1 / 14;    % ~14 day infectious period
    t_span = [0, 200];

    [t, S, E, I, R] = seir_model('solve', S0, E0, I0, R0_0, ...
        beta, sigma, gamma, t_span);

    % ---- Assert 1: Population conservation ----
    N_t = S + E + I + R;
    max_dev = max(abs(N_t - N_pop));
    assert(max_dev < 1e-8, ...
        'Self-test FAILED: population not conserved, max dev = %.4e.', max_dev);

    % ---- Assert 2: Final recovered > 0 (epidemic occurred) ----
    assert(R(end) > 0, ...
        'Self-test FAILED: no recoveries — epidemic did not occur.');

    % ---- Assert 3: Peak I occurs at t > 0 ----
    [peak_t, peak_I] = seir_model('peak', I, t);
    assert(peak_t > 0, ...
        'Self-test FAILED: peak at t=%.2f, expected > 0.', peak_t);
    assert(peak_I > I0, ...
        'Self-test FAILED: peak I = %.2f not > initial I0 = %.2f.', peak_I, I0);

    % ---- Assert 4: R0 > 1 for this epidemic ----
    R0_val = seir_model('R0', beta, gamma);
    expected_R0 = beta / gamma;  % = 0.3 * 14 = 4.2
    assert(abs(R0_val - expected_R0) < tol, ...
        'Self-test FAILED: R0 = %.6f, expected %.6f.', R0_val, expected_R0);
    assert(R0_val > 1, ...
        'Self-test FAILED: R0 = %.4f <= 1 for an epidemic-prone setting.', R0_val);

    % ---- Assert 5: S is non-increasing ----
    assert(all(diff(S) <= 1e-10), ...
        'Self-test FAILED: S increased at some point.');

    % ---- Assert 6: R is non-decreasing ----
    assert(all(diff(R) >= -1e-10), ...
        'Self-test FAILED: R decreased at some point.');

    disp('SEIR_MODEL self-test passed.');
end
end
