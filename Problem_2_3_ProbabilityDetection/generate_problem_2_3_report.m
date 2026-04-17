function generate_problem_2_3_report()
%GENERATE_PROBLEM_2_3_REPORT Build the markdown summary from saved results.

script_dir = fileparts(mfilename('fullpath'));
results_path = fullfile(script_dir, 'problem_2_3_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_3.md');

loaded_results = load(results_path);

Pd_values = loaded_results.Pd_values;
eta = loaded_results.eta;
sigma_n = loaded_results.sigma_n;
K = loaded_results.K;
Es = loaded_results.Es;

channel_lines = strings(numel(Pd_values), 1);
for channel_idx = 1:numel(Pd_values)
    channel_lines(channel_idx) = sprintf('| %d | %.12g | %.12g | %.12g |', ...
        channel_idx, sigma_n(channel_idx).^2, eta(channel_idx), Pd_values(channel_idx));
end

report_lines = [
    "# Problem 2.3 Probability of Detection"
    ""
    "## Problem Summary"
    "This step computes the theoretical probability of detection for the energy detector using the saved noise variance estimates from Problem 2.1 and the saved thresholds from Problem 2.2."
    ""
    "## Equations Used"
    "The Marcum-Q formulation from the assignment was used:"
    "`P_D = Q_K(sqrt(Es)/sigma_n, sqrt(eta)/sigma_n)`"
    "`P_MD = 1 - P_D`"
    ""
    "## Parameters"
    sprintf('- `K = %d` complex samples per measurement', K)
    sprintf('- `Es = K * signal_power = %.12g` with `signal_power = 1`', Es)
    "- `sigma_n^2` came from Problem 2.1"
    "- `eta` came from Problem 2.2"
    ""
    "## Computed P_D Values"
    "| Channel | Noise Variance | Threshold | P_D |"
    "| --- | ---: | ---: | ---: |"
    channel_lines
    ""
    "## Plot"
    "The bar chart below shows all 6 channels."
    "![Energy Detector Probability of Detection](probability_detection_bar.png)"
    ""
];

fid = fopen(report_path, 'w');
for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
fclose(fid);

fprintf('Problem 2.3 report saved to %s\n', report_path);

end
