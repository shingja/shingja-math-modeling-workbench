% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [xbest, fbest, exitflag, output] = surrogateopt_wrapper(objfun, lb, ub, options)
%% SURROGATEOPT_WRAPPER Surrogate optimization wrapper. Paradigm: PARADIGM-0117-SURROGATE-OPT. v3.0.0.
%  Reference: Gutmann (2001) J Global Optimization. DOI:10.1023/A:1011207517955
%  Requirement 5 (fullfile): not_applicable -- no file I/O.
arguments
    objfun (1,1) function_handle
    lb (:,1) double
    ub (:,1) double
    options.MaxFunctionEvaluations (1,1) double {mustBePositive} = 200
    options.seed (1,1) double = 42
end
rng(options.seed, 'twister');
nvars = numel(lb);
opts = optimoptions('surrogateopt', 'MaxFunctionEvaluations', options.MaxFunctionEvaluations);
[xbest, fbest, exitflag, output] = surrogateopt(objfun, lb, ub, opts);
%% Self-test
function self_test()
    f = @(x) (1-x(1))^2 + 100*(x(2)-x(1)^2)^2;
    [xb, fb, ef] = surrogateopt_wrapper(f, [-5;-5], [5;5], MaxFunctionEvaluations=50, seed=42);
    assert(ef >= 0, 'surrogateopt exitflag nonnegative');
    assert(fb < 5.0, sprintf('fbest=%.4f should be near 0', fb));
    assert(norm(xb - [1;1]) < 2.0, 'xbest far from Rosenbrock optimum [1,1]');
    disp('surrogateopt_wrapper self-test passed.');
end
end
