function [threshold_estimate, threshold_info] = compute_energy_threshold(noise_variance_estimate, measurement_length, target_pfa)
%COMPUTE_ENERGY_THRESHOLD Compute the summed-energy threshold for a target Pfa.

% use the gamma inverse CDF because the summed complex-noise energy over
% one timeslot is gamma distributed with shape N and scale sigma^2
threshold_estimate = gaminv(1 - target_pfa, measurement_length, noise_variance_estimate);

if nargout > 1
    threshold_info = struct();
    threshold_info.shape = measurement_length;
    threshold_info.scale = noise_variance_estimate;
    threshold_info.achieved_pfa = 1 - gamcdf(threshold_estimate, measurement_length, noise_variance_estimate);
end

end
