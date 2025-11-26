%% Installation Verification Script
% This script verifies that PAR-MTDMS-CMOEA is correctly installed
%
% Run this script after installation to ensure all components are working
%
% Author: Shouheng Tuo
% Date: 2025-01

clc;
clear;
close all;

fprintf('========================================\n');
fprintf('PAR-MTDMS-CMOEA Installation Verification\n');
fprintf('========================================\n\n');

%% Step 1: Check MATLAB Version
fprintf('Step 1: Checking MATLAB version...\n');
matlab_version = version;
fprintf('  MATLAB version: %s\n', matlab_version);

% Extract year
version_year = str2double(matlab_version(end-4:end-2));
if version_year >= 2020
    fprintf('  ✓ MATLAB version OK (R2020a or higher required)\n\n');
else
    fprintf('  ✗ WARNING: MATLAB R2020a or higher recommended\n\n');
end

%% Step 2: Check Core Functions
fprintf('Step 2: Checking core functions...\n');

core_functions = {
    'PAR_MTDMS_CMOEA', ...
    'visualize_pareto_front', ...
    'PAR_stage1', ...
    'PAR_stage2', ...
    'PAR_stage3', ...
    'init_pop', ...
    'nonDominatedSorting', ...
    'get_objective', ...
    'get_safe_f_CV'
};

all_found = true;
for i = 1:length(core_functions)
    func_name = core_functions{i};
    func_path = which(func_name);
    
    if ~isempty(func_path)
        fprintf('  ✓ %s found\n', func_name);
    else
        fprintf('  ✗ %s NOT FOUND\n', func_name);
        all_found = false;
    end
end

if all_found
    fprintf('  ✓ All core functions found\n\n');
else
    fprintf('  ✗ Some functions missing. Check installation.\n\n');
    return;
end

%% Step 3: Check Data Files
fprintf('Step 3: Checking data files...\n');

data_files = {
    'data_10.mat', ...
    'dataOffT.mat', ...
    'dataOfftasks.mat'
};

all_data_found = true;
for i = 1:length(data_files)
    file_name = data_files{i};
    
    % Try to find in current directory or data subdirectory
    if exist(file_name, 'file') == 2
        fprintf('  ✓ %s found\n', file_name);
    elseif exist(fullfile('data', file_name), 'file') == 2
        fprintf('  ✓ %s found in data/\n', file_name);
    else
        fprintf('  ✗ %s NOT FOUND\n', file_name);
        all_data_found = false;
    end
end

if all_data_found
    fprintf('  ✓ All data files found\n\n');
else
    fprintf('  ✗ Some data files missing\n');
    fprintf('    Add data directory to path: addpath(''data'');\n\n');
end

%% Step 4: Check Parallel Computing Toolbox
fprintf('Step 4: Checking Parallel Computing Toolbox...\n');

if license('test', 'Distrib_Computing_Toolbox')
    fprintf('  ✓ Parallel Computing Toolbox available\n');
    
    % Try to get parallel pool
    try
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            fprintf('  ℹ Parallel pool not active (will be created when needed)\n');
        else
            fprintf('  ✓ Parallel pool already active (%d workers)\n', poolobj.NumWorkers);
        end
    catch
        fprintf('  ⚠ Parallel pool test failed (may still work)\n');
    end
else
    fprintf('  ⚠ Parallel Computing Toolbox not available\n');
    fprintf('    Algorithm can still run with use_parallel=false\n');
end
fprintf('\n');

%% Step 5: Quick Functional Test
fprintf('Step 5: Running quick functional test...\n');
fprintf('  Testing with K=10, N=20, iter=50 (very quick)...\n');

try
    % Minimal test
    tic;
    [pop, ~, fes, runtime] = PAR_MTDMS_CMOEA(20, 50, 10, false);
    test_time = toc;
    
    % Check output
    if ~isempty(pop) && size(pop, 1) > 0
        D = 10 * 6 + 120;
        latencies = pop(:, D+1);
        energies = pop(:, D+2);
        risks = pop(:, D+3);
        
        fprintf('  ✓ Algorithm executed successfully\n');
        fprintf('    Pareto front size: %d solutions\n', size(pop, 1));
        fprintf('    Latency range: [%.3f, %.3f] ms\n', min(latencies), max(latencies));
        fprintf('    Energy range: [%.3f, %.3f] J\n', min(energies), max(energies));
        fprintf('    Risk range: [%.3f, %.3f]\n', min(risks), max(risks));
        fprintf('    Test runtime: %.2f seconds\n', test_time);
        fprintf('    FES: %d\n', fes);
    else
        fprintf('  ✗ Algorithm returned empty result\n');
    end
catch ME
    fprintf('  ✗ Algorithm test FAILED\n');
    fprintf('    Error: %s\n', ME.message);
    fprintf('    Check error details above.\n');
end
fprintf('\n');

%% Final Summary
fprintf('========================================\n');
fprintf('Installation Verification Summary\n');
fprintf('========================================\n\n');

if all_found && all_data_found
    fprintf('✓ Installation appears to be complete and functional!\n\n');
    fprintf('Next steps:\n');
    fprintf('  1. Run PAR_MTDMS_CMOEA_Main for a full demonstration\n');
    fprintf('  2. See USER_GUIDE.md for detailed usage instructions\n');
    fprintf('  3. Check Example_Usage.m for various use cases\n\n');
else
    fprintf('⚠ Installation has some issues:\n');
    if ~all_found
        fprintf('  - Some core functions are missing\n');
    end
    if ~all_data_found
        fprintf('  - Some data files are missing\n');
    end
    fprintf('\nRecommended actions:\n');
    fprintf('  1. Ensure all files are extracted properly\n');
    fprintf('  2. Add all subdirectories to MATLAB path:\n');
    fprintf('     addpath(genpath(''Par_MTDMS_CMOEA''));\n');
    fprintf('  3. Verify data files are in data/ subdirectory\n\n');
end

fprintf('========================================\n');
fprintf('Verification Complete\n');
fprintf('========================================\n');
