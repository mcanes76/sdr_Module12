
% Load the pre-trained network
load trainedModulationClassificationNetwork

% Load the data that will be used
load TestData.mat

%Specify the SNR
SNR_val_dB = 7;


% The BPSK signal must be organized into 4D tensor
% as required by the network
% That shape is
% 1 row, 1024 columns, 2 pages, and 1000 frames
bpsk_signal_matrix = reshape(bpsk_signal,1024,1000);
bpsk_signal_tensor = zeros(1,1024,2,1000);
bpsk_signal_tensor(1,:,1,:) = real(bpsk_signal_matrix(:,:));
bpsk_signal_tensor(1,:,2,:) = imag(bpsk_signal_matrix(:,:));
rxTestFrames4D = cat(4, rxTestFrames{:});

% Create a 4D noise tensor
NumSamps = length(bpsk_signal);
noise_vector = randn(1,NumSamps)+1.0i*randn(1,NumSamps);
noise_vector = noise_vector*sqrt(1/2);
noise_vector = noise_vector*sqrt(10^(-SNR_val_dB/10));
noise_vector = noise_vector(:);
noise_matrix = reshape(noise_vector,1024,1000);
noise_tensor = zeros(1,1024,2,1000);
noise_tensor(1,:,1,:) = real(noise_matrix(:,:));
noise_tensor(1,:,2,:) = imag(noise_matrix(:,:));


% plotting the histogram of the BPSK signal at the designated SNR
% for the student to inspect
rxd_signal = bpsk_signal+noise_vector;
figure
histogram2(real(rxd_signal),...
    imag(rxd_signal),'Normalization','pdf','FaceColor','flat')
title(['BPSK Constellation at SNR ' num2str(SNR_val_dB) ' dB'])
xlabel('Real')
ylabel('Imaginary')
zlabel('Occurance')
colorbar
view(2)

% Call the network
rxTestPredbpsk = classify(trainedNet,bpsk_signal_tensor+noise_tensor);
testAccuracy = mean(rxTestPredbpsk == bpsk_signal_labels);
disp("BPSK Test accuracy: " + testAccuracy*100 + "%")