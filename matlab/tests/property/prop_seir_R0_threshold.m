% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_seir_R0_threshold(n_trials)
%% PROP_SEIR_R0_THRESHOLD Property test: R0 > 1 implies outbreak (I peaks > initial I).
%  Invariant: When basic reproduction number R0 = beta/gamma > 1,
%             the infectious population should peak above its initial value.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    N_pop = 10000 + randi([1000, 50000]);
    I0_val = randi([1, max(1, floor(N_pop * 0.02))]);
    E0_val = randi([0, max(0, floor(N_pop * 0.01))]);
    R0_init = 0;
    S0 = N_pop - E0_val - I0_val - R0_init;
    if S0 <= 0, continue; end

    % Ensure R0 > 1
    gamma = 0.02 + rand() * 0.3;
    beta = gamma * (1.5 + rand() * 4);  % R0 in (1.5, 5.5)
    sigma = 0.1 + rand() * 0.5;
    t_span = [0, 100 + randi([0, 200])];

    try
        [t, S, E, I, R] = seir_model('solve', S0, E0_val, I0_val, R0_init, ...
            beta, sigma, gamma, t_span, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['SEIR solve failed: ' ME.message]);
        continue;
    end

    R0_val = seir_model('R0', beta, gamma);

    % Invariant: if R0 > 1, then I peak > I(0)
    I_peak = max(I);
    if R0_val > 1 && I_peak <= I0_val * 1.01
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('R0=%.2f > 1 but I_peak=%.1f <= I0=%.1f', ...
            R0_val, I_peak, I0_val));
    end

    % Also verify basic R0 formula
    R0_expected = beta / gamma;
    if abs(R0_val - R0_expected) > 1e-10
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('R0 mismatch: computed=%.4f, expected=%.4f', ...
            R0_val, R0_expected));
    end
end
end

%% Self-test
function self_test()
    result = prop_seir_R0_threshold(5);
    assert(result.pass, 'Self-test failed: SEIR R0 threshold violated.');
    fprintf('prop_seir_R0_threshold self-test PASSED (%d trials).\n', result.n_trials);
end
