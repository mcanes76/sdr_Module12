# Execution Plan for Module 12 Extra Credit Problem 2.7

## 1. Goal

Implement Problem 2.7 so that it computes the probability of a length-4 idle window in two ways for the example channel and all six channels:
- directly from the Problem 2.4 detector decision sequences
- from the Markov model built in Problems 2.5 and 2.6

Then compare those two probabilities and save the results for reporting.

## 2. Development Order

Recommended build sequence:

1. Inspect the Problem 2.4 decision sequences.
2. Inspect the Problem 2.5 transition matrices and Problem 2.6 limiting distributions.
3. Lock the event definition and sliding-window counting rule.
4. Compute the example observed 4-idle probability.
5. Compute the example Markov-model 4-idle probability.
6. Compare the two example-channel values.
7. Extend the same calculations to all six channels.
8. Save results in a reusable `.mat` file.
9. Generate a short markdown report from the saved results.

## 3. Concrete Milestones

### Milestone 1: Inspect inputs and live-lab patterns

Confirm what Problem 2.7 will consume from:
- `Problem_2_4_EnergyDetection/problem_2_4_results.mat`
- `Problem_2_5_HMM/problem_2_5_results.mat`
- `Problem_2_6_IdlePrediction/problem_2_6_results.mat`
- the HMM / limiting-distribution live-lab material

Expected outcome:
- field names are known
- state and matrix conventions are confirmed
- the Markov probability formula is tied back to the earlier HMM work

### Milestone 2: Lock window-counting and state conventions

Decide and document:
- use sliding windows of length 4
- total candidate windows = `N - 3`
- idle means empty
- state 1 is idle in the Markov model
- `P11` means idle-to-idle transition probability

Expected outcome:
- no ambiguity remains in either the observation-based or Markov-model calculation

### Milestone 3: Implement observation-based 4-idle probability

Compute the fraction of length-4 sliding windows that are all idle in the example decision sequence.

Expected outcome:
- example observed probability is available
- window counting matches the overlap rule

### Milestone 4: Implement Markov-model 4-idle probability

Compute the example predicted probability using the steady-state chain formula.

Expected outcome:
- example predicted probability is available
- formula uses `pi_idle * P11^3`, not `(pi_idle)^4`

### Milestone 5: Compare example-channel results

Compare the observed and predicted example-channel values.

Expected outcome:
- example difference is easy to interpret
- reasons for mismatch are clear before scaling to all channels

### Milestone 6: Compute all six channels

Apply both calculations to all six channels.

Expected outcome:
- one observed probability and one predicted probability per channel
- a saved difference metric for each channel

### Milestone 7: Save results and prepare markdown report

Save the extra-credit outputs in a `.mat` file and generate a short markdown report.

Expected outcome:
- `problem_2_7_results.mat` is ready
- `report_problem_2_7.md` summarizes the observation vs Markov comparison

## 4. Review Gates

Recommended pause points for human review:

Review Gate A:
- After inspecting the saved inputs and confirming state conventions
- Confirm that idle is consistently treated as state 1 / empty

Review Gate B:
- After locking the Markov probability formula
- Confirm that the implementation uses `pi_idle * P11^3`

Review Gate C:
- After the example-channel comparison
- Confirm that the observed and predicted values look reasonable before scaling to all channels

Review Gate D:
- After all six channels are computed
- Confirm that quieter channels generally show larger 4-idle probabilities

## 5. Expected Artifacts

Files expected in the later implementation:
- `Problem_2_7_LongWhitespace/main_problem_2_7.m`
- `Problem_2_7_LongWhitespace/generate_problem_2_7_report.m`
- `Problem_2_7_LongWhitespace/report_problem_2_7.md`
- optionally `utilities/compute_long_whitespace_probability.m`
- `Problem_2_7_LongWhitespace/problem_2_7_results.mat`

These should be enough for the homework workflow. No extra structure is needed.

## 6. Planned Result Schema

Expected saved fields:

- `results.example_channel.observed_probability_4_idle`
- `results.example_channel.predicted_probability_4_idle`
- `results.example_channel.difference`

- `results.channels(i).observed_probability_4_idle`
- `results.channels(i).predicted_probability_4_idle`
- `results.channels(i).difference`

- `results.metadata.window_length`
- `results.metadata.event_definition`
- `results.metadata.prediction_method`
- `results.metadata.state_definition`

## 7. Future Reuse

The long-whitespace probabilities give a more concrete measure of secondary-user opportunity than simple occupied / idle percentages alone.

They connect directly to channel access questions because a channel that often produces 4-slot idle windows may be more useful than a channel that is only slightly quieter on average but does not produce longer clean opportunities.
