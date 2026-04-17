function timeslot_energy = compute_timeslot_energy(timeslot_matrix)
%COMPUTE_TIMESLOT_ENERGY Compute column-wise energy for each timeslot.

timeslot_energy = sum(abs(timeslot_matrix).^2, 1);

end

