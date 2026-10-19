% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [weights, consistency_ratio, exitflag] = bwm(comparisons, options)
%% BWM Best-Worst Method weight determination. Paradigm: PARADIGM-1206-BWM. v3.0.0.
%  Reference: Rezaei (2015) Omega, DOI:10.1016/j.omega.2014.11.009
arguments
    comparisons.best_to_others (1,:) double {mustBePositive}
    comparisons.others_to_worst (1,:) double {mustBePositive}
    options.consistency_threshold (1,1) double = 0.2
end
n = numel(comparisons.best_to_others);
assert(n == numel(comparisons.others_to_worst), 'Vector lengths must match.');
% Build LP: min xi s.t. |w_B/w_j - a_Bj| <= xi, |w_j/w_W - a_jW| <= xi, sum(w)=1, w>=0
f = [1; zeros(n, 1)];
A_ub = zeros(4*n, n+1);
b_ub = zeros(4*n, 1);
for j = 1:n
    A_ub(4*j-3, [1, j+1]) = [-1, -1/comparisons.best_to_others(j)];
    b_ub(4*j-3) = 0;
    A_ub(4*j-2, [1, j+1]) = [-1, 1/comparisons.best_to_others(j)];
    b_ub(4*j-2) = 0;
    A_ub(4*j-1, [1, j+1]) = [-1, -comparisons.others_to_worst(j)];
    b_ub(4*j-1) = 0;
    A_ub(4*j, [1, j+1]) = [-1, comparisons.others_to_worst(j)];
    b_ub(4*j) = 0;
end
A_eq = [0, ones(1, n)];
b_eq = 1;
lb = [-inf; zeros(n, 1)];
[x, ~, exitflag] = linprog(f, A_ub, b_ub, A_eq, b_eq, lb);
xi_opt = x(1);
weights = x(2:end);
consistency_ratio = xi_opt / (2*n);  % simplified CR
if consistency_ratio > options.consistency_threshold
    warning('BWM:Inconsistent', 'Consistency ratio %.3f exceeds threshold.', consistency_ratio);
end
%% Self-test
function self_test()
    best_to_others = [1, 3, 5];
    others_to_worst = [5, 3, 1];
    [w, cr, ef] = bwm(struct('best_to_others',best_to_others,'others_to_worst',others_to_worst));
    assert(ef >= 0, 'LP solver exitflag nonnegative');
    assert(abs(sum(w) - 1.0) < 1e-6, 'Weights sum to 1');
    assert(all(w > 0), 'All weights positive');
    assert(cr < 0.3, 'Consistency ratio reasonable');
    disp('bwm self-test passed.');
end
end
