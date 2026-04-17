transition_matrix = [0.8, 0.2; 0.2, 0.8];

number_of_transitions = 65536;

constant_prob_falarm = 0.05;

% Create Emission Matrices for the High and Low SNR cases.
% Note that the transmission matrix does not change.
% becuase whether or not the transmitter chooses to transmit
% is _not_ a function of SNR at your receiver.
% What is a function of SNR at your receiver is whether or not 
% your can observe the transmission.
% That is what the Emissions Matrix helps determine.
prob_detect = 0.75;
emission_matrix_lowSNR = ...
    [1-constant_prob_falarm, constant_prob_falarm;...
    1-prob_detect, prob_detect];

prob_detect = 0.99;
emission_matrix_highSNR = ...
    [1-constant_prob_falarm, constant_prob_falarm;...
    1-prob_detect, prob_detect];


%Create state and emission sequences for the High SNR cases
[emission_sequence_highSNR, state_sequence_highSNR] = ...
    hmmgenerate(number_of_transitions, ...
    transition_matrix, emission_matrix_highSNR);

%Create state and emission sequences for the Low SNR cases
[emission_sequence_lowSNR, state_sequence_lowSNR] = ...
    hmmgenerate(number_of_transitions, ...
    transition_matrix, emission_matrix_lowSNR);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Case One: High SNR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
emission_matrix_estimate = emission_matrix_highSNR;
observed_sequence = emission_sequence_highSNR;

% We need a guess as to what the transition matrix is
initial_transition_matrix_guess = [0.5, 0.5; 0.5, 0.5]; 

% Estimate the state transition matrix by way of training an HMM
[estimated_state_transition_matrix, estimated_emission_matrix] = ...
    hmmtrain(observed_sequence, ...
    initial_transition_matrix_guess,...
    emission_matrix_estimate, ...
    'Algorithm','BaumWelch', 'Maxiterations', 5000, 'Tolerance', 1e-5);

% Estimate the state transition matrix by observing the emissions
count_transitions = zeros(2,2);
for idx=1:(length(observed_sequence)-1)
    current_state = observed_sequence(idx);
    next_state = observed_sequence(idx + 1);
    count_transitions(current_state,next_state) = ...
        count_transitions(current_state,next_state) + 1;
end
normalization_factors_vector = sum(count_transitions,2);
observed_state_transition_matrix = ...
    count_transitions * 1./normalization_factors_vector;

disp('Case 1: High SNR')
disp('Difference between the MM and Truth')
disp(...
    abs(transition_matrix - ...
    estimated_state_transition_matrix))

disp('Difference between the Observations and Truth')
disp(...
    abs(observed_state_transition_matrix - ...
    transition_matrix))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Case Two: Low SNR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
emission_matrix_estimate = emission_matrix_lowSNR;
observed_sequence = emission_sequence_lowSNR;

initial_transition_matrix_guess = [0.5, 0.5; 0.5, 0.5]; 
% Estimate the state transition matrix by way of training an HMM
[estimated_state_transition_matrix, estimated_emission_matrix] = ...
    hmmtrain(observed_sequence, ...
    initial_transition_matrix_guess,...
    emission_matrix_estimate, ...
    'Algorithm','BaumWelch', 'Maxiterations', 5000, 'Tolerance', 1e-5);

% Estimate the state transition matrix by observing the emissions
count_transitions = zeros(2,2);
for idx=1:(length(observed_sequence)-1)
    current_state = observed_sequence(idx);
    next_state = observed_sequence(idx + 1);
    count_transitions(current_state,next_state) = ...
        count_transitions(current_state,next_state) + 1;
end
normalization_factors_vector = sum(count_transitions,2);
observed_state_transition_matrix = ...
    count_transitions * 1./normalization_factors_vector;

disp('Case 2: Low SNR')
disp('Difference between the MM and Truth')
disp(...
    abs(transition_matrix - ...
    estimated_state_transition_matrix))

disp('Difference between the Observations and Truth')
disp(...
    abs(observed_state_transition_matrix - ...
    transition_matrix))









