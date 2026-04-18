function main_problem_2_7()
%MAIN_PROBLEM_2_7 Run Module 12 Extra Credit Problem 2.7 workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
problem_2_4_results_path = fullfile(repo_root, 'Problem_2_4_EnergyDetection', 'problem_2_4_results.mat');
problem_2_5_results_path = fullfile(repo_root, 'Problem_2_5_HMM', 'problem_2_5_results.mat');
problem_2_6_results_path = fullfile(repo_root, 'Problem_2_6_IdlePrediction', 'problem_2_6_results.mat');
results_path = fullfile(script_dir, 'problem_2_7_results.mat');

problem_2_4_data = load(problem_2_4_results_path, 'results');
problem_2_5_data = load(problem_2_5_results_path, 'results');
problem_2_6_data = load(problem_2_6_results_path, 'results');

problem_2_4_results = problem_2_4_data.results;
problem_2_5_results = problem_2_5_data.results;
problem_2_6_results = problem_2_6_data.results;

window_length = 4;

example_decisions = problem_2_4_results.example_channel.decisions;
example_transition_matrix = problem_2_5_results.example_channel.transition_matrix;
example_limiting_distribution = problem_2_6_results.example_channel.limiting_distribution;

example_observed_probability_4_idle = compute_observed_probability(example_decisions, window_length);

% This is a Markov-chain probability, not an IID one, so use pi_idle*P11^3
% instead of (pi_idle)^4 under the state-1 = idle convention.
example_pi_idle = example_limiting_distribution(1);
example_P11 = example_transition_matrix(1, 1);
example_predicted_probability_4_idle = example_pi_idle * example_P11^(window_length - 1);
example_difference = example_observed_probability_4_idle - example_predicted_probability_4_idle;

num_channels = numel(problem_2_4_results.channels);
channel_results = repmat(struct( ...
    'observed_probability_4_idle', [], ...
    'predicted_probability_4_idle', [], ...
    'difference', []), num_channels, 1);

for channel_idx = 1:num_channels
    decisions = problem_2_4_results.channels(channel_idx).decisions;
    transition_matrix = problem_2_5_results.channels(channel_idx).transition_matrix;
    limiting_distribution = problem_2_6_results.channels(channel_idx).limiting_distribution;

    observed_probability_4_idle = compute_observed_probability(decisions, window_length);

    % The first slot is idle with probability pi_idle, then the next
    % three slots stay idle through repeated P11 transitions.
    pi_idle = limiting_distribution(1);
    P11 = transition_matrix(1, 1);
    predicted_probability_4_idle = pi_idle * P11^(window_length - 1);

    channel_results(channel_idx).observed_probability_4_idle = observed_probability_4_idle;
    channel_results(channel_idx).predicted_probability_4_idle = predicted_probability_4_idle;
    channel_results(channel_idx).difference = observed_probability_4_idle - predicted_probability_4_idle;
end

results = struct();
results.example_channel = struct( ...
    'observed_probability_4_idle', example_observed_probability_4_idle, ...
    'predicted_probability_4_idle', example_predicted_probability_4_idle, ...
    'difference', example_difference);
results.channels = channel_results;
results.metadata = struct( ...
    'window_length', window_length, ...
    'event_definition', 'all_idle_sliding_window_of_length_4', ...
    'prediction_method', 'steady_state_markov_probability_pi_idle_times_P11_power_3', ...
    'state_definition', 'S1_idle_S2_occupied');

save(results_path, 'results');

fprintf('Problem 2.7 results saved to %s\n', results_path);
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

function observed_probability_4_idle = compute_observed_probability(decisions, window_length)
% Use every overlapping window of length 4, not disjoint runs.
% Keeping the vector as a row makes the conv output shape predictable.
idle_flags = double(decisions(:).' == 0);
window_idle_counts = conv(idle_flags, ones(1, window_length), 'valid');
observed_probability_4_idle = mean(window_idle_counts == window_length);
end
