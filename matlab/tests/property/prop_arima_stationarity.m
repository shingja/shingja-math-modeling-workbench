% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_arima_stationarity(n_trials)
%% PROP_ARIMA_STATIONARITY Property test: AR polynomial roots outside unit circle.
%  Invariant: For stationary time series, the fitted AR polynomial
%             must have all roots outside the unit circle |z| > 1.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    T = randi([50, 200]);
    % Generate stationary AR(2) data with known stable coefficients
    phi1_true = 0.5 + rand() * 0.3;   % phi1 in (0.5, 0.8)
    phi2_true = -0.3 + rand() * 0.3;  % phi2 in (-0.3, 0)
    % Ensure stationarity: phi1+phi2 < 1, phi2-phi1 < 1, |phi2| < 1
    if phi1_true + phi2_true >= 0.99, phi2_true = 0.98 - phi1_true - 0.01; end
    if phi2_true - phi1_true >= 0.99, phi1_true = phi2_true - 0.98; end
    if abs(phi2_true) >= 0.99, phi2_true = sign(phi2_true) * 0.98; end

    noise = randn(T + 100, 1) * 0.5;
    y = zeros(T + 100, 1);
    for t = 3:(T + 100)
        y(t) = phi1_true * y(t-1) + phi2_true * y(t-2) + noise(t);
    end
    y = y(101:end);  % discard burn-in
    T_actual = length(y);

    p_order = 2;
    d_order = 0;
    q_order = 0;

    try
        [forecast, phi_hat, ~, ~, ef] = arima_forecast(y, p_order, d_order, q_order, ...
            'horizon', 3, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['ARIMA failed: ' ME.message]);
        continue;
    end

    if ef < 0, continue; end  % convergence failure

    % Invariant: AR polynomial roots outside unit circle
    ar_poly = [1; -phi_hat(:)];  % 1 - phi1*z^{-1} - phi2*z^{-2}
    roots_ar = roots(flipud(ar_poly));  % flip for standard polynomial form

    if any(abs(roots_ar) <= 1 - 1e-6)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('AR roots inside unit circle: |roots| = [%s]', ...
            sprintf('%.4f ', abs(roots_ar))));
    end
end
end

%% Self-test
function self_test()
    result = prop_arima_stationarity(5);
    assert(result.pass, 'Self-test failed: ARIMA stationarity violated.');
    fprintf('prop_arima_stationarity self-test PASSED (%d trials).\n', result.n_trials);
end
