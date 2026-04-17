# Problem 2.4 Energy Detection

## Objective
Apply the saved thresholds from Problem 2.2 to the saved timeslot energies from Problem 2.1 to determine whether each timeslot is occupied or idle.

## Detector Definition
The detector statistic is summed timeslot energy over one 10-sample timeslot.
The decision rule is `occupied if timeslot_energy > threshold`, and idle otherwise.

## Example Channel Validation
- Percent occupied: `36.8515%`
- Percent idle: `63.1485%`
- Percent agreement with truth: `96.6568%`
- True positives: `21960`
- True negatives: `41385`
- False alarms: `2191`
- Missed detections: `0`

## Occupied / Idle Percentages
| Channel | Percent Occupied | Percent Idle |
| --- | ---: | ---: |
| 1 | 79.6967 | 20.3033 |
| 2 | 52.5146 | 47.4854 |
| 3 | 14.5111 | 85.4889 |
| 4 | 63.4003 | 36.5997 |
| 5 | 51.7441 | 48.2559 |
| 6 | 9.5779 | 90.4221 |

## Continuity
The full binary decision vectors were saved in `problem_2_4_results.mat` so the later HMM-related problems can reuse the channel activity sequences directly.

