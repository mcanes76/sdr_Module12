function main_problem_2_1()
%MAIN_PROBLEM_2_1 Run Module 12 Problem 2.1 noise estimation workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
utilities_dir = fullfile(repo_root, 'utilities');
data_path = fullfile(repo_root, 'data', 'hw12_test_data.mat');
results_path = fullfile(script_dir, 'problem_2_1_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_1.md');

addpath(utilities_dir);

dataset = load(data_path, ...
    'example_channel_samples', ...
    'example_channel_noise_power', ...
    'example_channel_state_sequence', ...
    'channelized_samples');

samples_per_timeslot = 10;
mdl_observation_length = samples_per_timeslot;

[example_noise_estimate, example_mdl] = EstimateNoiseMDL(dataset.example_channel_samples, mdl_observation_length);
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
write_problem_2_1_report(report_path, results);

fprintf('Problem 2.1 results saved to %s\n', results_path);
fprintf('Problem 2.1 report saved to %s\n', report_path);
fprintf('Example channel MDL estimate: %.12g\n', results.example_channel.noise_variance_estimate);
fprintf('Example channel ground truth: %.12g\n', results.example_channel.noise_variance_truth);
fprintf('Example channel relative error: %.4f%%\n', 100 * results.example_channel.relative_error);
fprintf('Passes 5%% requirement: %s\n', string(results.example_channel.pass_5_percent));

end

function write_problem_2_1_report(report_path, results)
channel_lines = strings(numel(results.channels), 1);
for channel_idx = 1:numel(results.channels)
    channel_lines(channel_idx) = sprintf('| %d | %.12g |', ...
        channel_idx, results.channels(channel_idx).noise_variance_estimate);
end

pass_text = 'No';
if results.example_channel.pass_5_percent
    pass_text = 'Yes';
end

report_lines = [
    "# Problem 2.1 Noise Estimation"
    ""
    "## Objective"
    "Estimate the noise variance in the provided captures using the MDL eigenvalue noise estimator from lecture and the Wireless Coexistence paper. The example channel is validated against the provided ground-truth noise power, and the same estimator is then applied to the six unknown channels."
    ""
    "## MDL Estimator Summary"
    sprintf(['The estimator reshapes the capture into %d-sample observations, forms a sample covariance matrix, computes and sorts the covariance eigenvalues, and uses the MDL criterion to choose the signal-subspace dimension. ', ...
        'The noise variance estimate is the mean of the trailing eigenvalues beyond the selected signal subspace.'], ...
        results.metadata.mdl_observation_length)
    ""
    "## Example Channel Validation"
    sprintf('- Estimated noise variance: `%.12g`', results.example_channel.noise_variance_estimate)
    sprintf('- Ground-truth noise variance: `%.12g`', results.example_channel.noise_variance_truth)
    sprintf('- Relative error: `|estimate - truth| / |truth| = %.8f` (%.4f%%)', ...
        results.example_channel.relative_error, 100 * results.example_channel.relative_error)
    sprintf('- Meets 5%% requirement: `%s`', pass_text)
    ""
    "## Six Unknown Channel Noise Estimates"
    "| Channel | Estimated Noise Variance |"
    "| --- | ---: |"
    channel_lines
    ""
    "## Downstream Data"
    sprintf('Timeslot energies were computed with `samples_per_timeslot = %d` for the example channel and each of the six unknown channels, then saved into `problem_2_1_results.mat` for later problems. These energies were not used as the Problem 2.1 noise estimator.', ...
        results.metadata.samples_per_timeslot)
    ""
];

fid = fopen(report_path, 'w');
cleanup_obj = onCleanup(@() fclose(fid));

for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
end
