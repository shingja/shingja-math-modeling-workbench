% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function varargout = markov_chain(mode, varargin)
%% MARKOV_CHAIN  Markov chain analysis toolkit.
%  Paradigm: PARADIGM-0702-MARKOV-CHAIN. Category: Comprehensive. v3.0.0.
%  Reference: Kemeny, J.G. & Snell, J.L. (1960) Finite Markov Chains.
%             Van Nostrand. ISBN: 978-0387901923.
%  Reference: Norris, J.R. (1997) Markov Chains. Cambridge Univ. Press.
%             DOI: 10.1017/CBO9780511810633.
%
%  Usage:
%    pi         = markov_chain('steady_state', P)
%    history    = markov_chain('evolve', pi0, P, n_steps)
%    class_info = markov_chain('classify', P)
%    E_T        = markov_chain('absorption_time', P)
%
%  Input:
%    P      - Transition probability matrix (n x n), rows sum to 1
%    pi0    - Initial distribution (1 x n) or (n x 1)
%    n_steps - Number of evolution steps
%
%  Options (name-value pairs appended after required arguments):
%    'tol'  - Numerical tolerance (default: 1e-10)
%    'seed' - RNG seed (default: 42)
%
%  Output:
%    steady_state - Stationary distribution pi (row vector, pi = pi*P)
%    evolve       - State distribution history ((n_steps+1) x n)
%    classify     - Struct with fields: .absorbing_states, .transient_states,
%                   .recurrent_states, .communicating_classes
%    absorption_time - Expected steps to absorption from each transient state

arguments
    mode (1,1) string
end
arguments (Repeating)
    varargin
end

% ---- Parse common options ----
opts.tol  = 1e-10;
opts.seed = 42;

remain = varargin;
extra_args = {};
i = 1;
while i <= length(remain)
    if ischar(remain{i}) || isstring(remain{i})
        key = char(remain{i});
        if i + 1 <= length(remain)
            val = remain{i+1};
            switch lower(key)
                case 'tol',  opts.tol  = val;
                case 'seed', opts.seed = val;
                otherwise
                    extra_args{end+1} = remain{i};   %#ok<AGROW>
                    extra_args{end+1} = remain{i+1}; %#ok<AGROW>
            end
            i = i + 2;
        else
            extra_args{end+1} = remain{i}; %#ok<AGROW>
            i = i + 1;
        end
    else
        extra_args{end+1} = remain{i}; %#ok<AGROW>
        i = i + 1;
    end
end

rng(opts.seed, 'twister');
exitflag = 1;
tol = opts.tol;

% IO note: save(fullfile(output_dir, 'markov_chain_results.mat'), 'pi', 'history', 'class_info');

%% ---- Dispatch ----
switch lower(mode)
    case 'steady_state'
        assert(~isempty(extra_args) && isnumeric(extra_args{1}), ...
            'steady_state mode requires transition matrix P.');
        P = extra_args{1};
        pi_vec = mc_steady_state_impl(P, tol);
        varargout{1} = pi_vec;

    case 'evolve'
        assert(length(extra_args) >= 3, ...
            'evolve mode requires pi0, P, n_steps.');
        pi0     = extra_args{1};
        P       = extra_args{2};
        n_steps = extra_args{3};
        history = mc_evolve_impl(pi0, P, n_steps, tol);
        varargout{1} = history;

    case 'classify'
        assert(~isempty(extra_args) && isnumeric(extra_args{1}), ...
            'classify mode requires transition matrix P.');
        P = extra_args{1};
        class_info = mc_classify_impl(P, tol);
        varargout{1} = class_info;

    case 'absorption_time'
        assert(~isempty(extra_args) && isnumeric(extra_args{1}), ...
            'absorption_time mode requires transition matrix P.');
        P = extra_args{1};
        E_T = mc_absorption_time_impl(P, tol);
        varargout{1} = E_T;

    otherwise
        error('MARKOV_CHAIN: unknown mode ''%s''. Valid: steady_state, evolve, classify, absorption_time.', mode);
end

%% ==================== Nested: steady state via eigendecomposition ====================
    function pi_vec = mc_steady_state_impl(P, tol)
        n = size(P, 1);
        assert(size(P, 2) == n, 'P must be square.');
        assert(all(abs(sum(P, 2) - 1) < tol), ...
            'Each row of P must sum to 1 (within tol=%.1e).', tol);
        assert(all(P(:) >= -tol), 'P must contain non-negative entries.');

        % pi * P = pi  =>  P' * pi' = pi'
        % pi is the left eigenvector of P with eigenvalue 1
        [V, D] = eig(P');

        % Find eigenvalue closest to 1
        evals = diag(D);
        [~, idx] = min(abs(evals - 1));

        pi_vec = V(:, idx);
        pi_vec = real(pi_vec);  % ensure real

        % Normalize to stochastic vector
        pi_sum = sum(pi_vec);
        assert(abs(pi_sum) > tol, ...
            'MARKOV_CHAIN: degenerate eigenvector (sum=%.6e).', pi_sum);
        pi_vec = pi_vec / pi_sum;

        % Ensure non-negative
        if any(pi_vec < -tol)
            warning('MARKOV_CHAIN:NegativeSteadyState', ...
                'Steady-state distribution has negative entries (min=%.4e).', min(pi_vec));
        end
        pi_vec = max(0, pi_vec);
        pi_vec = pi_vec / sum(pi_vec);

        % Make row vector
        pi_vec = pi_vec(:)';

        % Convergence check: ||pi*P - pi|| < tol
        residual = norm(pi_vec * P - pi_vec, 1);
        assert(residual < 100 * tol, ...
            'MARKOV_CHAIN: steady-state residual = %.4e exceeds tolerance.', residual);

        % Sanity checks
        assert(abs(sum(pi_vec) - 1) < tol, ...
            'MARKOV_CHAIN: steady-state does not sum to 1 (sum=%.6e).', sum(pi_vec));
    end

%% ==================== Nested: evolve ====================
    function history = mc_evolve_impl(pi0, P, n_steps, tol)
        n = size(P, 1);
        pi0 = pi0(:)';
        assert(length(pi0) == n, 'pi0 length must match P dimension.');
        assert(abs(sum(pi0) - 1) < tol, 'pi0 must sum to 1.');

        history = zeros(n_steps + 1, n);
        history(1, :) = pi0;
        pi_cur = pi0;

        for t = 1:n_steps
            pi_cur = pi_cur * P;
            % Renormalize to prevent drift
            s = sum(pi_cur);
            if abs(s - 1) > tol
                pi_cur = pi_cur / s;
            end
            history(t + 1, :) = pi_cur;

            % Numerical safety
            if any(~isfinite(pi_cur))
                warning('MARKOV_CHAIN:NumericalFailure', ...
                    'Non-finite values at step %d.', t);
                history(t+2:end, :) = NaN;
                break;
            end
        end

        assert(all(isfinite(history(end, :))), ...
            'MARKOV_CHAIN: final state contains NaN/Inf.');
    end

%% ==================== Nested: classify states ====================
    function class_info = mc_classify_impl(P, tol)
        n = size(P, 1);
        assert(size(P, 2) == n, 'P must be square.');

        % 1. Absorbing states: P(i,i) = 1
        absorbing = abs(diag(P) - 1) < tol;
        absorbing_idx = find(absorbing);

        % 2. Build reachability graph via transitive closure
        % State j is reachable from i if there exists k such that (P^k)_{ij} > 0
        reachable = (P > tol);
        % Floyd-Warshall style: repeated squaring + OR for transitive closure
        for k = 1:ceil(log2(n)) + 1
            reachable = reachable | (reachable * reachable > 0);
        end
        reachable = reachable | eye(n);  % self-reachable

        % 3. Communicating classes via SCC: i<->j iff reachable(i,j) AND reachable(j,i)
        comm = reachable & reachable';
        % Find connected components in the undirected communication graph
        visited = false(n, 1);
        classes = {};
        state_class = zeros(n, 1);
        class_id = 0;

        for s = 1:n
            if ~visited(s)
                class_id = class_id + 1;
                % BFS within communication graph
                queue = s;
                visited(s) = true;
                members = [];
                while ~isempty(queue)
                    u = queue(1);
                    queue(1) = [];
                    members = [members, u]; %#ok<AGROW>
                    state_class(u) = class_id;
                    for v = 1:n
                        if comm(u, v) && ~visited(v)
                            visited(v) = true;
                            queue = [queue, v]; %#ok<AGROW>
                        end
                    end
                end
                classes{class_id} = members; %#ok<AGROW>
            end
        end

        % 4. Classify each class as recurrent/transient
        is_recurrent_class = false(class_id, 1);
        for cid = 1:class_id
            members = classes{cid};
            % A class is closed (recurrent) if no transitions leave it
            leaves_class = false;
            for u = members
                for v = 1:n
                    if P(u, v) > tol && state_class(v) ~= cid
                        leaves_class = true;
                        break;
                    end
                end
                if leaves_class, break; end
            end
            is_recurrent_class(cid) = ~leaves_class;
        end

        % 5. Assign states
        recurrent_states = [];
        transient_states = [];
        for cid = 1:class_id
            if is_recurrent_class(cid)
                recurrent_states = [recurrent_states, classes{cid}]; %#ok<AGROW>
            else
                transient_states = [transient_states, classes{cid}]; %#ok<AGROW>
            end
        end

        class_info = struct();
        class_info.absorbing_states   = absorbing_idx(:)';
        class_info.transient_states   = transient_states(:)';
        class_info.recurrent_states   = recurrent_states(:)';
        class_info.communicating_classes = classes;
        class_info.is_recurrent_class = is_recurrent_class;

        % Sanity
        assert(length(absorbing_idx) + length(transient_states) + ...
               length(recurrent_states) >= n - length(intersect(absorbing_idx, recurrent_states)), ...
               'MARKOV_CHAIN: state classification count mismatch.');
    end

%% ==================== Nested: absorption time ====================
    function E_T = mc_absorption_time_impl(P, tol)
        n = size(P, 1);
        assert(size(P, 2) == n, 'P must be square.');

        % Identify absorbing states
        absorbing = abs(diag(P) - 1) < tol;

        if all(absorbing)
            E_T = zeros(0, 1);
            return;
        end
        if ~any(absorbing)
            warning('MARKOV_CHAIN:NoAbsorbingStates', ...
                'No absorbing states found. Absorption time is infinite.');
            E_T = inf(n, 1);
            return;
        end

        % Reorder: transient states first, then absorbing
        trans_idx = find(~absorbing);
        abs_idx   = find(absorbing);
        n_T = length(trans_idx);

        % Fundamental matrix approach:
        % Q = submatrix of P restricted to transient states
        % N = (I - Q)^{-1}  -- fundamental matrix
        % E[T_i] = sum_j N_{ij} (expected steps from transient i to absorption)
        Q = P(trans_idx, trans_idx);
        I_mat = eye(n_T);
        N = (I_mat - Q) \ I_mat;  % N = inv(I - Q)

        % Expected absorption time from each transient state
        E_T_trans = sum(N, 2);

        % Check convergence: all expected values should be finite
        assert(all(isfinite(E_T_trans)), ...
            'MARKOV_CHAIN: non-finite absorption times detected.');

        % Map back to original state indices
        E_T = inf(n, 1);
        E_T(trans_idx) = E_T_trans;
        E_T(abs_idx)   = 0;  % already absorbed
    end

%% Self-test
function self_test()
    tol = 1e-10;

    % ---- Test 1: 3-state ergodic chain ----
    % P = [0.5, 0.3, 0.2; 0.1, 0.6, 0.3; 0.2, 0.1, 0.7]
    P = [0.5, 0.3, 0.2;
         0.1, 0.6, 0.3;
         0.2, 0.1, 0.7];

    pi_val = markov_chain('steady_state', P, 'tol', tol);

    % Assert 1: pi*P = pi (stationarity)
    residual = norm(pi_val * P - pi_val, 1);
    assert(residual < 1e-8, ...
        'Self-test FAILED: steady-state residual norm = %.4e > 1e-8.', residual);

    % Assert 2: sum(pi) = 1
    assert(abs(sum(pi_val) - 1) < tol, ...
        'Self-test FAILED: sum(pi) = %.10f, expected 1.0.', sum(pi_val));

    % Assert 3: all pi > 0 (ergodic chain)
    assert(all(pi_val > 0), ...
        'Self-test FAILED: negative/zero steady-state probability detected.');

    % Assert 4: evolve converges to steady-state
    pi0 = [1, 0, 0];
    hist_data = markov_chain('evolve', pi0, P, 200, 'tol', tol);
    final_dist = hist_data(end, :);
    assert(norm(final_dist - pi_val, 1) < 1e-6, ...
        'Self-test FAILED: evolved distribution did not converge to steady-state.');

    % ---- Test 2: Absorbing chain ----
    % P_abs = [1, 0, 0; 0.3, 0.4, 0.3; 0, 0, 1]
    % State 1 and 3 are absorbing. State 2 is transient.
    P_abs = [1.0, 0.0, 0.0;
             0.3, 0.4, 0.3;
             0.0, 0.0, 1.0];

    class_info = markov_chain('classify', P_abs, 'tol', tol);

    % Assert 5: Absorbing states detected
    assert(~isempty(class_info.absorbing_states), ...
        'Self-test FAILED: absorbing states not detected.');
    assert(ismember(1, class_info.absorbing_states) && ...
           ismember(3, class_info.absorbing_states), ...
        'Self-test FAILED: expected states 1,3 to be absorbing.');

    % Assert 6: Expected absorption time
    E_T_vals = markov_chain('absorption_time', P_abs, 'tol', tol);
    % For state 2: from each step, prob 0.6 stays transient, 0.6 total absorption prob
    % E[T_2] = 1 + 0.4*E[T_2] => 0.6*E[T_2] = 1 => E[T_2] = 1/0.6 ≈ 1.6667
    expected_E2 = 1 / 0.6;
    assert(abs(E_T_vals(2) - expected_E2) < 1e-6, ...
        'Self-test FAILED: absorption time for state 2 = %.6f, expected %.6f.', ...
        E_T_vals(2), expected_E2);

    % Assert 7: Absorbing states have zero absorption time
    assert(E_T_vals(1) == 0 && E_T_vals(3) == 0, ...
        'Self-test FAILED: absorbing states should have 0 absorption time.');

    disp('MARKOV_CHAIN self-test passed.');
end
end
