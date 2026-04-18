# Architecture for Module 12 Extra Credit Problem 2.7

## 1. Purpose

Problem 2.7 asks for the probability of getting any string of 4 consecutive empty time slots in each channel.

This problem has two separate parts:
- observation-based whitespace probability from the detector output sequence
- Markov-model whitespace probability from the HMM transition matrix

That difference matters because:
- the observation-based result comes from actual finite detector decisions from Problem 2.4
- the Markov-model result comes from the fitted two-state model developed in Problems 2.5 and 2.6

Problem 2.7 extends Problems 2.4 through 2.6 by combining:
- the binary occupancy sequence from energy detection
- the HMM transition matrix
- the limiting / long-term occupancy interpretation

## 2. Inputs and Dependencies

Inputs from `Problem_2_4_EnergyDetection/problem_2_4_results.mat`:
- `results.example_channel.decisions`
- `results.channels(i).decisions`

Inputs from `Problem_2_5_HMM/problem_2_5_results.mat`:
- `results.example_channel.transition_matrix`
- `results.channels(i).transition_matrix`
- `results.metadata.transition_matrix_orientation`
- `results.metadata.state_definition`

Inputs from `Problem_2_6_IdlePrediction/problem_2_6_results.mat`:
- `results.example_channel.limiting_distribution`
- `results.channels(i).limiting_distribution`
- `results.metadata.state_definition`

Recommended new helper:
- an optional helper such as `utilities/compute_long_whitespace_probability.m` is reasonable
- if added, it should stay small and only handle one clear calculation path at a time

Possible helper usage:
- observation mode:
  - inputs: decision sequence, window length
  - output: observed probability of an all-idle window
- Markov mode:
  - inputs: limiting distribution, transition matrix, window length
  - output: predicted probability of an all-idle window

## 3. Definition of the Event

The event is:
- a length-4 sliding window in which all 4 time slots are empty / idle

This must be interpreted with overlapping windows.

For a sequence of length `N`, the number of candidate windows is:

`N - 3`

because each window has length 4.

Important counting rule:
- every consecutive 4-slot window is a valid observation
- this is not counting only disjoint runs

Example:
- if 5 consecutive slots are empty, then the length-4 windows are:
  - slots 1 to 4
  - slots 2 to 5
- so that 5-slot empty run contributes 2 successful windows

## 4. Observation-Based Probability

For the observation-based part, use the saved Problem 2.4 detector decision sequence.

State convention:
- idle / empty corresponds to detector output `0`
- occupied corresponds to detector output `1`

Recommended computation:
1. slide a 4-slot window across the decision vector
2. count how many windows are all idle
3. divide by the total number of windows `N - 3`

That gives:

`P_observed(4 idle) = number_of_all_idle_windows / (N - 3)`

Recommended implementation style:
- keep the logic straightforward and explicit
- either use a short loop over windows or a compact vectorized check
- prioritize readability over clever indexing

## 5. Markov-Model Probability

For the Markov-model part, use the two-state chain built in Problems 2.5 and 2.6.

State convention:
- `S1 = idle`
- `S2 = occupied`

Transition matrix orientation:
- rows = current state
- columns = next state

This is not an IID calculation, so the probability should not be:

$(\pi_idle)^4$

That would only be appropriate if each slot were independent.

Instead, under the steady-state Markov assumption:
- the first slot is idle with probability `pi_idle`
- the next three slots must each remain idle through the idle-to-idle transition

So the recommended formula is:

$P_{predicted}(4 idle) = \pi_{idle} * P_{11}^3$

where:
- $\pi_{idle}$ is the steady-state idle probability
- `P11` is the idle-to-idle transition probability

This can also be viewed as:
- choose a random slot in steady state
- require the chain to be in idle at that slot
- require three consecutive idle-to-idle transitions after that

Recommended implementation approach:
- use $\pi_{idle} * P_{11}^{(window_length - 1)}$ as the main formula
- for this homework, with window length 4, that becomes $\pi_{idle} * P_{11}^3`

Secondary interpretation / check:
- the same result can be viewed as a direct chain probability:
  - `P(S_k=idle, S_{k+1}=idle, S_{k+2}=idle, S_{k+3}=idle)`
- that agrees with the steady-state formula above

## 6. Comparison of Observation vs Prediction

Problem 2.7 should compare:
- observed probability of a 4-idle window from Problem 2.4
- predicted probability of a 4-idle window from the Markov model

These may differ for several reasons:
- detector false alarms and missed detections in Problem 2.4
- HMM transition matrix was inferred from detector outputs rather than hidden truth states
- finite sequence length in the observed data
- model mismatch between the fitted HMM and the actual channel process
- steady-state prediction versus finite observed sequence behavior

The report should frame these differences as expected modeling differences, not automatically as errors.

## 7. Live Lab Relevance

What is useful from the HMM / limiting-distribution live-lab material:
- the two-state state interpretation
- the row / column orientation of the transition matrix
- the steady-state / limiting-distribution view from the two-state Markov chain
- the link between transition probabilities and long-term occupancy

Most relevant concept for Problem 2.7:
- once the steady-state idle probability and idle-to-idle transition probability are known, short idle-string probabilities can be computed directly from the chain model

Useful conceptual reuse:
- state interpretation from the HMM scripts
- limiting-distribution reasoning from the limiting-distribution script and lab notes

Non-HMM live-lab files:
- `modulation_classification_confusion_matrix_experiment.m` and `modulation_classification_in_noise.m` are not relevant to Problem 2.7
- they are modulation-classification examples and fit much better with Problem 2.8

## 8. Proposed Software Architecture

Keep Problem 2.7 simple and aligned with the rest of the homework.

Recommended files:
- `Problem_2_7_LongWhitespace/main_problem_2_7.m`
- `Problem_2_7_LongWhitespace/generate_problem_2_7_report.m`
- `Problem_2_7_LongWhitespace/report_problem_2_7.md`
- optional helper: `utilities/compute_long_whitespace_probability.m`

Recommended responsibilities:
- `main_problem_2_7.m`
  Loads saved decision sequences, transition matrices, and limiting distributions; computes the observation-based and Markov-model 4-idle probabilities; compares them; and saves the results.
- `generate_problem_2_7_report.m`
  Loads the saved results and creates a short markdown summary.
- `compute_long_whitespace_probability.m` if added
  Handles either the sliding-window count or the Markov closed-form probability in a compact, readable way.

The helper should stay small if used. This is extra-credit homework code, so simple and readable is the priority.

## 9. Data Flow

Recommended Problem 2.7 flow:

1. Load `Problem_2_4_EnergyDetection/problem_2_4_results.mat`.
2. Load `Problem_2_5_HMM/problem_2_5_results.mat`.
3. Load `Problem_2_6_IdlePrediction/problem_2_6_results.mat`.
4. For the example channel, compute the observed probability of 4 consecutive idle slots from the saved decision sequence.
5. For the example channel, compute the predicted Markov-model probability using `pi_idle * P11^3`.
6. Compare the two example-channel values.
7. Repeat the same calculations for all six channels.
8. Save all results into `Problem_2_7_LongWhitespace/problem_2_7_results.mat`.

Results that should be saved:
- observed 4-idle probability
- predicted 4-idle probability
- difference between them
- metadata describing the event and prediction method

## 10. Results Structure

Proposed saved structure in `Problem_2_7_LongWhitespace/problem_2_7_results.mat`:

- `results.example_channel.observed_probability_4_idle`
- `results.example_channel.predicted_probability_4_idle`
- `results.example_channel.difference`

- `results.channels(i).observed_probability_4_idle`
- `results.channels(i).predicted_probability_4_idle`
- `results.channels(i).absolute_difference`
- `results.channels(i).relative_error`

- `results.metadata.window_length`
- `results.metadata.event_definition`
- `results.metadata.prediction_method`
- `results.metadata.state_definition`

Suggested metadata values:
- `window_length = 4`
- `event_definition = 'all_idle_sliding_window_of_length_4'`
- `prediction_method = 'steady_state_markov_probability_pi_idle_times_P11_power_3'`
- `state_definition = 'S1_idle_S2_occupied'`

## 11. Validation / Sanity Checks

Recommended checks:
- all probabilities are between 0 and 1
- observation-based counting uses exactly `N - 3` windows
- predicted 4-idle probability should generally be larger for quieter channels
- channels with lower long-term occupied probability should generally have larger 4-idle probability
- transition-matrix orientation and idle-state indexing match Problems 2.5 and 2.6

Important checks:
- do not accidentally use `(pi_idle)^4`
- do not accidentally use the occupied-to-occupied transition instead of `P11`
- do not accidentally count only disjoint idle runs in the observation-based part

## 12. Continuity

This extra-credit problem ties together:
- energy detection from Problem 2.4
- HMM transition estimation from Problem 2.5
- long-term occupancy prediction from Problem 2.6

It gives a more concrete channel-opportunity statistic for secondary access by asking how likely a useful multi-slot whitespace opportunity is under both observation and model-based views.
