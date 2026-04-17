# Architecture for Module 12 Problem 2.4

## 1. Purpose

Problem 2.4 applies the energy-detector threshold to every timeslot in each channel and turns the continuous-valued timeslot energies into a binary occupancy sequence.

This problem depends directly on:
- Problem 2.1 for the saved timeslot energies
- Problem 2.2 for the saved per-channel thresholds

This is also the first step where the module produces a full time-indexed activity sequence. That sequence is likely the main observation sequence needed later in Problems 2.5 and 2.6 for HMM-style modeling and limiting-distribution analysis.

## 2. Inputs and Dependencies

Inputs from `Problem_2_1_NoiseEstimation/problem_2_1_results.mat`:
- `results.example_channel.timeslot_energy`
- `results.channels(i).timeslot_energy`
- `results.metadata.samples_per_timeslot`

Inputs from `Problem_2_2_CFARThreshold/problem_2_2_results.mat`:
- `results.example_channel.threshold_estimate`
- `results.channels(i).threshold_estimate`
- `results.metadata.measurement_length`

Inputs from `data/hw12_test_data.mat`:
- `example_channel_state_sequence`

The example truth sequence should be included explicitly in Problem 2.4 because it is the only ground-truth activity sequence available for direct validation.

Existing utilities:
- `reshape_timeslots.m` and `compute_timeslot_energy.m` were already used in Problem 2.1, but Problem 2.4 should not need to recompute energies if it fully reuses the saved outputs.
- `compute_energy_threshold.m` was used in Problem 2.2, but Problem 2.4 should not need to recompute thresholds if it fully reuses the saved outputs.

Recommended new helper:
- A very small helper such as `utilities/run_energy_detector.m` is reasonable.
- This is optional, but it can keep the decision rule in one place and make later reuse easier.

Recommended helper behavior if added:
- Inputs:
  - `timeslot_energy`
  - `threshold`
- Outputs:
  - `decisions`
  - optional occupancy summary values

## 3. Detector Definition

Detector statistic:
- summed timeslot energy over 10 samples

The saved timeslot_energy values from Problem 2.1 already represent the summed energy over each 10-sample timeslot, so no additional windowing or summation is required in Problem 2.4.

Decision rule:
- occupied if `timeslot_energy > threshold`
- idle otherwise

This must match the conventions established in Problems 2.1 and 2.2:
- Problem 2.1 already saved summed timeslot energies
- Problem 2.2 already computed thresholds for that same summed-energy statistic

If Problem 2.4 changed the statistic or the comparison rule, the threshold would no longer match the saved energy values. Keeping the convention fixed avoids accidental scaling mistakes.

## 4. Occupancy Metrics

For each channel, define a binary decision sequence:
- `1` means occupied
- `0` means idle

For each channel, define:
- occupied percentage = `100 * mean(decisions == 1)`
- idle percentage = `100 * mean(decisions == 0)`

These two percentages should sum to 100%, up to small floating-point formatting error.

It is important to keep the full binary decision vector, not just the percentages, because:
- the assignment asks for per-timeslot signal presence decisions
- the example channel can be compared directly against truth
- Problems 2.5 and 2.6 will likely want the full observation sequence, not just summary percentages

## 5. Example-Channel Validation

The example channel includes a truth sequence, so Problem 2.4 should validate the detector output against:
- `example_channel_state_sequence`

Recommended simple validation outputs:
- decision sequence
- percent agreement with truth
- confusion-style counts if helpful:
  - true positives
  - true negatives
  - false alarms
  - missed detections

About the word "correlation" in the homework hint:
- literal correlation coefficient is possible
- percent agreement is simpler and usually easier to interpret for a homework detector check

Recommended choice:
- use percent agreement as the main reported measure
- optionally include a simple correlation coefficient only if it adds value without clutter

This keeps the validation tied directly to whether the detector decisions match the truth labels.

## 6. Proposed Software Architecture

Keep Problem 2.4 simple and aligned with the rest of the module.

Recommended files:
- `Problem_2_4_EnergyDetection/main_problem_2_4.m`
- `Problem_2_4_EnergyDetection/generate_problem_2_4_report.m`
- `Problem_2_4_EnergyDetection/report_problem_2_4.md`
- optional helper: `utilities/run_energy_detector.m`

Recommended responsibilities:
- `main_problem_2_4.m`
  Loads saved energies and thresholds, applies the detector to the example channel and the six unknown channels, computes occupancy percentages, computes example-channel validation metrics, and saves a results structure.
- `generate_problem_2_4_report.m`
  Loads the saved results and creates a short markdown summary.
- `run_energy_detector.m` if added
  Applies the threshold comparison and returns the binary decision vector.

The helper should stay tiny if used. This is homework code, so clarity matters more than building a large abstraction layer.

## 7. Data Flow

Recommended Problem 2.4 flow:

1. Load `Problem_2_1_NoiseEstimation/problem_2_1_results.mat`.
2. Load `Problem_2_2_CFARThreshold/problem_2_2_results.mat`.
3. Load `data/hw12_test_data.mat` and read `example_channel_state_sequence`.
4. Read the example-channel timeslot energy and threshold.
5. Apply the decision rule to produce the example decision sequence.
6. Compare the example decisions against the truth sequence and compute agreement metrics.
7. Apply the same decision rule to each of the six saved channel energy vectors using the corresponding saved threshold.
8. Compute occupied and idle percentages for every channel.
9. Save the example results, six-channel results, and metadata into `Problem_2_4_EnergyDetection/problem_2_4_results.mat`.

Results that should be saved for later problems:
- full decision vectors
- occupancy percentages
- example truth and validation metrics
- detector metadata

## 8. Results Structure

Proposed saved structure in `Problem_2_4_EnergyDetection/problem_2_4_results.mat`:

- `results.example_channel.threshold`
- `results.example_channel.timeslot_energy`
- `results.example_channel.decisions`
- `results.example_channel.truth_sequence`
- `results.example_channel.percent_occupied`
- `results.example_channel.percent_idle`
- `results.example_channel.percent_agreement`
- `results.example_channel.true_positives`
- `results.example_channel.true_negatives`
- `results.example_channel.false_alarms`
- `results.example_channel.missed_detections`

- `results.channels(i).threshold`
- `results.channels(i).timeslot_energy`
- `results.channels(i).decisions`
- `results.channels(i).percent_occupied`
- `results.channels(i).percent_idle`

- `results.metadata.samples_per_timeslot`
- `results.metadata.measurement_length`
- `results.metadata.detector_statistic`
- `results.metadata.decision_rule`

Suggested metadata values:
- `detector_statistic = 'summed_timeslot_energy'`
- `decision_rule = 'occupied_if_timeslot_energy_greater_than_threshold'`

## 9. Live Lab Relevance

The live-lab files are only lightly relevant to Problem 2.4.

Recommended interpretation:
- the HMM live-lab material is mostly relevant to Problems 2.5 and 2.6
- the CNN / modulation-classification live-lab material is mostly relevant to Problem 2.8
- Problem 2.4 itself should remain a direct energy-thresholding exercise

The main connection is that the occupancy sequence produced here becomes the observed activity sequence that later HMM problems may use.

## 10. Validation / Sanity Checks

Recommended checks:
- each decision vector length should be 65536
- occupied percentage + idle percentage should equal 100%
- thresholds used in Problem 2.4 should match the saved values from Problem 2.2
- example truth length should match example decision length
- percent agreement should be reasonable and easy to interpret

Ambiguities to resolve before coding:
- whether equality at the threshold should count as occupied or idle
- whether percent agreement alone is enough for the example validation report or if confusion counts should also be shown

Recommended convention:
- use `timeslot_energy > threshold` for occupied
- treat equality as idle, which matches the strict detector rule already described

## 11. Continuity to Problems 2.5 and 2.6

The binary decision sequence produced here is the natural observation sequence for later HMM work.

That matters because:
- Problem 2.5 will likely need a channel activity sequence for training or estimating simple HMM behavior
- Problem 2.6 will likely need the same saved sequences for limiting-distribution or prediction analysis

Saving the full decision vectors now will reduce rework later and keep the later problems from having to repeat the thresholding step.
