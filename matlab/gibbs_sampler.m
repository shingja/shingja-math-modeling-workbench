% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [samples] = gibbs_sampler(conditional_samplers, x0, n_samples, burn_in)
% GIBBS_SAMPLER Gibbs sampling (special case of Metropolis-Hastings)

if nargin < 3 || isempty(n_samples), n_samples = 10000; end
if nargin < 4 || isempty(burn_in), burn_in = 1000; end

d = length(x0);
total_samples = n_samples + burn_in;

samples_all = zeros(total_samples, d);
x = x0(:);
samples_all(1, :) = x';

for t = 2:total_samples
    for j = 1:d
        x_other = x([1:j-1, j+1:end]);
        x(j) = conditional_samplers{j}(x_other);
    end
    samples_all(t, :) = x';
end

samples = samples_all(burn_in+1:end, :);

end

%% Self-test
function self_test()
    % Test sample from bivariate normal (rho=0.7)
    rng(42, 'twister');
    rho = 0.7;
    sampler1 = @(x2) rho * x2 + sqrt(1 - rho^2) * randn();
    sampler2 = @(x1) rho * x1 + sqrt(1 - rho^2) * randn();
    samples = gibbs_sampler({sampler1, sampler2}, [0; 0], 500, 100);
    assert(size(samples, 1) == 500, 'Test failed: should have 500 samples.');
    mu_est = mean(samples, 1);
    assert(all(abs(mu_est) < 0.5), 'Test failed: sample mean should be near 0.');
    disp('gibbs_sampler self-test passed.');
end
