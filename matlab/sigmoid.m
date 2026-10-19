% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function s = sigmoid(z)
% SIGMOID Numerically stable sigmoid function
s = 1 ./ (1 + exp(-min(max(z, -50), 50)));
end

%% Self-test
function self_test()
    % Test sigmoid(0) = 0.5
    assert(abs(sigmoid(0) - 0.5) < 1e-6, 'Test failed: sigmoid(0) should be 0.5.');
    assert(sigmoid(10) > 0.99, 'Test failed: sigmoid(10) should be near 1.');
    assert(sigmoid(-10) < 0.01, 'Test failed: sigmoid(-10) should be near 0.');
    disp('sigmoid self-test passed.');
end
