function generate_problem_2_1_report()
%GENERATE_PROBLEM_2_1_REPORT Build the markdown report from saved results.

script_dir = fileparts(mfilename('fullpath'));
results_path = fullfile(script_dir, 'problem_2_1_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_1.md');

loaded_results = load(results_path, 'results');
results = loaded_results.results;

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
    "The MDL noise estimator reused here is the same implementation developed in Module 11."
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
    sprintf(['Timeslot energies were computed with `samples_per_timeslot = %d` for the example channel and each of the six unknown channels, then saved into `problem_2_1_results.mat` for later problems. ', ...
        'These energies were not used as the Problem 2.1 noise estimator.'], ...
        results.metadata.samples_per_timeslot)
    ""
];

fid = fopen(report_path, 'w');
for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
fclose(fid);

fprintf('Problem 2.1 report saved to %s\n', report_path);

end
