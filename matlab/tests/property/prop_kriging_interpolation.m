% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_kriging_interpolation(n_trials)
%% PROP_KRIGING_INTERPOLATION Property test: Kriging prediction at training point = training value.
%  Invariant: For a noise-free GP, prediction at training inputs
%             should equal the training outputs exactly.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    N = randi([5, 30]);
    D = randi([1, 3]);
    X = rand(N, D) * 10;
    y = sum(X.^2, 2) + randn(N, 1) * 0.01;  % nearly noise-free quadratic

    try
        [model, mu_pred, ~, ~] = kriging_gpr(X, y, X, 'seed', 42+i, ...
            'optimize_hyperparams', false);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Kriging failed: ' ME.message]);
        continue;
    end

    % Invariant: prediction at training points should closely match training values
    abs_err = abs(mu_pred(:) - y(:));
    max_err = max(abs_err);

    % With optimize_hyperparams=false and simple kernel, should be very close
    if max_err > 0.5
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('Kriging interpolation error: max|err|=%.4f', max_err));
    end
end
end

%% Self-test
function self_test()
    result = prop_kriging_interpolation(5);
    assert(result.pass, 'Self-test failed: kriging interpolation violated.');
    fprintf('prop_kriging_interpolation self-test PASSED (%d trials).\n', result.n_trials);
end
