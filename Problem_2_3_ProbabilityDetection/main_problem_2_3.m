function main_problem_2_3()
%MAIN_PROBLEM_2_3 Run Module 12 Problem 2.3 probability of detection workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
problem_2_1_results_path = fullfile(repo_root, 'Problem_2_1_NoiseEstimation', 'problem_2_1_results.mat');
problem_2_2_results_path = fullfile(repo_root, 'Problem_2_2_CFARThreshold', 'problem_2_2_results.mat');
results_path = fullfile(script_dir, 'problem_2_3_results.mat');
plot_path = fullfile(script_dir, 'probability_detection_bar.png');

% reuse the saved noise estimates and thresholds from the earlier problems
problem_2_1_data = load(problem_2_1_results_path, 'results');
problem_2_2_data = load(problem_2_2_results_path, 'results');

problem_2_1_results = problem_2_1_data.results;
problem_2_2_results = problem_2_2_data.results;

K = 10;
signal_power = 1;

% page 133 uses Es as the total signal energy over the whole measurement,
% so with unit average signal power and K samples we use Es = K*signal_power
Es = K * signal_power;

num_channels = numel(problem_2_2_results.channels);
Pd_values = zeros(num_channels, 1);
eta = zeros(num_channels, 1);
sigma_n = zeros(num_channels, 1);

for channel_idx = 1:num_channels
    noise_variance = problem_2_1_results.channels(channel_idx).noise_variance_estimate;
    eta(channel_idx) = problem_2_2_results.channels(channel_idx).threshold_estimate;
    sigma_n(channel_idx) = sqrt(noise_variance);

    % marcumq gives the theoretical detection probability directly for the
    % Kth-order noncoherent energy detector model from the assignment
    a = sqrt(Es) / sigma_n(channel_idx);
    b = sqrt(eta(channel_idx)) / sigma_n(channel_idx);
    Pd_values(channel_idx) = marcumq(a, b, K);
end

% plot every channel so the figure matches the full set of computed results
plot_channel_count = num_channels;
plot_channel_indices = 1:plot_channel_count;

fig = figure('Visible', 'on');
bar(plot_channel_indices, Pd_values(plot_channel_indices));
title('Energy Detector Probability of Detection');
xlabel('Channel');
ylabel('P_D');
xticks(plot_channel_indices);
ylim([0 1]);
grid on;
exportgraphics(fig, plot_path, 'Resolution', 150);
%close(fig);

save(results_path, 'Pd_values', 'eta', 'sigma_n', 'K', 'Es', 'plot_channel_indices');

fprintf('Problem 2.3 results saved to %s\n', results_path);
fprintf('Problem 2.3 plot saved to %s\n', plot_path);
fprintf('Computed P_D for %d channels.\n', num_channels);
fprintf('Channel 1 P_D: %.8f\n', Pd_values(1));
if num_channels >= 2
    fprintf('Channel 2 P_D: %.8f\n', Pd_values(2));
end
if num_channels >= 3
    fprintf('Channel 3 P_D: %.8f\n', Pd_values(3));
end

end
