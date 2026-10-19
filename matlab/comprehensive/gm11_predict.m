% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x0_fitted, x0_forecast, a, b, exitflag] = gm11_predict(x0, options)
%% GM11_PREDICT Grey Model GM(1,1) for small-sample time series prediction.
%  Paradigm: PARADIGM-0201-GM11. Category: Prediction. v3.0.0.
%  Reference: Deng J.L. (1982) Control problems of grey systems. SCL.
%  Performs AGO accumulation, B/Y matrix construction, least-squares [a,b]
%  estimation, and prediction via x_hat(k+1)=(x0(1)-b/a)*(1-exp(a))*exp(-a*k).
%  Input:  x0 - nonnegative equidistant series (row or column vector)
%          options.seed - random seed (default 42)
%          options.n_forecast - points to forecast (default 0)
%  Output: x0_fitted - fitted values, same shape as x0
%          x0_forecast - forecasted values (row vector)
%          a - development coefficient
%          b - grey action quantity
%          exitflag - 1 converged, -1 failed

arguments
    x0 (:, :) double {mustBeNonnegative}
    options.seed (1,1) double = 42
    options.n_forecast (1,1) double {mustBeNonnegative, mustBeInteger} = 0
end
rng(options.seed, 'twister');

% Convert to row vector for internal processing; record original orientation
was_column = (size(x0, 1) > 1);
x0_row = x0(:)';
n = length(x0_row);

if n < 4
    warning('GM11:InsufficientData', ...
        'GM(1,1) requires at least 4 data points for reliable estimation.');
    exitflag = -1;
    x0_fitted = x0;
    x0_forecast = [];
    a = NaN;
    b = NaN;
    return;
end

% Step 1: Accumulated Generating Operation (AGO)
x1_ago      = cumsum(x0_row);                               % L01

% Step 2: Build background-value matrix B and data vector Y
B_mat       = zeros(n - 1, 2);                              % L02
Y_vec       = zeros(n - 1, 1);                              % L03
for k = 1:(n - 1)
    B_mat(k, 1) = -0.5 * (x1_ago(k) + x1_ago(k + 1));       % L04
    B_mat(k, 2) = 1.0;                                      % L05
    Y_vec(k)    = x0_row(k + 1);                             % L06
end

% Step 3: Least-squares parameter estimation [a; b] = (B'B)^{-1} B'Y
coeff       = (B_mat' * B_mat) \ (B_mat' * Y_vec);          % L07
a           = coeff(1);                                     % L08
b           = coeff(2);                                     % L09

% Convergence / feasibility check
if abs(a) < 1e-12                                           % L10
    warning('GM11:NotConverged', ...
        'Development coefficient a is near zero; grey model is infeasible.');
    exitflag    = -1;                                       % L11
    x0_fitted   = x0;                                       % L12
    x0_forecast = [];                                       % L13
    return;
end
exitflag = 1;                                               % L14

% Step 4: Time-response formula for fitted values
c_const     = x0_row(1) - b / a;                             % L15
x1_hat      = zeros(1, n);                                  % L16
x1_hat(1)   = x0_row(1);                                    % L17
for k = 2:n
    x1_hat(k) = c_const * exp(-a * (k - 1)) + b / a;         % L18
end
x0_hat = zeros(1, n);                                       % L19
x0_hat(1) = x0_row(1);                                      % L20
for k = 2:n
    x0_hat(k) = x1_hat(k) - x1_hat(k - 1);                  % L21
end

% Step 5: Forecasting future values beyond the original series
nf          = options.n_forecast;
x0_fc       = zeros(1, nf);                                 % L22
if nf > 0
    x1_fc       = zeros(1, nf);                             % L23
    for k = 1:nf
        x1_fc(k) = c_const * exp(-a * (n + k - 1)) + b / a; % L24
    end
    x0_fc(1) = x1_fc(1) - x1_hat(n);                        % L25
    for k = 2:nf
        x0_fc(k) = x1_fc(k) - x1_fc(k - 1);                 % L26
    end
end

% Restore original orientation for fitted values
if was_column
    x0_fitted = x0_hat(:);
else
    x0_fitted = x0_hat;
end
x0_forecast = x0_fc;

end

%% Self-test ================================================================
function self_test()
% Known series from Deng (1982); expected a ~ -0.0372
    x0_known = [2.874, 3.278, 3.337, 3.390, 3.679];
    [x0_fit, ~, a_val, ~, exitflag] = gm11_predict(x0_known);

    % Assert 1: model must converge
    assert(exitflag == 1, ...
        'GM(1,1) failed to converge on standard test series.');

    % Assert 2: development coefficient a within 0.005 of -0.0372
    assert(abs(a_val - (-0.0372)) < 0.005, ...
        sprintf('GM(1,1) a=%.5f differs from expected -0.0372 by >0.005.', a_val));

    % Assert 3: fitted values within 2 % relative error of originals
    rel_err = max(abs((x0_fit - x0_known) ./ x0_known));
    assert(rel_err < 0.02, ...
        sprintf('GM(1,1) fitted-series max relative error %.4f exceeds 2%%.', rel_err));

    fprintf('gm11_predict self-test passed. (a=%.5f, maxRelErr=%.4f%%)\n', ...
        a_val, rel_err * 100);
end
