function [noise_estimate, estimate_info] = EstimateNoiseMDL(captured_data, num_samples_per_observation)

if nargin < 2
    num_samples_per_observation = 64;
end

captured_data = captured_data(:);

num_observations = floor(length(captured_data) / num_samples_per_observation);

if num_observations < 1
    error('captured_data must contain at least one full observation.')
end

num_samples_used = num_observations * num_samples_per_observation;
captured_data = captured_data(1:num_samples_used);

observation_matrix = reshape(captured_data, num_samples_per_observation, num_observations);
observation_matrix = observation_matrix - mean(observation_matrix, 2);

covariance_matrix = (observation_matrix * observation_matrix') / (num_observations - 1);
eig_vector = eig(covariance_matrix);
sorted_eig_vector = sort(real(eig_vector), 'descend');

[kVal, kMin] = calcKMin(sorted_eig_vector, num_observations, num_samples_per_observation);
noise_estimate = mean(sorted_eig_vector(kMin+1:num_samples_per_observation));

if nargout > 1
    estimate_info.kVal = kVal;
    estimate_info.kMin = kMin;
    estimate_info.sorted_eig_vector = sorted_eig_vector;
    estimate_info.num_observations = num_observations;
    estimate_info.observation_length = num_samples_per_observation;
end

end
