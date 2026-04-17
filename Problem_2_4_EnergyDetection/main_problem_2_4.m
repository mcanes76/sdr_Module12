function main_problem_2_4()
%MAIN_PROBLEM_2_4 Run Module 12 Problem 2.4 energy detection workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
utilities_dir = fullfile(repo_root, 'utilities');
problem_2_1_results_path = fullfile(repo_root, 'Problem_2_1_NoiseEstimation', 'problem_2_1_results.mat');
problem_2_2_results_path = fullfile(repo_root, 'Problem_2_2_CFARThreshold', 'problem_2_2_results.mat');
data_path = fullfile(repo_root, 'data', 'hw12_test_data.mat');
results_path = fullfile(script_dir, 'problem_2_4_results.mat');

addpath(utilities_dir);

% load the saved energies and thresholds from the earlier problems
problem_2_1_data = load(problem_2_1_results_path, 'results');
problem_2_2_data = load(problem_2_2_results_path, 'results');
dataset = load(data_path, 'example_channel_state_sequence');

problem_2_1_results = problem_2_1_data.results;
problem_2_2_results = problem_2_2_data.results;

example_timeslot_energy = problem_2_1_results.example_channel.timeslot_energy(:);
example_threshold = problem_2_2_results.example_channel.threshold_estimate;
example_truth_sequence = dataset.example_channel_state_sequence(:);

% apply the same detector rule to every timeslot
example_decisions = run_energy_detector(example_timeslot_energy, example_threshold);

example_percent_occupied = 100 * mean(example_decisions);
example_percent_idle = 100 * mean(~example_decisions);

% The example truth sequence uses two state labels.
% For this dataset we treat the larger label as "occupied" so that
% the detector decisions (1 = occupied, 0 = idle) can be compared
% directly against the truth sequence.
example_truth_occupied = example_truth_sequence == max(example_truth_sequence);
example_percent_agreement = 100 * mean(example_decisions == example_truth_occupied);

true_positives = sum(example_decisions & example_truth_occupied);
true_negatives = sum(~example_decisions & ~example_truth_occupied);
false_alarms = sum(example_decisions & ~example_truth_occupied);
missed_detections = sum(~example_decisions & example_truth_occupied);

num_channels = numel(problem_2_1_results.channels);
channel_results = repmat(struct( ...
    'threshold', [], ...
    'timeslot_energy', [], ...
    'decisions', [], ...
    'percent_occupied', [], ...
    'percent_idle', []), num_channels, 1);

for channel_idx = 1:num_channels
    channel_timeslot_energy = problem_2_1_results.channels(channel_idx).timeslot_energy(:);
    channel_threshold = problem_2_2_results.channels(channel_idx).threshold_estimate;
    channel_decisions = run_energy_detector(channel_timeslot_energy, channel_threshold);

    channel_results(channel_idx).threshold = channel_threshold;
    channel_results(channel_idx).timeslot_energy = channel_timeslot_energy;
    channel_results(channel_idx).decisions = channel_decisions;
    channel_results(channel_idx).percent_occupied = 100 * mean(channel_decisions);
    channel_results(channel_idx).percent_idle = 100 * mean(~channel_decisions);
end

results = struct();
results.example_channel = struct( ...
    'threshold', example_threshold, ...
    'timeslot_energy', example_timeslot_energy, ...
    'decisions', example_decisions, ...
    'truth_sequence', example_truth_sequence, ...
    'percent_occupied', example_percent_occupied, ...
    'percent_idle', example_percent_idle, ...
    'percent_agreement', example_percent_agreement, ...
    'true_positives', true_positives, ...
    'true_negatives', true_negatives, ...
    'false_alarms', false_alarms, ...
    'missed_detections', missed_detections);
results.channels = channel_results;
results.metadata = struct( ...
    'samples_per_timeslot', problem_2_1_results.metadata.samples_per_timeslot, ...
    'measurement_length', problem_2_2_results.metadata.measurement_length, ...
    'detector_statistic', 'summed_timeslot_energy', ...
    'decision_rule', 'occupied_if_timeslot_energy_greater_than_threshold');

save(results_path, 'results');

fprintf('Problem 2.4 results saved to %s\n', results_path);
fprintf('Example channel occupied: %.4f%%\n', results.example_channel.percent_occupied);
fprintf('Example channel idle: %.4f%%\n', results.example_channel.percent_idle);
fprintf('Example channel agreement with truth: %.4f%%\n', results.example_channel.percent_agreement);
fprintf('Example channel TP=%d TN=%d FA=%d MD=%d\n', ...
    results.example_channel.true_positives, ...
    results.example_channel.true_negatives, ...
    results.example_channel.false_alarms, ...
    results.example_channel.missed_detections);

for channel_idx = 1:num_channels
    fprintf('Channel %d occupied: %.4f%%, idle: %.4f%%\n', ...
        channel_idx, ...
        results.channels(channel_idx).percent_occupied, ...
        results.channels(channel_idx).percent_idle);
end

end
