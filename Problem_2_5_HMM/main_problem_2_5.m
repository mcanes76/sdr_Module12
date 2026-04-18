function main_problem_2_5()
%MAIN_PROBLEM_2_5 Run Module 12 Problem 2.5 HMM estimation workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
utilities_dir = fullfile(repo_root, 'utilities');
problem_2_4_results_path = fullfile(repo_root, 'Problem_2_4_EnergyDetection', 'problem_2_4_results.mat');
results_path = fullfile(script_dir, 'problem_2_5_results.mat');

addpath(utilities_dir);

% use the Problem 2.4 detector outputs as the observed HMM sequence
problem_2_4_data = load(problem_2_4_results_path, 'results');
problem_2_4_results = problem_2_4_data.results;

% rows are current state and columns are next state
initial_transition_matrix = [0.5, 0.5; 0.5, 0.5];

% build the first emission guess from the example truth and detector output
initial_emission_matrix = build_initial_emission_matrix( ...
    problem_2_4_results.example_channel.truth_sequence, ...
    problem_2_4_results.example_channel.decisions);

hmmtrain_settings = struct( ...
    'Algorithm', 'BaumWelch', ...
    'Maxiterations', 5000, ...
    'Tolerance', 1e-5);

% MATLAB HMM functions expect symbols starting at 1, so shift 0/1 to 1/2
example_observed_sequence = problem_2_4_results.example_channel.decisions(:).' + 1;
[example_transition_matrix, example_emission_matrix] = estimate_hmm_transition_matrix( ...
    example_observed_sequence, ...
    initial_transition_matrix, ...
    initial_emission_matrix, ...
    hmmtrain_settings);

num_channels = numel(problem_2_4_results.channels);
channel_results = repmat(struct( ...
    'observed_sequence', [], ...
    'transition_matrix', [], ...
    'emission_matrix', []), num_channels, 1);

for channel_idx = 1:num_channels
    % the detector output is not the hidden state, so we still pass it in
    % as an observation sequence and let the HMM infer the transitions
    observed_sequence = problem_2_4_results.channels(channel_idx).decisions(:).' + 1;
    [transition_matrix, emission_matrix] = estimate_hmm_transition_matrix( ...
        observed_sequence, ...
        initial_transition_matrix, ...
        initial_emission_matrix, ...
        hmmtrain_settings);

    channel_results(channel_idx).observed_sequence = observed_sequence;
    channel_results(channel_idx).transition_matrix = transition_matrix;
    channel_results(channel_idx).emission_matrix = emission_matrix;
end

results = struct();
results.example_channel = struct( ...
    'observed_sequence', example_observed_sequence, ...
    'transition_matrix', example_transition_matrix, ...
    'emission_matrix', example_emission_matrix, ...
    'truth_sequence', problem_2_4_results.example_channel.truth_sequence(:).');
results.channels = channel_results;
results.metadata = struct( ...
    'state_definition', 'S1_idle_S2_occupied', ...
    'observation_definition', 'O1_idle_detector_output_O2_occupied_detector_output', ...
    'hmmtrain_settings', hmmtrain_settings, ...
    'transition_matrix_orientation', 'rows_current_state_columns_next_state', ...
    'initial_transition_matrix', initial_transition_matrix, ...
    'initial_emission_matrix', initial_emission_matrix);

save(results_path, 'results');

fprintf('Problem 2.5 results saved to %s\n', results_path);
fprintf('Example channel transition matrix:\n');
disp(results.example_channel.transition_matrix)
fprintf('Example channel emission matrix:\n');
disp(results.example_channel.emission_matrix)

for channel_idx = 1:num_channels
    fprintf('Channel %d transition matrix:\n', channel_idx);
    disp(results.channels(channel_idx).transition_matrix)
end

end

function emission_matrix = build_initial_emission_matrix(truth_sequence, detector_decisions)
% build a simple emission guess from the example channel confusion behavior

truth_sequence = truth_sequence(:);
detector_decisions = detector_decisions(:);

idle_state_label = min(truth_sequence);
occupied_state_label = max(truth_sequence);
truth_states = ones(size(truth_sequence));
truth_states(truth_sequence == occupied_state_label) = 2;
truth_states(truth_sequence == idle_state_label) = 1;

observations = detector_decisions + 1;

emission_counts = zeros(2, 2);
for idx = 1:numel(observations)
    emission_counts(truth_states(idx), observations(idx)) = ...
        emission_counts(truth_states(idx), observations(idx)) + 1;
end

row_sums = sum(emission_counts, 2);
emission_matrix = emission_counts ./ row_sums;

% if the data-driven estimate is too sharp or unstable, fall back to a
% simple diagonally dominant emission guess
if any(~isfinite(emission_matrix), 'all') || any(row_sums == 0) || any(emission_matrix(:) == 0)
    emission_matrix = [0.95, 0.05; 0.05, 0.95];
else
    emission_matrix = max(emission_matrix, 1e-6);
    emission_matrix = emission_matrix ./ sum(emission_matrix, 2);
end

end
