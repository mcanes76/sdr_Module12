function main_problem_2_2()
%MAIN_PROBLEM_2_2 Run Module 12 Problem 2.2 threshold calculation workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
utilities_dir = fullfile(repo_root, 'utilities');
problem_2_1_results_path = fullfile(repo_root, 'Problem_2_1_NoiseEstimation', 'problem_2_1_results.mat');
data_path = fullfile(repo_root, 'data', 'hw12_test_data.mat');
results_path = fullfile(script_dir, 'problem_2_2_results.mat');

addpath(utilities_dir);

% load the saved noise estimates from Problem 2.1 so we do not recompute anything here
problem_2_1_data = load(problem_2_1_results_path, 'results');
problem_2_1_results = problem_2_1_data.results;

% only grab the example threshold truth from the homework dataset
dataset = load(data_path, 'example_cfa_threshold');

samples_per_timeslot = 10;
measurement_length = 10;
target_pfa = 0.05;

% the detector uses summed timeslot energy over one 10-sample slot
example_noise_variance_estimate = problem_2_1_results.example_channel.noise_variance_estimate;
[example_threshold_estimate, example_threshold_info] = compute_energy_threshold( ...
    example_noise_variance_estimate, measurement_length, target_pfa);

% check what false alarm probability this threshold gives back under the same model
example_achieved_pfa = example_threshold_info.achieved_pfa;
example_relative_error = abs(example_threshold_estimate - dataset.example_cfa_threshold) / ...
    abs(dataset.example_cfa_threshold);
example_pass_pfa_requirement = example_achieved_pfa >= 0.049 && example_achieved_pfa <= 0.051;

num_channels = numel(problem_2_1_results.channels);
channel_results = repmat(struct( ...
    'threshold_estimate', [], ...
    'noise_variance_estimate', []), num_channels, 1);

for channel_idx = 1:num_channels
    % each channel gets its own threshold because the noise estimate changes
    channel_noise_variance_estimate = problem_2_1_results.channels(channel_idx).noise_variance_estimate;
    channel_threshold_estimate = compute_energy_threshold( ...
        channel_noise_variance_estimate, measurement_length, target_pfa);

    channel_results(channel_idx).threshold_estimate = channel_threshold_estimate;
    channel_results(channel_idx).noise_variance_estimate = channel_noise_variance_estimate;
end

results = struct();
results.example_channel = struct( ...
    'threshold_estimate', example_threshold_estimate, ...
    'threshold_truth', dataset.example_cfa_threshold, ...
    'relative_error', example_relative_error, ...
    'noise_variance_estimate', example_noise_variance_estimate, ...
    'achieved_pfa', example_achieved_pfa, ...
    'pass_pfa_requirement', example_pass_pfa_requirement);
results.channels = channel_results;
results.metadata = struct( ...
    'samples_per_timeslot', samples_per_timeslot, ...
    'measurement_length', measurement_length, ...
    'target_pfa', target_pfa, ...
    'threshold_formula', 'gaminv(1-target_pfa,N,sigma2_hat)', ...
    'statistic_definition', 'summed_timeslot_energy', ...
    'noise_variance_convention', 'per_complex_sample_variance', ...
    'distribution_model', 'gamma_equivalent_to_scaled_chi_square');

save(results_path, 'results');

fprintf('Problem 2.2 results saved to %s\n', results_path);
fprintf('Example channel threshold estimate: %.12g\n', results.example_channel.threshold_estimate);
fprintf('Example channel threshold truth: %.12g\n', results.example_channel.threshold_truth);
fprintf('Example channel threshold relative error: %.4f%%\n', 100 * results.example_channel.relative_error);
fprintf('Example channel achieved Pfa: %.6f\n', results.example_channel.achieved_pfa);
fprintf('Passes Pfa requirement [0.049, 0.051]: %s\n', string(results.example_channel.pass_pfa_requirement));

end
