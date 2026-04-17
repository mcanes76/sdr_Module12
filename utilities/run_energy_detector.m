function decisions = run_energy_detector(timeslot_energy, threshold)
%RUN_ENERGY_DETECTOR Apply the saved threshold to a timeslot-energy vector.

decisions = timeslot_energy > threshold;

end
