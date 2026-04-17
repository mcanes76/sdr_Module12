function [kVal, kMin] = calcKMin(sorted_eig_vector, num_observations, num_samples_per_observation)

L = num_samples_per_observation;
N = num_observations;
kVal = zeros(L, 1);

for kIdx = 0:L-1
    trailing_eigvals = sorted_eig_vector(kIdx+1:L);
    trailing_eigvals = max(real(trailing_eigvals), eps);

    phi_val = exp(mean(log(trailing_eigvals)));
    theta_val = mean(trailing_eigvals);

    kVal(kIdx+1) = -(L-kIdx)*N*log(phi_val/theta_val) + ...
        0.5*kIdx*(2*L-kIdx)*log(N);
end

[~, min_idx] = min(kVal);
kMin = min_idx - 1;

end
