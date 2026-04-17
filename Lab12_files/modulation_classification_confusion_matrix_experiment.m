
% Load the pre-trained network
load trainedModulationClassificationNetwork

% Load the data that will be used
% loads rxTestFrames
load TestData.mat



% select signal
sig_idx = 95;

% rxTestFrames is a cell array of tensors, select the sig_idx cell
array_from_cell = rxTestFrames{sig_idx};

% Create a complex-valued signal from that tensor
txSig = array_from_cell(1,:,1) + 1.0i*array_from_cell(1,:,2);

% plot the signal as a 2D histogram on the complex plane
figure
histogram2(real(txSig),imag(txSig),'Normalization','pdf','FaceColor','flat')
title('BPSK Constellation')
xlabel('Real')
ylabel('Imaginary')
zlabel('Occurance')
colorbar
view(2)

% The signal must be organized into 4D tensor
% as required by the network
% That shape is
% 1 row, 1024 columns, 2 pages, and then some number of frames
rxTestFrames4D = cat(4, rxTestFrames{:});

% Call the network
rxTestPred = classify(trainedNet,rxTestFrames4D);
testAccuracy = mean(rxTestPred == rxTestLabels);
disp("Test accuracy: " + testAccuracy*100 + "%")

figure
cm = confusionchart(rxTestLabels, rxTestPred);
cm.Title = 'Confusion Matrix for Test Data';
cm.RowSummary = 'row-normalized';
cm.Parent.Position = [cm.Parent.Position(1:2) 950 550];

