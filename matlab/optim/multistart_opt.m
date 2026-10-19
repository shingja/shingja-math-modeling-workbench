% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [xbest, fbest, exitflag, all_solutions] = multistart_opt(objfun, lb, ub, options)
%% MULTISTART_OPT MultiStart + fmincon global optimization wrapper. Paradigm: PARADIGM-0116-MULTI-START. v3.0.0.
%  Reference: Ugray et al. (2007) INFORMS J. Computing 19(3):328-340. DOI:10.1287/ijoc.1060.0181
%  Requirement 5 (fullfile): not_applicable -- no file IO.
arguments
    objfun (1,1) function_handle
    lb (:,1) double
    ub (:,1) double
    options.NumStartPoints (1,1) double {mustBePositive} = 10
    options.Display (1,1) string = "off"
    options.seed (1,1) double = 42
    options.Algorithm (1,1) string = "sqp"
    options.MaxTime (1,1) double {mustBePositive} = 300
    options.OptimalityTolerance (1,1) double {mustBePositive} = 1e-6
end
rng(options.seed, 'twister');
% Validate input dimensions and bounds
nvars = numel(lb);
assert(numel(ub) == nvars, ...
    'multistart_opt: lb and ub must have the same number of elements.');
assert(all(ub > lb), ...
    'multistart_opt: ub must be strictly greater than lb element-wise.');
% Verify objective function validity
xmid = (lb + ub) / 2;
fmid = objfun(xmid);
assert(isscalar(fmid) && isfinite(fmid), ...
    'multistart_opt: objfun must return a finite scalar.');
% Configure fmincon solver options
fmincon_opts = optimoptions('fmincon', ...
    'Algorithm', char(options.Algorithm), ...
    'Display', char(options.Display), ...
    'MaxFunctionEvaluations', 10000, ...
    'MaxIterations', 4000, ...
    'OptimalityTolerance', options.OptimalityTolerance, ...
    'ConstraintTolerance', 1e-6, ...
    'StepTolerance', 1e-10);
% Build the optimization problem structure
problem = createOptimProblem('fmincon', ...
    'objective', objfun, ...
    'x0', xmid, ...
    'lb', lb, ...
    'ub', ub, ...
    'options', fmincon_opts);
% Create the MultiStart object
ms = MultiStart('Display', char(options.Display), ...
    'UseParallel', false, ...
    'MaxTime', options.MaxTime, ...
    'StartPointsToRun', 'bounds-ineqs');
% Generate Latin Hypercube start points for better coverage
npts = options.NumStartPoints;
tpoints = lhsdesign(npts, nvars);
custompts = repmat(lb', npts, 1) + repmat(ub' - lb', npts, 1) .* tpoints;
% Run MultiStart optimization
[xbest, fbest, exitflag, all_solutions] = run(ms, problem, custompts);
% Convergence assessment and reporting
n_converged = sum([all_solutions(:).Exitflag] > 0);
n_total = numel(all_solutions);
if exitflag <= 0
    warning('multistart_opt: best run exitflag=%d. Converged runs: %d/%d.', ...
        exitflag, n_converged, n_total);
else
    fprintf('multistart_opt: best exitflag=%d. Converged runs: %d/%d.\n', ...
        exitflag, n_converged, n_total);
end
% Numerical sanity checks
assert(isfinite(fbest), ...
    'multistart_opt: best objective value is non-finite.');
assert(all(isfinite(xbest)), ...
    'multistart_opt: best solution contains non-finite values.');
% Verify best solution satisfies bounds
tol_bnd = 1e-6;
in_bounds = all(xbest >= lb - tol_bnd) && all(xbest <= ub + tol_bnd);
assert(in_bounds, ...
    'multistart_opt: best solution violates bound constraints.');
% fbest should not be worse than the midpoint value
assert(fbest <= fmid + 1e-6, ...
    'multistart_opt: optimized fbest=%.6e is worse than midpoint fmid=%.6e.', fbest, fmid);
% Store convergence summary in all_solutions for downstream use
fprintf('multistart_opt: fbest=%.6e, %d/%d runs converged, %d funcCount (best).\n', ...
    fbest, n_converged, n_total, all_solutions(1).output.funcCount);
end

%% Self-test
function self_test()
    % Rastrigin 2D: f(x)=20 + sum(x_i^2 - 10*cos(2*pi*x_i))
    % Known global minimum: x=[0,0], f=0
    rastrigin = @(x) 20 + x(1)^2 + x(2)^2 ...
        - 10 * (cos(2*pi*x(1)) + cos(2*pi*x(2)));

    [xb, fb, ef, sols] = multistart_opt(rastrigin, [-5.12; -5.12], [5.12; 5.12], ...
        NumStartPoints=5, seed=42, Algorithm="sqp");

    % Assert 1: exitflag of best run should be nonnegative
    assert(ef >= 0, ...
        sprintf('Rastrigin: best exitflag=%d, expected nonnegative', ef));

    % Assert 2: best solution should be near the global minimum [0,0]
    dist = norm(xb - [0; 0]);
    assert(dist < 1.5, ...
        sprintf('Rastrigin: xbest=[%.4f,%.4f] too far from [0,0], dist=%.4f', ...
        xb(1), xb(2), dist));

    % Assert 3: best objective value should be close to 0
    assert(fb < 5.0, ...
        sprintf('Rastrigin: fbest=%.6f should be near 0', fb));

    % Assert 4: at least one run should have converged
    nconv = sum([sols(:).Exitflag] > 0);
    assert(nconv >= 1, ...
        sprintf('Rastrigin: 0/%d runs converged, expected >= 1', numel(sols)));

    fprintf('multistart_opt self-test passed (Rastrigin 2D, dist=%.4f, fbest=%.6f).\n', dist, fb);
end
