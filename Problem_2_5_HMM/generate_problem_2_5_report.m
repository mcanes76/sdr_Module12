function generate_problem_2_5_report()
%GENERATE_PROBLEM_2_5_REPORT Build the markdown summary from saved results.

script_dir = fileparts(mfilename('fullpath'));
results_path = fullfile(script_dir, 'problem_2_5_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_5.md');

loaded_results = load(results_path, 'results');
results = loaded_results.results;

channel_sections = strings(numel(results.channels), 1);
for channel_idx = 1:numel(results.channels)
    matrix_text = format_matrix(results.channels(channel_idx).transition_matrix);
    channel_sections(channel_idx) = sprintf('### Channel %d\n```text\n%s\n```', ...
        channel_idx, matrix_text);
end

report_lines = [
    "# Problem 2.5 HMM Transition Matrix Estimation"
    ""
    "## Objective"
    "Estimate a two-state HMM transition matrix for the example channel and all six channels using the detector outputs saved in Problem 2.4."
    ""
    "## HMM Interpretation"
    "The hidden states are `S1 = idle` and `S2 = occupied`."
    "The saved detector outputs from Problem 2.4 are treated as observations, not direct hidden-state labels."
    "That means the transition matrices reported here are inferred from detector observations through the HMM model."
    ""
    "## Observation / State Definitions"
    sprintf('- State definition: `%s`', results.metadata.state_definition)
    sprintf('- Observation definition: `%s`', results.metadata.observation_definition)
    sprintf('- Transition matrix orientation: `%s`', results.metadata.transition_matrix_orientation)
    ""
    "## Example Channel"
    "### Transition Matrix"
    "```text"
    format_matrix(results.example_channel.transition_matrix)
    "```"
    "### Emission Matrix"
    "```text"
    format_matrix(results.example_channel.emission_matrix)
    "```"
    ""
    "## Transition Matrix Results for Channels 1-6"
    channel_sections
    ""
    "## Emission Initialization Note"
    "The initial emission matrix was estimated from the example-channel detector behavior in Problem 2.4, with a simple diagonally dominant fallback kept in reserve for stability."
    ""
];

fid = fopen(report_path, 'w');
for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
fclose(fid);

fprintf('Problem 2.5 report saved to %s\n', report_path);

end

function matrix_text = format_matrix(matrix_value)
matrix_text = sprintf('%.6f %.6f\n%.6f %.6f', ...
    matrix_value(1,1), matrix_value(1,2), ...
    matrix_value(2,1), matrix_value(2,2));
end
