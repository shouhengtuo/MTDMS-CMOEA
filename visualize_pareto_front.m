function visualize_pareto_front(pop)
% VISUALIZE_PARETO_FRONT - Visualize tri-objective Pareto front
%
% Input:
%   pop - Population matrix [decision_vars, latency, energy, risk, CV]
%
% Generates:
%   - 3D Pareto front visualization
%   - 2D projections (Latency-Energy, Latency-Risk, Energy-Risk)
%   - Objective distribution histograms

% Extract objectives
D = size(pop, 2) - 4;
latencies = pop(:, D+1);
energies = pop(:, D+2);
risks = pop(:, D+3);
CVs = pop(:, D+4);

% Filter feasible solutions
feasible_mask = (CVs == 0);
if sum(feasible_mask) > 0
    % Extract feasible solutions
    feasible_pop = pop(feasible_mask, :);
    feasible_objs = [latencies(feasible_mask), energies(feasible_mask), risks(feasible_mask)];
    
    % Perform non-dominated sorting to get true Pareto front
    [fronts, ~] = nonDominatedSorting(feasible_objs);
    
    % Extract first front (non-dominated solutions)
    pareto_indices = fronts{1};
    lat_vis = feasible_objs(pareto_indices, 1);
    eng_vis = feasible_objs(pareto_indices, 2);
    risk_vis = feasible_objs(pareto_indices, 3);
    
    fprintf('Total feasible solutions: %d\n', size(feasible_objs, 1));
    fprintf('Non-dominated solutions (Pareto front): %d\n', length(pareto_indices));
else
    % No feasible solutions, use all solutions
    all_objs = [latencies, energies, risks];
    [fronts, ~] = nonDominatedSorting(all_objs);
    pareto_indices = fronts{1};
    lat_vis = latencies(pareto_indices);
    eng_vis = energies(pareto_indices);
    risk_vis = risks(pareto_indices);
    
    fprintf('Warning: No feasible solutions found\n');
    fprintf('Non-dominated solutions from all population: %d\n', length(pareto_indices));
end

%% Figure 1: 3D Pareto Front
figure('Position', [100, 100, 800, 600]);
scatter3(lat_vis, eng_vis, risk_vis, 80, risk_vis, 'filled', 'MarkerEdgeColor', 'k');
xlabel('Latency (ms)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Energy (J)', 'FontSize', 12, 'FontWeight', 'bold');
zlabel('Security Risk (normalized)', 'FontSize', 12, 'FontWeight', 'bold');
title('Tri-Objective Pareto Front', 'FontSize', 14, 'FontWeight', 'bold');
colorbar('Label', 'Security Risk');
colormap('jet');
grid on;
view(45, 30);
set(gca, 'FontSize', 11);

% Save figure
saveas(gcf, 'Pareto_Front_3D.fig');
saveas(gcf, 'Pareto_Front_3D.png');

%% Figure 2: 2D Projections
figure('Position', [150, 150, 1200, 400]);

% Latency vs Energy
subplot(1, 3, 1);
scatter(lat_vis, eng_vis, 80, 'b', 'filled', 'MarkerEdgeColor', 'k');
xlabel('Latency (ms)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Energy (J)', 'FontSize', 11, 'FontWeight', 'bold');
title('Latency vs Energy', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10);

% Latency vs Risk
subplot(1, 3, 2);
scatter(lat_vis, risk_vis, 80, 'r', 'filled', 'MarkerEdgeColor', 'k');
xlabel('Latency (ms)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Security Risk', 'FontSize', 11, 'FontWeight', 'bold');
title('Latency vs Security Risk', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10);

% Energy vs Risk
subplot(1, 3, 3);
scatter(eng_vis, risk_vis, 80, 'g', 'filled', 'MarkerEdgeColor', 'k');
xlabel('Energy (J)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Security Risk', 'FontSize', 11, 'FontWeight', 'bold');
title('Energy vs Security Risk', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10);

% Save figure
saveas(gcf, 'Pareto_Front_2D_Projections.fig');
saveas(gcf, 'Pareto_Front_2D_Projections.png');

%% Figure 3: Objective Distributions
figure('Position', [200, 200, 1200, 400]);

% Latency distribution
subplot(1, 3, 1);
histogram(lat_vis, 15, 'FaceColor', 'b', 'EdgeColor', 'k');
xlabel('Latency (ms)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Frequency', 'FontSize', 11, 'FontWeight', 'bold');
title(sprintf('Latency Distribution\nMean: %.3f, Std: %.3f', ...
    mean(lat_vis), std(lat_vis)), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10);

% Energy distribution
subplot(1, 3, 2);
histogram(eng_vis, 15, 'FaceColor', 'r', 'EdgeColor', 'k');
xlabel('Energy (J)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Frequency', 'FontSize', 11, 'FontWeight', 'bold');
title(sprintf('Energy Distribution\nMean: %.3f, Std: %.3f', ...
    mean(eng_vis), std(eng_vis)), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10);

% Risk distribution
subplot(1, 3, 3);
histogram(risk_vis, 15, 'FaceColor', 'g', 'EdgeColor', 'k');
xlabel('Security Risk', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Frequency', 'FontSize', 11, 'FontWeight', 'bold');
title(sprintf('Risk Distribution\nMean: %.3f, Std: %.3f', ...
    mean(risk_vis), std(risk_vis)), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10);

% Save figure
saveas(gcf, 'Objective_Distributions.fig');
saveas(gcf, 'Objective_Distributions.png');

fprintf('Figures saved successfully.\n');

end
