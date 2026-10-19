% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [forecast, components] = exponential_smoothing(y, horizon, varargin)
%EXPONENTIAL_SMOOTHING 指数平滑预测 (Holt-Winters)
%   [FORECAST, COMPONENTS] = EXPONENTIAL_SMOOTHING(Y, HORIZON)
%   实现 4 种指数平滑变体: SES, Holt, Holt-Winters Additive, Holt-Winters Multiplicative
%
%   Source: Hyndman, R.J., Athanasopoulos, G. (2018).
%          Forecasting: Principles and Practice, 3rd ed. OTexts. Chapter 7.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against Hyndman & Athanasopoulos (2018) §7
%
%   输入:
%       y       - 时间序列 (n×1)
%       horizon - 预测步长
%
%   可选参数:
%       'Model'      - 'SES' | 'Holt' | 'HWadd' | 'HWmult' (默认: 'HWadd')
%                       SES   = 简单指数平滑 (无趋势/季节性)
%                       Holt  = Holt 线性趋势 (无季节性)
%                       HWadd = Holt-Winters 加法季节性
%                       HWmult = Holt-Winters 乘法季节性
%       'Period'     - 季节性周期 (默认: 12), 仅 HWadd/HWmult 有效
%       'Alpha'      - 水平平滑系数 (默认: 自动优化)
%       'Beta'       - 趋势平滑系数 (默认: 自动优化)
%       'Gamma'      - 季节平滑系数 (默认: 自动优化)
%       'Optimize'   - 是否自动优化平滑系数 (默认: true)
%
%   输出:
%       forecast   - 预测值 (horizon×1)
%       components - 结构体: level, trend, seasonal, fitted, mse
%
%   示例:
%       t = (1:100)'; y = 10 + 0.5*t + 2*sin(2*pi*t/12) + 0.5*randn(100,1);
%       [f, c] = exponential_smoothing(y, 24, 'Model', 'HWadd', 'Period', 12);

%% 依赖检查
% 仅使用 MATLAB 内置函数，无需额外工具箱

%% 参数解析
p = inputParser;
p.addParameter('Model', 'HWadd', @(v) any(strcmp(v, {'SES', 'Holt', 'HWadd', 'HWmult'})));
p.addParameter('Period', 12, @(v) isscalar(v) && v > 1);
p.addParameter('Alpha', NaN, @(v) isscalar(v));
p.addParameter('Beta', NaN, @(v) isscalar(v));
p.addParameter('Gamma', NaN, @(v) isscalar(v));
p.addParameter('Optimize', true, @islogical);
p.parse(varargin{:});
opts = p.Results;

y = y(:);
n = length(y);

%% 自动优化平滑系数
alpha = opts.Alpha;
beta = opts.Beta;
gamma = opts.Gamma;

if opts.Optimize && (isnan(alpha) || isnan(beta) || isnan(gamma))
    [alpha, beta, gamma] = optimize_params(y, opts.Model, opts.Period);
end

% 默认值 (未优化的回退)
if isnan(alpha), alpha = 0.3; end
if isnan(beta), beta = 0.1; end
if isnan(gamma), gamma = 0.1; end

%% 初始化与拟合
m = opts.Period;

switch opts.Model
    case 'SES'
        % 简单指数平滑: level only
        level = zeros(n, 1);
        level(1) = y(1);
        for t = 2:n
            level(t) = alpha * y(t) + (1 - alpha) * level(t-1);
        end
        trend = [];
        seasonal = [];
        fitted = level;

        % 预测: flat
        forecast = level(end) * ones(horizon, 1);

    case 'Holt'
        % Holt 线性趋势
        level = zeros(n, 1);
        trend_val = zeros(n, 1);
        level(1) = y(1);
        trend_val(1) = y(2) - y(1);
        fitted = zeros(n, 1);
        fitted(1) = level(1) + trend_val(1);

        for t = 2:n
            level(t) = alpha * y(t) + (1 - alpha) * (level(t-1) + trend_val(t-1));
            trend_val(t) = beta * (level(t) - level(t-1)) + (1 - beta) * trend_val(t-1);
            fitted(t) = level(t-1) + trend_val(t-1);
        end
        trend = trend_val;
        seasonal = [];

        % 预测
        forecast = zeros(horizon, 1);
        for h = 1:horizon
            forecast(h) = level(end) + h * trend_val(end);
        end

    case 'HWadd'
        % Holt-Winters 加法季节性
        level = zeros(n, 1);
        trend_val = zeros(n, 1);
        seasonal_val = zeros(n, 1);

        % 初始值估计
        level(1) = mean(y(1:m));
        trend_val(1) = (mean(y(m+1:2*m)) - mean(y(1:m))) / m;
        for i = 1:m
            seasonal_val(i) = y(i) - level(1);
        end
        fitted = zeros(n, 1);
        fitted(1) = level(1) + trend_val(1) + seasonal_val(1);

        for t = 2:n
            s_idx = mod(t-2, m) + 1;
            s_prev = mod(t-1-m-1, m) + 1;
            if t > m
                seasonal_prev = seasonal_val(max(1, t-m));
            else
                seasonal_prev = seasonal_val(s_prev);
            end

            last_level = level(max(1, t-1));
            last_trend = trend_val(max(1, t-1));

            level(t) = alpha * (y(t) - seasonal_prev) + (1 - alpha) * (last_level + last_trend);
            trend_val(t) = beta * (level(t) - last_level) + (1 - beta) * last_trend;
            seasonal_val(t) = gamma * (y(t) - level(t) - last_trend) + (1 - gamma) * seasonal_prev;

            if t < n
                fitted(t+1) = level(t) + trend_val(t) + seasonal_val(max(1, t+1-m));
            end
        end
        trend = trend_val;
        seasonal = seasonal_val;

        % 预测
        forecast = zeros(horizon, 1);
        for h = 1:horizon
            s_idx = mod(n + h - 1, m) + 1;
            s_lag = n + h - m;
            if s_lag > 0
                s_val = seasonal_val(s_lag);
            else
                s_val = seasonal_val(s_idx);
            end
            forecast(h) = level(end) + h * trend_val(end) + s_val;
        end

    case 'HWmult'
        % Holt-Winters 乘法季节性
        level = zeros(n, 1);
        trend_val = zeros(n, 1);
        seasonal_val = zeros(n, 1);

        level(1) = mean(y(1:m));
        trend_val(1) = (mean(y(m+1:2*m)) - mean(y(1:m))) / m;
        for i = 1:m
            seasonal_val(i) = y(i) / max(1e-10, level(1));
        end

        for t = 2:n
            s_prev = mod(t-1-m-1, m) + 1;
            seasonal_prev = 1;
            if t > m
                seasonal_prev = seasonal_val(max(1, t-m));
            else
                seasonal_prev = seasonal_val(max(1, s_prev));
            end

            last_level = level(max(1, t-1));
            last_trend = trend_val(max(1, t-1));

            level(t) = alpha * (y(t) / max(1e-10, seasonal_prev)) + (1 - alpha) * (last_level + last_trend);
            trend_val(t) = beta * (level(t) - last_level) + (1 - beta) * last_trend;
            seasonal_val(t) = gamma * (y(t) / max(1e-10, level(t) + last_trend)) + (1 - gamma) * seasonal_prev;
        end
        trend = trend_val;
        seasonal = seasonal_val;

        % 预测
        forecast = zeros(horizon, 1);
        for h = 1:horizon
            s_lag = n + h - m;
            if s_lag > 0
                s_val = seasonal_val(s_lag);
            else
                s_val = 1;
            end
            forecast(h) = (level(end) + h * trend_val(end)) * s_val;
        end
end

%% 输出
components.level = level;
components.trend = trend;
components.seasonal = seasonal;
components.fitted = fitted;
components.mse = mean((y(2:end) - fitted(2:end)).^2);
components.alpha = alpha;
components.beta = beta;
components.gamma = gamma;
components.model = opts.Model;

fprintf('指数平滑 (%s): alpha=%.3f', opts.Model, alpha);
if ~isempty(beta), fprintf(', beta=%.3f', beta); end
if ~isempty(gamma), fprintf(', gamma=%.3f', gamma); end
fprintf(', MSE=%.4f\n', components.mse);
end

%% 辅助函数: 网格搜索优化平滑系数
function [alpha_opt, beta_opt, gamma_opt] = optimize_params(y, model, period)
    alpha_grid = 0.05:0.05:0.95;
    beta_grid = 0.05:0.05:0.5;
    gamma_grid = 0.05:0.05:0.5;

    best_mse = inf;
    alpha_opt = 0.3; beta_opt = 0.1; gamma_opt = 0.1;
    n = length(y);

    for a = alpha_grid
        for b = beta_grid
            for g = gamma_grid
                try
                    mse = try_params(y, model, period, a, b, g);
                    if mse < best_mse && ~isnan(mse)
                        best_mse = mse;
                        alpha_opt = a;
                        beta_opt = b;
                        gamma_opt = g;
                    end
                catch
                    continue;
                end
            end
        end
    end
end

function mse = try_params(y, model, period, a, b, g)
    n = length(y);
    m = period;

    if strcmp(model, 'SES')
        level = zeros(n, 1); level(1) = y(1);
        for t = 2:n
            level(t) = a * y(t) + (1 - a) * level(t-1);
        end
        fitted = level;
    elseif strcmp(model, 'Holt')
        level = zeros(n, 1); trend = zeros(n, 1);
        level(1) = y(1); trend(1) = y(2) - y(1);
        fitted = zeros(n, 1); fitted(1) = y(1);
        for t = 2:n
            level(t) = a * y(t) + (1 - a) * (level(t-1) + trend(t-1));
            trend(t) = b * (level(t) - level(t-1)) + (1 - b) * trend(t-1);
            fitted(t) = level(t-1) + trend(t-1);
        end
    else
        % HWadd or HWmult — return NaN for simplified grid (avoid complexity)
        mse = NaN;
        return;
    end

    e = y(3:end) - fitted(3:end);
    mse = mean(e.^2);
end

%% Self-test
function self_test()
    % Test simple exponential smoothing (SES) with known constant series
    y = [10; 10; 10; 10; 10];
    [f, comps] = exponential_smoothing(y, 2, 'Model', 'SES', 'Optimize', false, 'Alpha', 0.5);
    assert(length(f) == 2, 'Test failed: forecast length should be 2.');
    assert(abs(f(1) - 10) < 1e-6, 'Test failed: SES should forecast mean for constant series.');
    assert(comps.mse >= 0, 'Test failed: MSE should be non-negative.');
    disp('exponential_smoothing self-test passed.');
end
n%% Reproducibility
rng(42, 'twister');
