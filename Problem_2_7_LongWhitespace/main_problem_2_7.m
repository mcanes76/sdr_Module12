function main_problem_2_7()
%MAIN_PROBLEM_2_7 Run Module 12 Extra Credit Problem 2.7 workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
utilities_dir = fullfile(repo_root, 'utilities');
problem_2_4_results_path = fullfile(repo_root, 'Problem_2_4_EnergyDetection', 'problem_2_4_results.mat');
problem_2_5_results_path = fullfile(repo_root, 'Problem_2_5_HMM', 'problem_2_5_results.mat');
problem_2_6_results_path = fullfile(repo_root, 'Problem_2_6_IdlePrediction', 'problem_2_6_results.mat');
results_path = fullfile(script_dir, 'problem_2_7_results.mat');
example_plot_path = fullfile(script_dir, 'example_idle_run_probability_curve.png');
predicted_plot_path = fullfile(script_dir, 'predicted_idle_run_probability_by_channel.png');

addpath(utilities_dir);

problem_2_4_data = load(problem_2_4_results_path, 'results');
problem_2_5_data = load(problem_2_5_results_path, 'results');
problem_2_6_data = load(problem_2_6_results_path, 'results');

problem_2_4_results = problem_2_4_data.results;
problem_2_5_results = problem_2_5_data.results;
problem_2_6_results = problem_2_6_data.results;

window_length = 4;
k_values = 1:10;
curve_max_k = max(k_values);

example_decisions = problem_2_4_results.example_channel.decisions;
example_transition_matrix = problem_2_5_results.example_channel.transition_matrix;
example_limiting_distribution = problem_2_6_results.example_channel.limiting_distribution;

example_pi_idle = example_limiting_distribution(1);
example_P11 = example_transition_matrix(1, 1);
example_observed_probability_curve = compute_idle_run_probability_curve( ...
    example_decisions, k_values, 'observed');
example_predicted_probability_curve = compute_idle_run_probability_curve( ...
    example_pi_idle, k_values, 'markov', example_P11);

example_observed_probability_4_idle = example_observed_probability_curve(k_values == window_length);

% This is a Markov-chain probability, not an IID one, so use pi_idle*P11^3
% instead of (pi_idle)^4 under the state-1 = idle convention.
example_predicted_probability_4_idle = example_pi_idle * example_P11^(window_length - 1);
example_difference = example_observed_probability_4_idle - example_predicted_probability_4_idle;

num_channels = numel(problem_2_4_results.channels);
channel_results = repmat(struct( ...
    'observed_probability_4_idle', [], ...
    'predicted_probability_4_idle', [], ...
    'difference', [], ...
    'k_values', [], ...
    'observed_probability_curve', [], ...
    'predicted_probability_curve', []), num_channels, 1);

all_predicted_curves = zeros(num_channels, numel(k_values));

for channel_idx = 1:num_channels
    decisions = problem_2_4_results.channels(channel_idx).decisions;
    transition_matrix = problem_2_5_results.channels(channel_idx).transition_matrix;
    limiting_distribution = problem_2_6_results.channels(channel_idx).limiting_distribution;

    % The first slot is idle with probability pi_idle, then the next
    % three slots stay idle through repeated P11 transitions.
    pi_idle = limiting_distribution(1);
    P11 = transition_matrix(1, 1);
    observed_probability_curve = compute_idle_run_probability_curve( ...
        decisions, k_values, 'observed');
    predicted_probability_curve = compute_idle_run_probability_curve( ...
        pi_idle, k_values, 'markov', P11);
    observed_probability_4_idle = observed_probability_curve(k_values == window_length);
    predicted_probability_4_idle = pi_idle * P11^(window_length - 1);

    channel_results(channel_idx).observed_probability_4_idle = observed_probability_4_idle;
    channel_results(channel_idx).predicted_probability_4_idle = predicted_probability_4_idle;
    channel_results(channel_idx).difference = observed_probability_4_idle - predicted_probability_4_idle;
    channel_results(channel_idx).k_values = k_values;
    channel_results(channel_idx).observed_probability_curve = observed_probability_curve;
    channel_results(channel_idx).predicted_probability_curve = predicted_probability_curve;

    all_predicted_curves(channel_idx, :) = predicted_probability_curve;
end

% The Markov curve decays exponentially in k because every extra idle slot
% adds one more factor of P11 after the first idle slot is chosen by pi_idle.
example_fig = figure('Visible', 'off');
plot(k_values, example_observed_probability_curve, 'o-', 'LineWidth', 1.5, 'DisplayName', 'Observed');
hold on;
plot(k_values, example_predicted_probability_curve, 's-', 'LineWidth', 1.5, 'DisplayName', 'Markov Prediction');
grid on;
xlabel('Run length k');
ylabel('Probability of k consecutive idle slots');
title('Example Channel Idle-Run Probability: Observed vs Markov Prediction');
legend('Location', 'northeast');
exportgraphics(example_fig, example_plot_path, 'Resolution', 150);
close(example_fig);

predicted_fig = figure('Visible', 'off');
plot(k_values, all_predicted_curves.', 'LineWidth', 1.5);
grid on;
xlabel('Run length k');
ylabel('Predicted probability of k consecutive idle slots');
title('Predicted Idle-Run Probability by Channel');
legend(compose('Channel %d', 1:num_channels), 'Location', 'northeast');
exportgraphics(predicted_fig, predicted_plot_path, 'Resolution', 150);
close(predicted_fig);

results = struct();
results.example_channel = struct( ...
    'observed_probability_4_idle', example_observed_probability_4_idle, ...
    'predicted_probability_4_idle', example_predicted_probability_4_idle, ...
    'difference', example_difference, ...
    'k_values', k_values, ...
    'observed_probability_curve', example_observed_probability_curve, ...
    'predicted_probability_curve', example_predicted_probability_curve);
results.channels = channel_results;
results.metadata = struct( ...
    'window_length', window_length, ...
    'event_definition', 'all_idle_sliding_window_of_length_4', ...
    'prediction_method', 'steady_state_markov_probability_pi_idle_times_P11_power_3', ...
    'state_definition', 'S1_idle_S2_occupied', ...
    'curve_max_k', curve_max_k, ...
    'curve_formula', 'P(k idle) = pi_idle * P11^(k-1)');

save(results_path, 'results');

fprintf('Problem 2.7 results saved to %s\n', results_path);
fprintf('Problem 2.7 example-curve plot saved to %s\n', example_plot_path);
fprintf('Problem 2.7 all-channel prediction plot saved to %s\n', predicted_plot_path);
fprintf('Example observed P(4 idle): %.8f\n', results.example_channel.observed_probability_4_idle);
fprintf('Example predicted P(4 idle): %.8f\n', results.example_channel.predicted_probability_4_idle);
fprintf('Example difference (observed - predicted): %.8f\n', results.example_channel.difference);

for channel_idx = 1:num_channels
    fprintf('Channel %d observed: %.8f, predicted: %.8f, diff: %.8f\n', ...
        channel_idx, ...
        results.channels(channel_idx).observed_probability_4_idle, ...
        results.channels(channel_idx).predicted_probability_4_idle, ...
        results.channels(channel_idx).difference);
end

end
