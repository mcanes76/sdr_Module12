# Architecture for Module 12 Problem 2.6

## 1. Purpose

Problem 2.6 uses the transition matrices estimated in Problem 2.5 to compute the limiting distribution for each channel.

This problem depends on:
- Problem 2.5 for the estimated HMM transition matrices
- Problem 2.4 for the observed occupied / idle percentages and detector decision sequences used for comparison

This is the step that connects the HMM-estimated channel dynamics to a long-term prediction of how often each channel will be idle or occupied.

## 2. Inputs and Dependencies

Inputs from `Problem_2_5_HMM/problem_2_5_results.mat`:
- `results.example_channel.transition_matrix`
- `results.channels(i).transition_matrix`
- `results.metadata.state_definition`
- `results.metadata.transition_matrix_orientation`

Inputs from `Problem_2_4_EnergyDetection/problem_2_4_results.mat`:
- `results.example_channel.percent_idle`
- `results.example_channel.percent_occupied`
- `results.channels(i).percent_idle`
- `results.channels(i).percent_occupied`
- `results.example_channel.truth_sequence`

Direct dataset usage:
- probably not necessary if the example truth sequence is already saved in Problem 2.4 results
- direct dataset access can stay optional and should only be used if an extra sanity check is needed

Example truth sequence usage:
- yes, it is useful for validation here
- it should be used to form truth-derived idle / occupied percentages for the example channel
- it should not replace the main HMM-based prediction flow

Recommended new helper:
- a small helper such as `utilities/compute_limiting_distribution.m` is reasonable
- it can keep the steady-state calculation in one place and make the main script easier to read

Recommended helper behavior if added:
- Inputs:
  - `transition_matrix`
- Outputs:
  - `limiting_distribution`
  - optional sanity-check result from a second method

## 3. Limiting Distribution Theory

For a two-state Markov chain, the limiting distribution is the steady-state probability vector:

`pi = [pi_idle, pi_occupied]`

It satisfies:

`pi = pi * A`

with:

`sum(pi) = 1`

In this problem:
- `pi_idle` is the long-term probability that the channel is idle
- `pi_occupied` is the long-term probability that the channel is occupied

These are the predicted long-term occupied / idle percentages implied by the estimated transition matrix.

If:

`A = [1-a, a;
      b, 1-b]`

then the two-state shortcut is:

`pi_idle = b / (a + b)`

`pi_occupied = a / (a + b)`

This is the same pattern used in the live-lab limiting-distribution script, where the long-term state probabilities are written directly from the off-diagonal transition probabilities.

Recommended implementation approach for this homework:
- use the direct two-state formula as the main method
- optionally use the linear-system or eigenvector method as a sanity check

Why this is the best fit here:
- it is simple
- it matches the live-lab pattern directly
- it is easy to explain in the report

## 4. Comparison to Problem 2.4 Observations

Problem 2.6 should compare:
- predicted idle / occupied percentages from the limiting distribution
- observed idle / occupied percentages from Problem 2.4

This comparison matters because the assignment asks whether the predicted percentages differ from what was measured by observing energy.

Reasons the two may differ:
- finite observation length rather than an infinite-time average
- detector false alarms and missed detections from Problem 2.4
- HMM transition matrices were inferred through detector observations, not direct hidden-state labels
- the observed sequence may reflect transient behavior, while the limiting distribution is a long-term steady-state prediction

This section should make clear that a difference is not automatically a mistake. It can be a natural consequence of the model and finite data.

## 5. Example-Channel Validation

The example channel has truth information available through the saved truth sequence from Problem 2.4.

Recommended validation quantities:
- predicted idle / occupied percentages from the limiting distribution
- observed idle / occupied percentages from Problem 2.4
- truth-derived idle / occupied percentages from the example truth sequence

Recommended interpretation of "accuracy of your prediction":
- compare the predicted steady-state percentages to the truth-derived percentages for the example channel
- also compare predicted percentages to the observed detector-based percentages

This keeps the validation simple and directly tied to the assignment wording.

## 6. Channel Ranking for Secondary User Access

The two quietest channels should be the channels with the smallest predicted occupied probability:

- lowest `pi_occupied`

These are the best candidates for secondary user access because the limiting distribution predicts they spend the smallest fraction of time in the occupied state.

This ranking should be based on the predicted long-term occupied probability, not just the finite observed occupancy from Problem 2.4.

## 7. Live Lab Relevance

What was found in the HMM / limiting-distribution live-lab scripts:

From `experiment_hmm_limiting_distribution.m`:
- the script uses a 2x2 transition matrix
- it computes the limiting distribution directly from the two off-diagonal probabilities
- it uses the same row / column convention as the earlier HMM work
- it directly connects transition probabilities to long-term state occupancy

From `experiment_training_a_hmm_model.m`:
- the script reinforces the same transition-matrix orientation
- it shows the distinction between observed emissions and hidden states
- it supports the idea that the transition matrix used here came from HMM estimation on observations

Useful concepts to reuse:
- direct two-state limiting-distribution formula
- row = current state, column = next state convention
- interpretation of long-term occupancy probabilities as state percentages

About the live-lab PDF:
- `SDR Live Lab 12.pdf` is part of the intended lab context, and its limiting-distribution material is relevant here
- the live-lab HMM discussion supports the same two-state closed-form formula used in this architecture
- the local HMM scripts still give the clearest concrete code patterns needed for Problem 2.6

Non-HMM live-lab files:
- `modulation_classification_confusion_matrix_experiment.m` and `modulation_classification_in_noise.m` are not relevant to Problem 2.6
- they are modulation-classification examples and fit much better with Problem 2.8

## 8. Proposed Software Architecture

Keep Problem 2.6 simple and aligned with the rest of the homework.

Recommended files:
- `Problem_2_6_IdlePrediction/main_problem_2_6.m`
- `Problem_2_6_IdlePrediction/generate_problem_2_6_report.m`
- `Problem_2_6_IdlePrediction/report_problem_2_6.md`
- optional helper: `utilities/compute_limiting_distribution.m`

Recommended responsibilities:
- `main_problem_2_6.m`
  Loads the transition matrices from Problem 2.5 and the observed occupancy summaries from Problem 2.4, computes limiting distributions, compares predicted vs observed percentages, computes example truth-based percentages, identifies the two quietest channels, and saves results.
- `generate_problem_2_6_report.m`
  Loads the saved results and creates a short markdown summary.
- `compute_limiting_distribution.m` if added
  Inputs:
  - `transition_matrix`
  Outputs:
  - `limiting_distribution`
  - optional check from the linear-system method

The helper should stay small if used. This is homework code, so clarity is more important than building a generic Markov toolbox.

## 9. Data Flow

Recommended Problem 2.6 flow:

1. Load `Problem_2_5_HMM/problem_2_5_results.mat`.
2. Load `Problem_2_4_EnergyDetection/problem_2_4_results.mat`.
3. Read the example-channel transition matrix and compute its limiting distribution.
4. Read the six channel transition matrices and compute their limiting distributions.
5. Convert each limiting distribution into predicted idle / occupied percentages.
6. Compare the predicted percentages to the observed percentages from Problem 2.4.
7. For the example channel, compute truth-derived idle / occupied percentages from the saved truth sequence.
8. Rank channels by predicted occupied probability and identify the two quietest channels.
9. Save all results into `Problem_2_6_IdlePrediction/problem_2_6_results.mat`.

Results that should be saved:
- transition matrices
- limiting distributions
- predicted percentages
- observed percentages
- example truth-based percentages
- quietest channel summary

## 10. Results Structure

Proposed saved structure in `Problem_2_6_IdlePrediction/problem_2_6_results.mat`:

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

Suggested metadata values:
- `state_definition = 'S1_idle_S2_occupied'`
- `transition_matrix_orientation = 'rows_current_state_columns_next_state'`
- `limiting_distribution_method = 'two_state_closed_form_with_optional_matrix_sanity_check'`

## 11. Validation / Sanity Checks

Recommended checks:
- each limiting distribution sums to 1
- predicted idle + predicted occupied = 100%
- quietest channel selection is based on predicted occupied probability
- transition-matrix orientation matches Problem 2.5
- if both methods are used, the direct two-state formula and the matrix method agree

Ambiguities to resolve before coding:
- whether to report absolute percentage differences between predicted and observed values
- whether the example truth comparison should be the main accuracy check or just one supporting check

Most important checks:
- do not accidentally flip the off-diagonal probabilities in the two-state formula
- do not accidentally swap idle and occupied state ordering

## 12. Continuity

Problem 2.6 completes the HMM-based channel-occupancy prediction path in this module.

After this step, the workflow has:
- detector-derived observations from Problem 2.4
- HMM-estimated transition matrices from Problem 2.5
- long-term predicted channel-usage probabilities from Problem 2.6

That gives a complete path from raw capture processing to long-term channel-availability prediction.
