function generate_problem_2_4_report()
%GENERATE_PROBLEM_2_4_REPORT Build the markdown summary from saved results.

script_dir = fileparts(mfilename('fullpath'));
results_path = fullfile(script_dir, 'problem_2_4_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_4.md');

loaded_results = load(results_path, 'results');
results = loaded_results.results;

channel_lines = strings(numel(results.channels), 1);
for channel_idx = 1:numel(results.channels)
    channel_lines(channel_idx) = sprintf('| %d | %.4f | %.4f |', ...
        channel_idx, ...
        results.channels(channel_idx).percent_occupied, ...
        results.channels(channel_idx).percent_idle);
end

report_lines = [
    "# Problem 2.4 Energy Detection"
    ""
    "## Objective"
    "Apply the saved thresholds from Problem 2.2 to the saved timeslot energies from Problem 2.1 to determine whether each timeslot is occupied or idle."
    ""
    "## Detector Definition"
    "The detector statistic is summed timeslot energy over one 10-sample timeslot."
    "The decision rule is `occupied if timeslot_energy > threshold`, and idle otherwise."
    ""
    "## Example Channel Validation"
    sprintf('- Percent occupied: `%.4f%%`', results.example_channel.percent_occupied)
    sprintf('- Percent idle: `%.4f%%`', results.example_channel.percent_idle)
    sprintf('- Percent agreement with truth: `%.4f%%`', results.example_channel.percent_agreement)
    sprintf('- True positives: `%d`', results.example_channel.true_positives)
    sprintf('- True negatives: `%d`', results.example_channel.true_negatives)
    sprintf('- False alarms: `%d`', results.example_channel.false_alarms)
    sprintf('- Missed detections: `%d`', results.example_channel.missed_detections)
    ""
    "## Occupied / Idle Percentages"
    "| Channel | Percent Occupied | Percent Idle |"
    "| --- | ---: | ---: |"
    channel_lines
    ""
    "## Continuity"
    "The full binary decision vectors were saved in `problem_2_4_results.mat` so the later HMM-related problems can reuse the channel activity sequences directly."
    ""
];

fid = fopen(report_path, 'w');
for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
fclose(fid);

fprintf('Problem 2.4 report saved to %s\n', report_path);

end
