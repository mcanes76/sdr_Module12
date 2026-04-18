# Problem 2.6 Limiting Distribution

## Limiting Distribution Explanation
The limiting distribution gives the long-term fraction of time that the two-state Markov chain spends in the idle and occupied states.
For this homework, the steady-state probabilities were computed from the Problem 2.5 transition matrices using the two-state closed-form formula.

## Example Channel Results
The predicted steady-state percentages are very close to the truth-derived percentages, indicating that the HMM transition matrix estimated in Problem 2.5 provides an accurate model of the channel dynamics.

| Quantity | Idle % | Occupied % |
| --- | ---: | ---: |
| Predicted | 66.2073 | 33.7927 |
| Observed | 63.1485 | 36.8515 |
| Truth | 66.4917 | 33.5083 |

## Six Channel Predictions
| Channel | Predicted Idle % | Predicted Occupied % | Observed Idle % | Observed Occupied % |
| --- | ---: | ---: | ---: | ---: |
| 1 | 23.2719 | 76.7281 | 20.3033 | 79.6967 |
| 2 | 49.9710 | 50.0290 | 47.4854 | 52.5146 |
| 3 | 81.9400 | 18.0600 | 85.4889 | 14.5111 |
| 4 | 37.9398 | 62.0602 | 36.5997 | 63.4003 |
| 5 | 49.9914 | 50.0086 | 48.2559 | 51.7441 |
| 6 | 86.3799 | 13.6201 | 90.4221 | 9.5779 |

## Quietest Channels
The two channels with the lowest predicted occupied probability are **Channel 6** and **Channel 3**.
Their predicted occupied percentages are `13.6201%` and `18.0600%`, so they look like the best choices for secondary access.

