function [pop_final, pop_stage2, fes, runtime] = PAR_MTDMS_CMOEA(N, iter_max, count, use_parallel, final_relax_rate)
% PAR_MTDMS_CMOEA - Parallel Multi-Task Dynamic Membrane System with
% Constrained Multi-Objective Evolutionary Algorithm
%
% Inputs:
%   N                - Population size
%   iter_max         - Maximum iterations
%   count            - Number of IoT devices
%   use_parallel     - Enable/disable parallel (default: true)
%   final_relax_rate - Final constraint relaxation as % of initial (default: 0.05)
%
% Outputs:
%   pop_final    - Final Pareto front
%   pop_stage2   - Population after Stage 2
%   fes          - Function evaluations
%   runtime      - Total runtime

runtime = 0;

% Diagnostic: Confirm function version
fprintf('PAR_MTDMS_CMOEA v2.0 loaded (with final_relax_rate parameter)\n');

%% Input Validation
if nargin < 4
    use_parallel = true;
end

if nargin < 5
    final_relax_rate = 0.05;  % Default: 5%
end

if final_relax_rate <= 0 || final_relax_rate > 1.0
    warning('final_relax_rate should be in (0, 1]. Using default 0.05');
    final_relax_rate = 0.05;
end

% Stage duration control parameters
delta = 0.3;   % Stage 1 ratio
delta2 = 0.3;  % Stage 2 ratio
delta3 = 0.2;  % Stage 3 ratio

global fes;
fes = 0;

D = count * 6 + 120;

%% Parallel Pool Management
if use_parallel
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        fprintf('Initializing parallel pool with 4 workers...\n');
        parpool('local', 4);
        fprintf('Parallel pool initialized.\n');
    else
        fprintf('Using existing parallel pool with %d workers.\n', poolobj.NumWorkers);
    end
end

%% Stage 1
fprintf('========================================\n');
fprintf('Stage 1: Parallel Membrane Evolution\n');
fprintf('========================================\n');

pop_1 = init_pop(N, D); 
pop_2 = init_pop(N, D); 
pop_3 = init_pop(N, D); 
pop_4 = init_pop(N, D); 

if use_parallel
    fprintf('Running Stage 1 with parallel computing...\n');
    tic;
    
    pops = {pop_1, pop_2, pop_3, pop_4};
    results = cell(1, 4);
    fes_results = zeros(1, 4);
    
    parfor i = 1:4
        fprintf('  Worker %d: Processing membrane type %d...\n', i, i);
        [results{i}, fes_results(i)] = PAR_stage1(pops{i}, delta*iter_max, i, count);
        fprintf('  Worker %d: Membrane type %d completed.\n', i, i);
    end
    
    pop_1 = results{1};
    pop_2 = results{2};
    pop_3 = results{3};
    pop_4 = results{4};
    
    fes = fes + sum(fes_results);
    
    elapsed_time = toc;
    runtime = runtime + elapsed_time;
    fprintf('Stage 1 completed in %.2f seconds (parallel mode)\n', elapsed_time);
else
    fprintf('Running Stage 1 with sequential computing...\n');
    tic;
    
    [pop_1, fes1] = PAR_stage1(pop_1, delta*iter_max, 1, count);
    fes = fes + fes1;
    fprintf('  Membrane 1 completed\n');
    
    [pop_2, fes2] = PAR_stage1(pop_2, delta*iter_max, 2, count);
    fes = fes + fes2;
    fprintf('  Membrane 2 completed\n');
    
    [pop_3, fes3] = PAR_stage1(pop_3, delta*iter_max, 3, count);
    fes = fes + fes3;
    fprintf('  Membrane 3 completed\n');
    
    [pop_4, fes4] = PAR_stage1(pop_4, delta*iter_max, 4, count);
    fes = fes + fes4;
    fprintf('  Membrane 4 completed\n');
    
    elapsed_time = toc;
    runtime = runtime + elapsed_time;
    fprintf('Stage 1 completed in %.2f seconds (sequential mode)\n', elapsed_time);
end

%% Stage 2
fprintf('========================================\n');
fprintf('Stage 2: Constraint-Aware Refinement\n');
fprintf('========================================\n');

% CRITICAL FIX: Restart parallel pool to clear cached functions
% This ensures workers load the latest version of PAR_stage2 with final_relax_rate parameter
if use_parallel
    fprintf('Restarting parallel pool to ensure latest functions are loaded...\n');
    poolobj = gcp('nocreate');
    if ~isempty(poolobj)
        delete(poolobj);
        pause(2);  % Wait for clean shutdown
    end
    parpool('local', 4);
    fprintf('Parallel pool restarted.\n');
end

if use_parallel
    fprintf('Running Stage 2 with parallel computing...\n');
    tic;
    
    pops = {pop_1, pop_2, pop_3, pop_4};
    results = cell(1, 4);
    fes_results = zeros(1, 4);
    
    parfor i = 1:4
        fprintf('  Worker %d: Processing membrane type %d...\n', i, i);
        [results{i}, fes_results(i)] = PAR_stage2(pops{i}, delta2*iter_max, i, count, final_relax_rate);
        fprintf('  Worker %d: Membrane type %d completed.\n', i, i);
    end
    
    pop_1 = results{1};
    pop_2 = results{2};
    pop_3 = results{3};
    pop_4 = results{4};
    
    fes = fes + sum(fes_results);
    
    elapsed_time = toc;
    runtime = runtime + elapsed_time;
    fprintf('Stage 2 completed in %.2f seconds (parallel mode)\n', elapsed_time);
else
    fprintf('Running Stage 2 with sequential computing...\n');
    tic;
    
    [pop_1, fes1] = PAR_stage2(pop_1, delta2*iter_max, 1, count, final_relax_rate);
    fes = fes + fes1;
    fprintf('  Membrane 1 completed\n');
    
    [pop_2, fes2] = PAR_stage2(pop_2, delta2*iter_max, 2, count, final_relax_rate);
    fes = fes + fes2;
    fprintf('  Membrane 2 completed\n');
    
    [pop_3, fes3] = PAR_stage2(pop_3, delta2*iter_max, 3, count, final_relax_rate);
    fes = fes + fes3;
    fprintf('  Membrane 3 completed\n');
    
    [pop_4, fes4] = PAR_stage2(pop_4, delta2*iter_max, 4, count, final_relax_rate);
    fes = fes + fes4;
    fprintf('  Membrane 4 completed\n');
    
    elapsed_time = toc;
    runtime = runtime + elapsed_time;
    fprintf('Stage 2 completed in %.2f seconds (sequential mode)\n', elapsed_time);
end

pop_1 = top(pop_1);
pop_2 = top(pop_2);
pop_3 = top(pop_3);
pop_4 = top(pop_4);

pop = [pop_1; pop_2; pop_3; pop_4];
pop = top(pop);
pop_stage2 = pop;

%% Stage 3
fprintf('========================================\n');
fprintf('Stage 3: Security-Aware Optimization\n');
fprintf('========================================\n');
tic;

num_stage2_solutions = size(pop, 1);
num_security_samples = min(10, num_stage2_solutions);

fprintf('Optimizing security for %d representative solutions...\n', num_security_samples);

indices = round(linspace(1, num_stage2_solutions, num_security_samples));
representatives = pop(indices, :);

all_tri_objectives = [];
all_decision_vars = [];
all_CVs = [];
fes_stage3_total = 0;

for rep_idx = 1:num_security_samples
    current_sol = representatives(rep_idx, :);
    
    T_stage2_latency = current_sol(D+1);
    T_stage2_energy = current_sol(D+2);
    stage2_CV = current_sol(D+3);
    decision_vars_stage2 = current_sol(1:D);
    
    L = creatsafemodel(current_sol);
    iter_per_rep = round(delta3*iter_max / num_security_samples);
    [pop_sec, fes_sec] = PAR_stage3(L, iter_per_rep);
    fes_stage3_total = fes_stage3_total + fes_sec;
    
    security_costs = pop_sec(:, end-2);
    security_risks = pop_sec(:, end-1);
    sec_CVs = pop_sec(:, end);
    
    num_sec_solutions = size(pop_sec, 1);
    latencies = repmat(T_stage2_latency, num_sec_solutions, 1) + security_costs;
    energies = repmat(T_stage2_energy, num_sec_solutions, 1);
    risks = security_risks;
    decision_vars = repmat(decision_vars_stage2, num_sec_solutions, 1);
    
    combined_CVs = repmat(stage2_CV, num_sec_solutions, 1) + sec_CVs;
    
    all_tri_objectives = [all_tri_objectives; latencies, energies, risks];
    all_decision_vars = [all_decision_vars; decision_vars];
    all_CVs = [all_CVs; combined_CVs];
end

pop_all = [all_decision_vars, all_tri_objectives, all_CVs];
fes = fes + fes_stage3_total;

fprintf('Total solutions: %d\n', size(pop_all, 1));

feasible_mask = (all_CVs == 0);
if sum(feasible_mask) > 0
    pop_feasible = pop_all(feasible_mask, :);
    fprintf('Feasible solutions: %d\n', size(pop_feasible, 1));
    
    objectives_feasible = pop_feasible(:, (D+1):(D+3));
    [fronts, ~] = nonDominatedSorting(objectives_feasible);
    
    first_front_indices = fronts{1};
    pop_final = pop_feasible(first_front_indices, :);
    
    fprintf('Non-dominated solutions (Pareto front): %d\n', length(first_front_indices));
else
    fprintf('Warning: No feasible solutions found, using all solutions\n');
    objectives_all = pop_all(:, (D+1):(D+3));
    [fronts, ~] = nonDominatedSorting(objectives_all);
    first_front_indices = fronts{1};
    pop_final = pop_all(first_front_indices, :);
    fprintf('Non-dominated solutions: %d\n', length(first_front_indices));
end

elapsed_time = toc;
runtime = runtime + elapsed_time;
fprintf('Stage 3 completed in %.2f seconds\n', elapsed_time);
fprintf('Final Pareto front size: %d solutions\n', size(pop_final, 1));

fprintf('========================================\n');
fprintf('Algorithm completed. Total FES: %d\n', fes);
fprintf('Total runtime: %.2f seconds\n', runtime);
fprintf('========================================\n');

end
