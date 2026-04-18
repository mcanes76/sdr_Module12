function generate_problem_2_8_report()
%GENERATE_PROBLEM_2_8_REPORT Build the markdown summary from saved results.

script_dir = fileparts(mfilename('fullpath'));
results_path = fullfile(script_dir, 'problem_2_8_results.mat');
report_path = fullfile(script_dir, 'report_problem_2_8.md');

loaded_results = load(results_path, 'results');
results = loaded_results.results;

snr_lines = strings(numel(results.snr_db), 1);
for idx = 1:numel(results.snr_db)
    snr_lines(idx) = sprintf('| %.1f | %d | %.4f |', ...
        results.snr_db(idx), results.correct_counts(idx), results.accuracy(idx));
end

report_lines = [
    "# Problem 2.8 Modulation Classifier Accuracy vs SNR"
    ""
    "## Objective"
    "Evaluate the pretrained CNN modulation classifier on BPSK-only inputs as a function of SNR using the same signal path as the live-lab script."
    ""
    "## Experiment Setup"
    sprintf('- `%d` vectors per SNR', results.num_vectors)
    sprintf('- vector length `%d` samples', results.vector_length)
    "- SNR sweep: `10` down to `3` dB in `0.5` dB steps"
    "- pretrained CNN classifier from the live lab"
    ""
    "## Results"
    "| SNR (dB) | Correct Count | Accuracy |"
    "| --- | ---: | ---: |"
    snr_lines
    ""
    "![Pre-trained Modulation Classifier Accuracy vs SNR (BPSK)](accuracy_vs_snr.png)"
    ""
    "### Example Constellation Density Plots"
    "![BPSK Constellation at SNR 10 dB](bpsk_constellation_snr10.png)"
    "![BPSK Constellation at SNR 7 dB](bpsk_constellation_snr7.png)"
    "![BPSK Constellation at SNR 5 dB](bpsk_constellation_snr5.png)"
    "![BPSK Constellation at SNR 3 dB](bpsk_constellation_snr3.png)"
    ""
    "## Interpretation"
    "Accuracy decreases as SNR decreases because noise obscures the BPSK structure in the I/Q samples, which makes the constellation clusters harder for the classifier to separate."
    ""
    "## Improvement Ideas"
    "- train or fine-tune with more low-SNR BPSK examples"
    "- use data augmentation over a wider SNR range"
    "- increase the observation length beyond 1024 samples if the model allows it"
    "- add denoising or front-end preprocessing before classification"
    "- use a larger or more robust CNN architecture"
    ""
];

fid = fopen(report_path, 'w');
for line_idx = 1:numel(report_lines)
    fprintf(fid, '%s\n', report_lines(line_idx));
end
fclose(fid);

fprintf('Problem 2.8 report saved to %s\n', report_path);

end
