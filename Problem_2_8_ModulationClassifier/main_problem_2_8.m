function main_problem_2_8()
%MAIN_PROBLEM_2_8 Run Module 12 Extra Credit Problem 2.8 workflow.

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
network_path = fullfile(repo_root, 'Lab12_files', 'trainedModulationClassificationNetwork.mat');
test_data_path = fullfile(repo_root, 'Lab12_files', 'TestData.mat');
results_path = fullfile(script_dir, 'problem_2_8_results.mat');
accuracy_plot_path = fullfile(script_dir, 'accuracy_vs_snr.png');

% load the same pretrained network and BPSK data used by the live lab
network_data = load(network_path, 'trainedNet');
test_data = load(test_data_path, 'bpsk_signal', 'bpsk_signal_labels');

trainedNet = network_data.trainedNet;
bpsk_signal = test_data.bpsk_signal;
bpsk_signal_labels = test_data.bpsk_signal_labels;

snr_db = 10:-0.5:3;
num_vectors = 1000;
vector_length = 1024;
num_snr_points = numel(snr_db);

% Keep the exact tensor formatting from modulation_classification_in_noise.m
% so the pretrained CNN sees the same kind of input it was built around.
bpsk_signal_matrix = reshape(bpsk_signal, vector_length, num_vectors);
bpsk_signal_tensor = zeros(1, vector_length, 2, num_vectors);
bpsk_signal_tensor(1,:,1,:) = real(bpsk_signal_matrix(:,:));
bpsk_signal_tensor(1,:,2,:) = imag(bpsk_signal_matrix(:,:));

correct_counts = zeros(num_snr_points, 1);
accuracy = zeros(num_snr_points, 1);
predicted_labels = cell(num_snr_points, 1);

constellation_snr_values = [10, 7, 5, 3];
constellation_plot_paths = strings(size(constellation_snr_values));

for snr_idx = 1:num_snr_points
    current_snr_db = snr_db(snr_idx);

    % Reuse the same clean BPSK signal at every SNR so the only thing
    % changing in the experiment is the AWGN level.
    num_samps = length(bpsk_signal);
    noise_vector = randn(1, num_samps) + 1.0i * randn(1, num_samps);
    noise_vector = noise_vector * sqrt(1/2);
    noise_vector = noise_vector * sqrt(10^(-current_snr_db/10));
    noise_vector = noise_vector(:);

    noise_matrix = reshape(noise_vector, vector_length, num_vectors);
    noise_tensor = zeros(1, vector_length, 2, num_vectors);
    noise_tensor(1,:,1,:) = real(noise_matrix(:,:));
    noise_tensor(1,:,2,:) = imag(noise_matrix(:,:));

    rxTestPredbpsk = classify(trainedNet, bpsk_signal_tensor + noise_tensor);
    correct_counts(snr_idx) = sum(rxTestPredbpsk == bpsk_signal_labels);
    accuracy(snr_idx) = correct_counts(snr_idx) / num_vectors;
    predicted_labels{snr_idx} = rxTestPredbpsk;

    if any(abs(current_snr_db - constellation_snr_values) < eps)
        % Show how the I/Q cloud spreads out as SNR drops.
        rxd_signal = bpsk_signal + noise_vector;
        fig = figure('Visible', 'on');
        histogram2(real(rxd_signal), imag(rxd_signal), 'FaceColor', 'flat');
        title(sprintf('BPSK Constellation at SNR %.0f dB', current_snr_db));
        xlabel('Real');
        ylabel('Imaginary');
        zlabel('Occurrence');
        plot_path = fullfile(script_dir, sprintf('bpsk_constellation_snr%.0f.png', current_snr_db));
        exportgraphics(fig, plot_path, 'Resolution', 150);
        %close(fig);
        constellation_plot_paths(constellation_snr_values == current_snr_db) = string(plot_path);
    end
end

accuracy_fig = figure('Visible', 'on');
plot(snr_db, accuracy, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
grid on;
xlabel('SNR (dB)');
ylabel('Accuracy');
title('Pre-trained Modulation Classifier Accuracy vs SNR (BPSK)');
exportgraphics(accuracy_fig, accuracy_plot_path, 'Resolution', 150);
%close(accuracy_fig);

results = struct();
results.snr_db = snr_db;
results.num_vectors = num_vectors;
results.vector_length = vector_length;
results.correct_counts = correct_counts;
results.accuracy = accuracy;
results.predicted_labels = predicted_labels;
results.true_label = bpsk_signal_labels;
results.metadata = struct( ...
    'network_source', 'Lab12_files/trainedModulationClassificationNetwork.mat', ...
    'input_format', '1x1024x2x1000_real_imag_tensor', ...
    'snr_range_definition', '10_to_3_dB_in_0p5_dB_steps');

save(results_path, 'results');

fprintf('Problem 2.8 results saved to %s\n', results_path);
fprintf('Problem 2.8 accuracy plot saved to %s\n', accuracy_plot_path);
for snr_idx = 1:num_snr_points
    fprintf('SNR %.1f dB: %d / %d correct, accuracy = %.4f\n', ...
        snr_db(snr_idx), correct_counts(snr_idx), num_vectors, accuracy(snr_idx));
end

end
