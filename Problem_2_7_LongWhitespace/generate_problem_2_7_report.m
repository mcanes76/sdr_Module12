function generate_problem_2_7_report()
%GENERATE_PROBLEM_2_7_REPORT Build the markdown summary from saved results.

script_dir = fileparts(mfilename('fullpath'));
results_path = fullfile(script_dir, 'problem_2_7_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_7.md');

loaded_results = load(results_path, 'results');
results = loaded_results.results;

channel_lines = strings(numel(results.channels), 1);
for channel_idx = 1:numel(results.channels)
    channel_lines(channel_idx) = sprintf('| %d | %.8f | %.8f | %.8f |', ...
        channel_idx, ...
        results.channels(channel_idx).observed_probability_4_idle, ...
        results.channels(channel_idx).predicted_probability_4_idle, ...
        results.channels(channel_idx).difference);
end

report_lines = [
    "# Problem 2.7 Long Whitespace Probability"
    ""
    "## Objective"
    "Compute the probability of a sliding length-4 all-idle window in two ways: directly from the Problem 2.4 detector outputs and from the Markov model built in Problems 2.5 and 2.6."
    ""
    "## Event Definition"
    "The event is an overlapping sliding window of 4 consecutive idle time slots."
    "For a sequence of length `N`, there are `N-3` candidate windows."
    ""
    "## Example Channel"
    sprintf('- Observed probability of 4 idle slots: `%.8f`', ...
        results.example_channel.observed_probability_4_idle)
    sprintf('- Predicted Markov-model probability: `%.8f`', ...
        results.example_channel.predicted_probability_4_idle)
    sprintf('- Difference (observed - predicted): `%.8f`', ...
        results.example_channel.difference)
    ""
    "## All Channels"
    "| Channel | Observed P(4 idle) | Predicted P(4 idle) | Difference |"
    "| --- | ---: | ---: | ---: |"
    channel_lines
    ""
    "## Why They May Differ"
    "The observation-based probability comes from a finite detector output sequence, while the Markov-model probability comes from a steady-state chain approximation."
    "Differences can come from detector errors, HMM estimation through observations instead of hidden states, finite sample length, and mismatch between steady-state behavior and the measured sequence."
    ""
];

fid = fopen(report_path, 'w');
for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
fclose(fid);

fprintf('Problem 2.7 report saved to %s\n', report_path);

end
