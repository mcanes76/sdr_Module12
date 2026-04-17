function timeslot_matrix = reshape_timeslots(signal_vector, samples_per_timeslot)
%RESHAPE_TIMESLOTS Reshape a vector into column-wise timeslots.

signal_vector = signal_vector(:);
num_complete_slots = floor(numel(signal_vector) / samples_per_timeslot);
if num_complete_slots < 1
    error('signal_vector must contain at least one full timeslot.');
end
signal_vector = signal_vector(1:num_complete_slots * samples_per_timeslot);
timeslot_matrix = reshape(signal_vector, samples_per_timeslot, num_complete_slots);

end

