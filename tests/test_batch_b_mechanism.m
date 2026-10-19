% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
% test_batch_b_mechanism.m — Batch B: 4 Mechanism Model Unit Tests
clear; clc;

PASS = 0; FAIL = 0;
TOL = 1e-6;
fprintf('╔══════════════════════════════════════════╗\n');
fprintf('║  v2.2.1 Batch B — Mechanism Unit Tests   ║\n');
fprintf('╚══════════════════════════════════════════╝\n\n');

%% Test 1: Malthus — Analytical solution verification
% N(t) = N0 * exp(r*t)
% N0=100, r=ln(2), t=10 → N(10) = 100 * 2^10 = 102400
fprintf('--- Test 1: malthus_model ---\n');
try
    N0 = 100; r = log(2);
    [t, N] = malthus_model(N0, r, [0, 10], 'nPoints', 11);
    expected_N_end = N0 * exp(r * 10);  % = 100 * 1024 = 102400
    assert(abs(N(end) - expected_N_end) < TOL, ...
        sprintf('N(end)=%.1f ≠ %.1f', N(end), expected_N_end));
    % Verify monotonic growth
    assert(all(diff(N) > 0), 'population not monotonically increasing');
    fprintf('  ✅ PASS: N(0)=%.1f, N(10)=%.1f (expected %.1f)\n', N(1), N(end), expected_N_end);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 2: Logistic — Carrying capacity & inflection point
% N0=10, r=0.5, K=1000 → approaches K
% Inflection at N=500 (K/2)
fprintf('--- Test 2: logistic_model ---\n');
try
    [t, N, kp] = logistic_model(10, 0.5, 1000, [0, 30]);
    % Final population < K (approaches from below)
    assert(N(end) < 1000, 'exceeds K');
    assert(N(end) > 950, sprintf('too far from K: %.1f', N(end)));
    % Inflection point exists
    assert(~isnan(kp.inflection_t), 'no inflection point');
    assert(abs(kp.inflection_N - 500) < 1, sprintf('inflection N=%.1f ≠ 500', kp.inflection_N));
    fprintf('  ✅ PASS: N(end)=%.1f (K=1000), inflection at t=%.2f N=%.1f\n', ...
            N(end), kp.inflection_t, kp.inflection_N);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 3: Leslie — Eigenvalue determines long-term growth
% Construct known matrix: λ1=1.2 (growing), λ1=0.8 (declining)
fprintf('--- Test 3: leslie_model ---\n');
try
    % 3-age-group: λ1 ≈ 1.1 (growing)
    L = [0 1.5 2.0;
         0.6 0   0;
         0   0.7 0];
    N0 = [100; 80; 60];
    [~, pop, ~] = leslie_model(N0, L, 30, 'Display', 'off');
    % Population grows (λ1 > 1)
    assert(pop(end) > pop(1), 'population should grow');
    % Eigenvalue check
    lambda1 = max(abs(eig(L)));
    fprintf('  ✅ PASS: pop(0)=%.0f → pop(30)=%.0f, λ1=%.4f\n', pop(1), pop(end), lambda1);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 4: SIS — R0 threshold behavior
% R0 > 1 → endemic equilibrium; R0 < 1 → dies out
fprintf('--- Test 4a: SIS (R0 > 1) ---\n');
try
    [t, S, I, kp] = sis_model(950, 50, 0.5, 0.1, [0, 50], 'Display', 'off');
    assert(kp.R0 > 1, sprintf('R0=%.2f should be > 1', kp.R0));
    assert(I(end) > 0, 'should reach endemic equilibrium');
    assert(abs(kp.I_steady - I(end)) < 1, ...
        sprintf('final I=%.1f ≠ steady %.1f', I(end), kp.I_steady));
    fprintf('  ✅ PASS: R0=%.2f, I(0)=%.0f → I(end)=%.1f (steady=%.1f)\n', ...
            kp.R0, I(1), I(end), kp.I_steady);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

fprintf('--- Test 4b: SIS (R0 < 1) ---\n');
try
    [t, S, I, kp] = sis_model(950, 50, 0.001, 0.2, [0, 50], 'Display', 'off');
    assert(kp.R0 < 1, sprintf('R0=%.2f should be < 1', kp.R0));
    % Disease dies out
    assert(I(end) < 5, sprintf('should die out, I(end)=%.1f', I(end)));
    fprintf('  ✅ PASS: R0=%.2f, I drops to %.1f (die-out)\n', kp.R0, I(end));
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Summary
fprintf('\n═══════════════════════════\n');
fprintf('Batch B Results: %d PASS, %d FAIL\n', PASS, FAIL);
if FAIL == 0
    fprintf('✅ ALL TESTS PASSED\n');
else
    fprintf('❌ SOME TESTS FAILED\n');
end
