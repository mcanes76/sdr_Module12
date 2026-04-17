function generate_problem_2_2_report()
%GENERATE_PROBLEM_2_2_REPORT Build the markdown summary from saved results.

script_dir = fileparts(mfilename('fullpath'));
results_path = fullfile(script_dir, 'problem_2_2_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_2.md');

loaded_results = load(results_path, 'results');
results = loaded_results.results;

channel_lines = strings(numel(results.channels), 1);
for channel_idx = 1:numel(results.channels)
    channel_lines(channel_idx) = sprintf('| %d | %.12g | %.12g |', ...
        channel_idx, ...
        results.channels(channel_idx).noise_variance_estimate, ...
        results.channels(channel_idx).threshold_estimate);
end

pass_text = 'No';
if results.example_channel.pass_pfa_requirement
    pass_text = 'Yes';
end

report_lines = [
    "# Problem 2.2 CFAR Threshold"
    ""
    "## Objective"
    "Compute the energy-detector threshold for each channel at `target_pfa = 0.05` while reusing the saved noise variance estimates from Problem 2.1 instead of recomputing them from raw data."
    ""
    "## Threshold Theory"
    "The detector statistic is summed timeslot energy over 10 samples, not average energy."
    "Under the noise-only model, the summed complex-sample energy over one timeslot is treated as gamma distributed with shape `N = 10` and scale `sigma2_hat`."
    sprintf('The threshold was computed with `%s`.', results.metadata.threshold_formula)
    ""
    "## Example Channel Validation"
    sprintf('- Threshold estimate: `%.12g`', results.example_channel.threshold_estimate)
    sprintf('- Threshold truth: `%.12g`', results.example_channel.threshold_truth)
    sprintf('- Relative error vs truth: `%.8f` (%.4f%%)', ...
        results.example_channel.relative_error, 100 * results.example_channel.relative_error)
    sprintf('- Achieved false alarm probability: `%.8f`', results.example_channel.achieved_pfa)
    sprintf('- Passes required Pfa range [0.049, 0.051]: `%s`', pass_text)
    ""
    "## Six Channel Threshold Table"
    "| Channel | Noise Variance Estimate | Threshold Estimate |"
    "| --- | ---: | ---: |"
    channel_lines
    ""
    "## Continuity"
    "These thresholds are ready for Problem 2.3 probability-of-detection work and Problem 2.4 occupancy decisions."
    "Those later problems should reuse the same summed-timeslot-energy statistic and the same Problem 2.1 noise inputs so the scaling stays consistent."
    ""
];

fid = fopen(report_path, 'w');
for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
fclose(fid);

fprintf('Problem 2.2 report saved to %s\n', report_path);

end
