function generate_problem_2_6_report()
%GENERATE_PROBLEM_2_6_REPORT Build the markdown summary from saved results.

script_dir = fileparts(mfilename('fullpath'));
results_path = fullfile(script_dir, 'problem_2_6_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_6.md');

loaded_results = load(results_path, 'results');
results = loaded_results.results;

channel_lines = strings(numel(results.channels), 1);
for channel_idx = 1:numel(results.channels)
    channel_lines(channel_idx) = sprintf('| %d | %.4f | %.4f | %.4f | %.4f |', ...
        channel_idx, ...
        results.channels(channel_idx).predicted_percent_idle, ...
        results.channels(channel_idx).predicted_percent_occupied, ...
        results.channels(channel_idx).observed_percent_idle, ...
        results.channels(channel_idx).observed_percent_occupied);
end

report_lines = [
    "# Problem 2.6 Limiting Distribution"
    ""
    "## Limiting Distribution Explanation"
    "The limiting distribution gives the long-term fraction of time that the two-state Markov chain spends in the idle and occupied states."
    "For this homework, the steady-state probabilities were computed from the Problem 2.5 transition matrices using the two-state closed-form formula."
    ""
    "## Example Channel Results"
    "| Quantity | Idle % | Occupied % |"
    "| --- | ---: | ---: |"
    sprintf('| Predicted | %.4f | %.4f |', ...
        results.example_channel.predicted_percent_idle, ...
        results.example_channel.predicted_percent_occupied)
    sprintf('| Observed | %.4f | %.4f |', ...
        results.example_channel.observed_percent_idle, ...
        results.example_channel.observed_percent_occupied)
    sprintf('| Truth | %.4f | %.4f |', ...
        results.example_channel.truth_percent_idle, ...
        results.example_channel.truth_percent_occupied)
    ""
    "## Six Channel Predictions"
    "| Channel | Predicted Idle % | Predicted Occupied % | Observed Idle % | Observed Occupied % |"
    "| --- | ---: | ---: | ---: | ---: |"
    channel_lines
    ""
    "## Quietest Channels"
    sprintf('The two channels with the lowest predicted occupied probability are **Channel %d** and **Channel %d**.', ...
        results.summary.quietest_channel_indices(1), ...
        results.summary.quietest_channel_indices(2))
    sprintf(['Their predicted occupied percentages are `%.4f%%` and `%.4f%%`, ', ...
        'so they look like the best choices for secondary access.'], ...
        results.summary.quietest_channel_predicted_occupied_percentages(1), ...
        results.summary.quietest_channel_predicted_occupied_percentages(2))
    ""
];

fid = fopen(report_path, 'w');
for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
fclose(fid);

fprintf('Problem 2.6 report saved to %s\n', report_path);

end
