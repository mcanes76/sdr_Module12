# Execution Plan for Module 12 Problem 2.4

## 1. Goal

Implement Problem 2.4 so that it applies the saved energy-detector thresholds to the saved timeslot energies, generates a binary occupancy decision sequence for the example channel and all six unknown channels, computes occupied and idle percentages, validates the example sequence against truth, and saves results for reuse in Problems 2.5 and 2.6.

## 2. Development Order

Recommended build sequence:

1. Inspect the saved timeslot energies from Problem 2.1.
2. Inspect the saved thresholds from Problem 2.2.
3. Inspect the example truth sequence format and length from the dataset.
4. Lock the detector statistic and decision rule.
5. Compute example-channel decisions.
6. Validate the example decisions against truth.
7. Compute six-channel decisions.
8. Compute occupied and idle percentages.
9. Save results in a reusable `.mat` file.
10. Generate a short markdown report from the saved results.

## 3. Concrete Milestones

### Milestone 1: Inspect inputs

Confirm what Problem 2.4 will consume from:
- `Problem_2_1_NoiseEstimation/problem_2_1_results.mat`
- `Problem_2_2_CFARThreshold/problem_2_2_results.mat`
- `data/hw12_test_data.mat`

Expected outcome:
- exact field names are known
- timeslot energy lengths are confirmed
- example truth sequence format is understood

### Milestone 2: Lock detector and decision convention

Decide and document:
- detector statistic is summed timeslot energy over 10 samples
- decision rule is `timeslot_energy > threshold`
- occupied maps to `1`
- idle maps to `0`

Expected outcome:
- no ambiguity remains in how the detector output is formed

### Milestone 3: Implement example-channel detection

Apply the saved example threshold to the saved example timeslot energies and create the example binary decision vector.

Expected outcome:
- example decision vector is created
- occupied and idle percentages are computed

### Milestone 4: Example validation against truth

Compare the example decision sequence to `example_channel_state_sequence`.

Expected outcome:
- percent agreement is computed
- optional confusion-style counts are computed
- vector-length consistency is checked

### Milestone 5: Six-channel detection and percentages

Apply each saved threshold to the matching saved channel energy vector.

Expected outcome:
- one binary decision vector per channel
- occupied and idle percentages for all six channels

### Milestone 6: Save results and prepare markdown report

Save the full decision outputs in a `.mat` file and generate a short markdown report.

Expected outcome:
- `problem_2_4_results.mat` is ready for later problems
- `report_problem_2_4.md` captures the main detector outputs and example validation

## 4. Review Gates

Recommended pause points for human review:

Review Gate A:
- After inspecting the saved inputs
- Confirm that Problem 2.4 should fully reuse the saved timeslot energies and thresholds

Review Gate B:
- After locking the decision rule
- Confirm that strict `>` is the intended occupied decision rule

Review Gate C:
- After example-channel validation
- Confirm that the agreement metric is useful and the detector behavior looks reasonable before processing all channels

Review Gate D:
- After six-channel decisions are produced
- Confirm that the occupied / idle percentages make sense before continuing to HMM-related problems

## 5. Expected Artifacts

Files expected in the later implementation:
- `Problem_2_4_EnergyDetection/main_problem_2_4.m`
- `Problem_2_4_EnergyDetection/generate_problem_2_4_report.m`
- `Problem_2_4_EnergyDetection/report_problem_2_4.md`
- optionally `utilities/run_energy_detector.m`
- `Problem_2_4_EnergyDetection/problem_2_4_results.mat`

These should be enough for the homework workflow. No extra structure is needed.

## 6. Planned Result Schema

Expected saved fields:

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

## 7. Future Reuse

Problem 2.5:
- will likely use the saved binary decision sequences as the observed activity data for HMM-related analysis
- should not need to rerun the energy detector if Problem 2.4 saves the full sequences

Problem 2.6:
- will likely reuse the same sequences for limiting-distribution or prediction work
- will benefit from having the full channel decision vectors already saved

Most important continuity rule:
- save the full decision sequences, not just the percentages, so later HMM problems can build directly on the Problem 2.4 outputs.
