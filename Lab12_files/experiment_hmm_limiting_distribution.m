transition_matrix = [0.5, 0.5; 0.2, 0.8];
emission_matrix = [0.95, 0.05; 0.25, 0.75]; % [5% False alarm, 25% Missed detection]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the Limiting Distribution by Directly Observing the State
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate a bunch of transitions and states to directly observe
number_of_transitions = 65536;
[emission_seq,state_seq] = hmmgenerate(number_of_transitions, ...
transition_matrix, emission_matrix);

% Compute the averages
large_number_average_state_probabilities = ...
[sum(state_seq==1)/number_of_transitions, ...
sum(state_seq==2)/number_of_transitions];

disp('Average probability of states after many direct observations')
disp(large_number_average_state_probabilities)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate the Limiting Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trans_1_2 = transition_matrix(1,2);
trans_2_1 = transition_matrix(2,1);
limiting_transition_matrix = 1/(trans_1_2+trans_2_1)*...
    [trans_2_1, trans_1_2 ; trans_2_1, trans_1_2];
limiting_state_probabilities = ...
    [trans_2_1/(trans_1_2+trans_2_1) trans_1_2/(trans_1_2+trans_2_1)];
disp('Limiting Distribution of states')
disp(large_number_average_state_probabilities)





