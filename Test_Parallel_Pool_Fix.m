%% Quick Test: Verify Parallel Pool Restart Fix
% This test simulates the issue by running a short version with parallel

clear all;
close all;
clc;

fprintf('========================================\n');
fprintf('Testing Parallel Pool Restart Fix\n');
fprintf('========================================\n\n');

% Small test to run quickly
N = 20;
iter_max = 50;  % Very short test
K = 10;
use_parallel = true;
final_relax_rate = 0.05;

fprintf('Configuration:\n');
fprintf('  N=%d, iter=%d, K=%d\n', N, iter_max, K);
fprintf('  Parallel: %s\n', string(use_parallel));
fprintf('  Relaxation: %.1f%%\n\n', final_relax_rate * 100);

fprintf('This test will:\n');
fprintf('  1. Run Stage 1 with parallel\n');
fprintf('  2. Restart parallel pool (FIX)\n');
fprintf('  3. Run Stage 2 with parallel\n');
fprintf('  4. Complete without "too many arguments" error\n\n');

fprintf('Starting test...\n');
fprintf('========================================\n\n');

try
    tic;
    [pop_final, pop_stage2, fes, runtime] = PAR_MTDMS_CMOEA(...
        N, iter_max, K, use_parallel, final_relax_rate);
    total_time = toc;
    
    fprintf('\n========================================\n');
    fprintf('SUCCESS! Fix Verified!\n');
    fprintf('========================================\n');
    fprintf('Total time: %.2f seconds\n', total_time);
    fprintf('FES: %d\n', fes);
    fprintf('Solutions: %d\n', size(pop_final, 1));
    
    % Check if we got through Stage 2
    if ~isempty(pop_stage2)
        fprintf('\nStage 2 completed successfully!\n');
        fprintf('The parallel pool restart fix is working.\n');
    end
    
catch ME
    fprintf('\n========================================\n');
    fprintf('FAILED! Error occurred:\n');
    fprintf('========================================\n');
    fprintf('Message: %s\n', ME.message);
    fprintf('\nStack:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
    
    if contains(ME.message, '输入参数太多') || contains(ME.message, 'Too many')
        fprintf('\nThe cache issue still exists.\n');
        fprintf('Try Solution 2 (pctRunOnAll) instead.\n');
    end
end

fprintf('\n========================================\n');
fprintf('Test Complete\n');
fprintf('========================================\n');
