# Problem 2.7 Long Whitespace Probability

## Objective
Compute the probability of a sliding length-4 all-idle window in two ways: directly from the Problem 2.4 detector outputs and from the Markov model built in Problems 2.5 and 2.6.

## Event Definition
The event is an overlapping sliding window of 4 consecutive idle time slots.
For a sequence of length `N`, there are `N-3` candidate windows.

## Example Channel
- Observed probability of 4 idle slots: `0.22796149`
- Predicted Markov-model probability: `0.28137685`
- Difference (observed - predicted): `-0.05341537`

## All Channels
| Channel | Observed P(4 idle) | Predicted P(4 idle) | Difference |
| --- | ---: | ---: | ---: |
| 1 | 0.00282301 | 0.00538902 | -0.00256602 |
| 2 | 0.00128180 | 0.00176761 | -0.00048581 |
| 3 | 0.53280027 | 0.45043588 | 0.08236439 |
| 4 | 0.01841820 | 0.02080124 | -0.00238304 |
| 5 | 0.00439473 | 0.00385654 | 0.00053819 |
| 6 | 0.66958632 | 0.55904692 | 0.11053939 |

## Why They May Differ
The observation-based probability comes from a finite detector output sequence, while the Markov-model probability comes from a steady-state chain approximation.
Differences can come from detector errors, HMM estimation through observations instead of hidden states, finite sample length, and mismatch between steady-state behavior and the measured sequence.

