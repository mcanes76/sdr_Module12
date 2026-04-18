# Execution Plan for Module 12 Problem 2.6

## 1. Goal

Implement Problem 2.6 so that it uses the transition matrices estimated in Problem 2.5 to compute the limiting distribution for the example channel and all six channels, compares predicted long-term idle / occupied percentages against the observed percentages from Problem 2.4, uses the example truth sequence for validation, identifies the two quietest channels, and saves results for reporting.

## 2. Development Order

Recommended build sequence:

1. Inspect Problem 2.5 transition matrices.
2. Inspect Problem 2.4 observed occupancy percentages.
3. Inspect the live-lab limiting-distribution examples.
4. Lock the limiting-distribution method and matrix orientation.
5. Compute the example-channel steady-state probabilities.
6. Compare predicted vs observed / truth percentages for the example channel.
7. Compute steady-state probabilities for the six channels.
8. Identify the two quietest channels.
9. Save results in a reusable `.mat` file.
10. Generate a short markdown report from the saved results.

## 3. Concrete Milestones

### Milestone 1: Inspect inputs and live-lab patterns

Confirm what Problem 2.6 will consume from:
- `Problem_2_5_HMM/problem_2_5_results.mat`
- `Problem_2_4_EnergyDetection/problem_2_4_results.mat`
- the HMM / limiting-distribution live-lab scripts in `Lab12_files/`

Expected outcome:
- field names are known
- transition-matrix orientation is confirmed
- useful steady-state patterns from the live lab are identified

### Milestone 2: Lock matrix orientation and limiting-distribution formula

Decide and document:
- state order is `S1 = idle`, `S2 = occupied`
- rows are current state and columns are next state
- the main implementation uses the two-state closed form
- an optional matrix-based method can be used as a sanity check

Expected outcome:
- no ambiguity remains in how steady-state probabilities are computed

### Milestone 3: Implement example-channel limiting distribution

Compute the limiting distribution for the example transition matrix.

Expected outcome:
- example predicted idle / occupied probabilities are available
- the limiting distribution sums to 1

### Milestone 4: Compare predicted vs observed / truth percentages

Use the example observed percentages from Problem 2.4 and truth-derived percentages from the example truth sequence.

Expected outcome:
- example prediction accuracy is summarized in a simple way
- predicted vs observed differences are easy to interpret

### Milestone 5: Compute limiting distribution for six channels

Apply the same steady-state calculation to all six channel transition matrices.

Expected outcome:
- one limiting distribution per channel
- predicted idle / occupied percentages for every channel

### Milestone 6: Rank channels by occupied probability

Sort channels using predicted occupied probability.

Expected outcome:
- the two quietest channels are identified clearly

### Milestone 7: Save results and prepare markdown report

Save the limiting-distribution outputs in a `.mat` file and generate a short markdown report.

Expected outcome:
- `problem_2_6_results.mat` is ready
- `report_problem_2_6.md` captures the main prediction results

## 4. Review Gates

Recommended pause points for human review:

Review Gate A:
- After inspecting the saved inputs and the live-lab scripts
- Confirm that the matrix orientation and state ordering match Problem 2.5

Review Gate B:
- After locking the limiting-distribution formula
- Confirm that the two-state shortcut is being applied with the correct off-diagonal terms

Review Gate C:
- After the example-channel prediction
- Confirm that predicted vs observed / truth comparisons look reasonable before scaling to all channels

Review Gate D:
- After ranking the channels
- Confirm that the quietest-channel decision is based on predicted occupied probability, not just observed occupancy

## 5. Expected Artifacts

Files expected in the later implementation:
- `Problem_2_6_IdlePrediction/main_problem_2_6.m`
- `Problem_2_6_IdlePrediction/generate_problem_2_6_report.m`
- `Problem_2_6_IdlePrediction/report_problem_2_6.md`
- optionally `utilities/compute_limiting_distribution.m`
- `Problem_2_6_IdlePrediction/problem_2_6_results.mat`

These should be enough for the homework workflow. No extra structure is needed.

## 6. Planned Result Schema

Expected saved fields:

- `results.example_channel.transition_matrix`
- `results.example_channel.limiting_distribution`
- `results.example_channel.predicted_percent_idle`
- `results.example_channel.predicted_percent_occupied`
- `results.example_channel.observed_percent_idle`
- `results.example_channel.observed_percent_occupied`
- `results.example_channel.truth_percent_idle`
- `results.example_channel.truth_percent_occupied`
- `results.example_channel.predicted_minus_observed_idle_percent`
- `results.example_channel.predicted_minus_observed_occupied_percent`
- `results.example_channel.predicted_minus_truth_idle_percent`
- `results.example_channel.predicted_minus_truth_occupied_percent`

- `results.channels(i).transition_matrix`
- `results.channels(i).limiting_distribution`
- `results.channels(i).predicted_percent_idle`
- `results.channels(i).predicted_percent_occupied`
- `results.channels(i).observed_percent_idle`
- `results.channels(i).observed_percent_occupied`

- `results.summary.quietest_channel_indices`
- `results.summary.quietest_channel_predicted_occupied_percentages`

- `results.metadata.state_definition`
- `results.metadata.transition_matrix_orientation`
- `results.metadata.limiting_distribution_method`

## 7. Future Reuse

Problem 2.6 completes the channel-usage prediction part of the module.

After it is implemented, the project will have:
- observed occupancy from Problem 2.4
- HMM-estimated dynamics from Problem 2.5
- steady-state occupancy prediction from Problem 2.6

That gives the final HMM-based basis for discussing long-term channel availability and identifying good channels for secondary access.
