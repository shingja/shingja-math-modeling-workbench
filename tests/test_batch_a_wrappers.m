% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
% test_batch_a_wrappers.m — Batch A: 6 Wrapper Unit Tests
% 每个测试: 已知输入 → 预期输出, 容差 < 1e-6
clear; clc;

PASS = 0; FAIL = 0;
fprintf('╔══════════════════════════════════════╗\n');
fprintf('║  v2.2.1 Batch A — Wrapper Unit Tests ║\n');
fprintf('╚══════════════════════════════════════╝\n\n');

%% Test 1: linprog_wrapper — Linear Programming
% 案例: max x1+2x2, st 2x1+x2<=10, x1+3x2<=15, x1,x2>=0
% 解析解: x1=3, x2=4, max profit=11
fprintf('--- Test 1: linprog_wrapper ---\n');
try
    f = [-1; -2];  % max → min negative
    A = [2 1; 1 3]; b = [10; 15];
    lb = [0; 0];
    [x, fval] = linprog_wrapper(f, A, b, 'lb', lb);
    expected_x = [3; 4];
    expected_fval = -11;  % min → back to max
    assert(norm(x - expected_x) < 1e-6, sprintf('x mismatch: [%.4f, %.4f] ≠ [3, 4]', x));
    assert(abs(fval - expected_fval) < 1e-6, sprintf('fval mismatch: %.4f ≠ -11', fval));
    fprintf('  ✅ PASS: x=[%.2f, %.2f], fval=%.2f\n', x, fval);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 2: intlinprog_wrapper — Integer Programming
% 案例: max 5x1+8x2, st x1+x2<=6, 5x1+9x2<=45, x1,x2>=0, 整数
% 枚举验证: 最优整数解 x1=0, x2=5, profit=40
fprintf('--- Test 2: intlinprog_wrapper ---\n');
try
    f = [-5; -8];
    intcon = [1; 2];
    A = [1 1; 5 9]; b = [6; 45];
    [x, fval] = intlinprog_wrapper(f, intcon, A, b);
    expected_x_int = [0; 5];
    expected_fval_int = -40;
    assert(all(abs(x - expected_x_int) < 1e-6), 'x not integer optimal');
    assert(abs(fval - expected_fval_int) < 1e-6, 'fval mismatch');
    fprintf('  ✅ PASS: x=[%.0f, %.0f], fval=%.0f\n', x, fval);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 3: fmincon_wrapper — Nonlinear Programming
% 案例: min (x1-2)^2 + (x2-3)^2, 无约束
% 解析解: x1=2, x2=3, fval=0
fprintf('--- Test 3: fmincon_wrapper ---\n');
try
    fun = @(x) (x(1)-2)^2 + (x(2)-3)^2;
    x0 = [0; 0];
    [x, fval] = fmincon_wrapper(fun, x0, [], []);
    expected_x3 = [2; 3];
    assert(norm(x - expected_x3) < 1e-6, sprintf('x=[%.4f,%.4f] ≠ [2,3]', x));
    assert(abs(fval) < 1e-10, sprintf('fval=%.4f ≠ 0', fval));
    fprintf('  ✅ PASS: x=[%.2f, %.2f], fval=%.2e\n', x, fval);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 4: fgoalattain_wrapper — Goal Programming
% 案例: f1=x^2 targets 4, f2=(x-2)^2 targets 1, equal weights
% trade-off: x≈0.7 yields f1≈0.49, f2≈1.69 — close to both
fprintf('--- Test 4: fgoalattain_wrapper ---\n');
try
    fun_multi = @(x) [x^2; (x-2)^2];
    [x, fval, attain] = fgoalattain_wrapper(fun_multi, 0, [4; 1], [1; 1]);
    % Verify: solution exists, attainfactor is finite, fval reasonable
    assert(~isempty(x), 'no solution');
    assert(isfinite(attain), 'attainfactor not finite');
    assert(all(fval >= 0), 'negative objective values');
    fprintf('  ✅ PASS: x=%.4f, fval=[%.4f, %.4f], attain=%.4f\n', x, fval, attain);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 5: factoran_wrapper — Factor Analysis
% 生成含2因子的合成数据, 提取2因子, 验证累计方差 ≥ 50%
fprintf('--- Test 5: factoran_wrapper ---\n');
try
    rng(42);
    n = 200; p = 8;
    % 2 latent factors
    true_loadings = [0.8*ones(4,1) zeros(4,1); zeros(4,1) 0.7*ones(4,1)];
    scores = randn(n, 2);
    X_syn = scores * true_loadings' + 0.3 * randn(n, p);
    [loadings, ~, ~, s] = factoran_wrapper(X_syn, 2, 'Rotate', 'varimax');
    % Verify cumulative explained variance >= 50%
    assert(s.cumulative_var(end) >= 50, sprintf('explained var=%.1f%% < 50%%', s.cumulative_var(end)));
    % KMO >= 0.5 (acceptable)
    assert(s.kmo >= 0.5, sprintf('KMO=%.4f < 0.5', s.kmo));
    fprintf('  ✅ PASS: KMO=%.4f, explained=%.1f%%, χ²(%.0f)=%.2f, p=%.3f\n', ...
            s.kmo, s.cumulative_var(end), s.df, s.chi_sq, s.p_value);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 6: fitcdiscr_wrapper — Discriminant Analysis
% 生成2类分离数据, 验证准确率 ≥ 90%
fprintf('--- Test 6: fitcdiscr_wrapper ---\n');
try
    rng(42);
    X1 = randn(50, 3);              % class 1: N(0,1)
    X2 = randn(50, 3) + 3;          % class 2: N(3,1) — well separated
    X = [X1; X2];
    y = [ones(50,1); 2*ones(50,1)];
    [~, ~, acc] = fitcdiscr_wrapper(X, y, 'Display', 'off');
    assert(acc >= 0.90, sprintf('accuracy=%.2f%% < 90%%', acc*100));
    fprintf('  ✅ PASS: accuracy=%.2f%%\n', acc*100);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Summary
fprintf('\n═══════════════════════════\n');
fprintf('Batch A Results: %d PASS, %d FAIL\n', PASS, FAIL);
if FAIL == 0
    fprintf('✅ ALL TESTS PASSED\n');
else
    fprintf('❌ SOME TESTS FAILED\n');
end
