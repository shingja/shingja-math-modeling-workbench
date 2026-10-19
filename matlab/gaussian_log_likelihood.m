% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function ll = gaussian_log_likelihood(X, mu, sigma)
% GAUSSIAN_LOG_LIKELIHOOD Gaussian log-likelihood
n = size(X, 1);
sigma_safe = max(sigma, 1e-9);
diff_sq = ((X - mu) ./ sigma_safe).^2;
ll = -0.5 * sum(diff_sq + log(2 * pi * sigma_safe.^2), 2);
end

%% Self-test
function self_test()
    % Test N(0,1) log-lik known value
    x = [0; 1; -1];
    ll = gaussian_log_likelihood(x, 0, 1);
    % log N(0|0,1) = -0.5 * log(2*pi) ≈ -0.9189
    expected_0 = -0.5 * log(2 * pi);
    assert(abs(ll(1) - expected_0) < 1e-6, 'Test failed: log N(0|0,1) value mismatch.');
    disp('gaussian_log_likelihood self-test passed.');
end
