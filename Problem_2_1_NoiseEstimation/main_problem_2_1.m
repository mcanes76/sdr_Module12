function main_problem_2_1()
%MAIN_PROBLEM_2_1 Run Module 12 Problem 2.1 noise estimation workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
utilities_dir = fullfile(repo_root, 'utilities');
data_path = fullfile(repo_root, 'data', 'hw12_test_data.mat');
results_path = fullfile(script_dir, 'problem_2_1_results.mat');

addpath(utilities_dir);

dataset = load(data_path, ...
    'example_channel_samples', ...
    'example_channel_noise_power', ...
    'example_channel_state_sequence', ...
    'channelized_samples');

samples_per_timeslot = 10;
mdl_observation_length = samples_per_timeslot;

% Reuse the Module 11 MDL estimator after chopping the capture into
% short observation vectors that match this dataset's timeslot size.
[example_noise_estimate, example_mdl] = EstimateNoiseMDL(dataset.example_channel_samples, mdl_observation_length);

% Keep the per-timeslot energies around for later problems, but do not use
% them as the noise estimator in Problem 2.1.
example_timeslot_matrix = reshape_timeslots(dataset.example_channel_samples, samples_per_timeslot);
example_timeslot_energy = compute_timeslot_energy(example_timeslot_matrix).';
example_relative_error = abs(example_noise_estimate - dataset.example_channel_noise_power) / ...
    abs(dataset.example_channel_noise_power);
example_pass = example_relative_error <= 0.05;

num_channels = size(dataset.channelized_samples, 2);
channel_results = repmat(struct( ...
    'noise_variance_estimate', [], ...
    'mdl', [], ...
    'timeslot_energy', []), num_channels, 1);

for channel_idx = 1:num_channels
    channel_samples = dataset.channelized_samples(:, channel_idx);

    % The MDL step comes from the covariance eigenvalues of each channel's
    % observation matrix, just like the estimator we built in Module 11.
    [channel_noise_estimate, channel_mdl] = EstimateNoiseMDL(channel_samples, mdl_observation_length);
    channel_timeslot_matrix = reshape_timeslots(channel_samples, samples_per_timeslot);
    channel_timeslot_energy = compute_timeslot_energy(channel_timeslot_matrix).';

    channel_results(channel_idx).noise_variance_estimate = channel_noise_estimate;
    channel_results(channel_idx).mdl = channel_mdl;
    channel_results(channel_idx).timeslot_energy = channel_timeslot_energy;
end

results = struct();
results.example_channel = struct( ...
    'noise_variance_estimate', example_noise_estimate, ...
    'noise_variance_truth', dataset.example_channel_noise_power, ...
    'relative_error', example_relative_error, ...
    'pass_5_percent', example_pass, ...
    'mdl', example_mdl, ...
    'timeslot_energy', example_timeslot_energy);
results.channels = channel_results;
results.metadata = struct( ...
    'samples_per_timeslot', samples_per_timeslot, ...
    'mdl_observation_length', mdl_observation_length);

save(results_path, 'results');

fprintf('Problem 2.1 results saved to %s\n', results_path);
fprintf('Example channel MDL estimate: %.12g\n', results.example_channel.noise_variance_estimate);
fprintf('Example channel ground truth: %.12g\n', results.example_channel.noise_variance_truth);
fprintf('Example channel relative error: %.4f%%\n', 100 * results.example_channel.relative_error);
fprintf('Passes 5%% requirement: %s\n', string(results.example_channel.pass_5_percent));

end
