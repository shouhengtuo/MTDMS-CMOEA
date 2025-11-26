%% PAR-MTDMS-CMOEA: Main Entry Point
% Parallel Multi-Task Dynamic Membrane System with Constrained Multi-Objective 
% Evolutionary Algorithm for IoT Edge Computing Task Offloading
%
% This script demonstrates the usage of PAR-MTDMS-CMOEA algorithm for 
% tri-objective optimization of latency, energy, and security.
%
% Paper: MTDMS-CMOEA: A Multi-Task Dynamic Membrane Computing Framework for
%        Tri-Objective Optimization of Latency, Energy, and Security in 
%        IoT Edge Offloading
% Author: Shouheng Tuo
% Journal: Expert Systems With Applications (Under Review)
% Date: 2025-01

clc;
clear;
close all;

% Clear function cache to ensure latest version is used
clear functions;
rehash path;

fprintf('========================================\n');
fprintf('PAR-MTDMS-CMOEA Algorithm\n');
fprintf('Tri-Objective Optimization for IoT Edge Offloading\n');
fprintf('========================================\n\n');

%% Configuration Parameters
config = struct();

% Algorithm parameters
config.population_size = 200;        % Population size (N)
config.max_iterations = 1000;        % Maximum iterations
config.device_count = 50;            % Number of IoT devices (K)
config.use_parallel = true;          % Enable parallel computing

% Stage allocation ratios (must sum to 1.0)
config.stage1_ratio = 0.3;           % Stage 1: Exploration (50%)
config.stage2_ratio = 0.5;           % Stage 2: Convergence (30%)
config.stage3_ratio = 0.2;           % Stage 3: Security (20%)

% Constraint relaxation parameter (NEW)
config.final_relaxation_rate = 0.05; % Final threshold as % of initial (5% recommended)
                                      % Higher values (e.g., 0.10) = more relaxed
                                      % Lower values (e.g., 0.01) = stricter

% Display configuration
fprintf('Algorithm Configuration:\n');
fprintf('  Population size (N): %d\n', config.population_size);
fprintf('  Max iterations: %d\n', config.max_iterations);
fprintf('  Device count (K): %d\n', config.device_count);
fprintf('  Parallel computing: %s\n', string(config.use_parallel));
fprintf('  Stage allocation: [%.1f : %.1f : %.1f]\n', ...
    config.stage1_ratio, config.stage2_ratio, config.stage3_ratio);
fprintf('  Final constraint relaxation: %.1f%% of initial threshold\n', ...
    config.final_relaxation_rate * 100);
fprintf('\n');

%% Run Algorithm
fprintf('========================================\n');
fprintf('Starting Optimization...\n');
fprintf('========================================\n\n');

tic;
[pop_final, pop_stage2, fes, runtime] = PAR_MTDMS_CMOEA(...
    config.population_size, ...
    config.max_iterations, ...
    config.device_count, ...
    config.use_parallel, ...
    config.final_relaxation_rate);  % Pass relaxation parameter
total_time = toc;

fprintf('\n========================================\n');
fprintf('Optimization Completed!\n');
fprintf('========================================\n\n');

%% Display Results
fprintf('Results Summary:\n');
fprintf('  Total runtime: %.2f seconds\n', total_time);
fprintf('  Function evaluations: %d\n', fes);
fprintf('  Pareto front size (non-dominated): %d solutions\n', size(pop_final, 1));

% Extract objectives
D = size(pop_final, 2) - 4;  % Decision variables dimension
latencies = pop_final(:, D+1);
energies = pop_final(:, D+2);
risks = pop_final(:, D+3);
CVs = pop_final(:, D+4);

% Calculate statistics (all solutions in pop_final are non-dominated)
fprintf('\nObjective Statistics (Non-Dominated Solutions):\n');
fprintf('  Latency (ms):\n');
fprintf('    Min: %.4f, Max: %.4f, Mean: %.4f\n', ...
    min(latencies), max(latencies), mean(latencies));
fprintf('  Energy (J):\n');
fprintf('    Min: %.4f, Max: %.4f, Mean: %.4f\n', ...
    min(energies), max(energies), mean(energies));
fprintf('  Security Risk (normalized):\n');
fprintf('    Min: %.4f, Max: %.4f, Mean: %.4f\n', ...
    min(risks), max(risks), mean(risks));
fprintf('  Feasible solutions: %d/%d (%.1f%%)\n', ...
    sum(CVs==0), length(CVs), (sum(CVs==0)/length(CVs))*100);

%% Visualize Pareto Front
fprintf('\n========================================\n');
fprintf('Generating Visualizations...\n');
fprintf('========================================\n\n');

visualize_pareto_front(pop_final);

fprintf('Visualization completed.\n');
fprintf('Figures saved in current directory.\n\n');

%% Save Results
result_filename = sprintf('PAR_MTDMS_CMOEA_Results_K%d_%s.mat', ...
    config.device_count, datestr(now, 'yyyymmdd_HHMMSS'));

save(result_filename, 'pop_final', 'pop_stage2', 'config', 'fes', 'runtime');

fprintf('Results saved to: %s\n', result_filename);

fprintf('\n========================================\n');
fprintf('Execution Complete!\n');
fprintf('========================================\n');

%% Additional Information
fprintf('\nFor more information:\n');
fprintf('  - Algorithm details: See README.md\n');
fprintf('  - Code structure: See file organization in README.md\n');
fprintf('  - Citation: See README.md for BibTeX entry\n\n');
