# Problem 2.5 HMM Transition Matrix Estimation

## Objective
Estimate a two-state HMM transition matrix for the example channel and all six channels using the detector outputs saved in Problem 2.4.

## HMM Interpretation
The hidden states are `S1 = idle` and `S2 = occupied`.
The saved detector outputs from Problem 2.4 are treated as observations, not direct hidden-state labels.
That means the transition matrices reported here are inferred from detector observations through the HMM model.

## Observation / State Definitions
- State definition: `S1_idle_S2_occupied`
- Observation definition: `O1_idle_detector_output_O2_occupied_detector_output`
- Transition matrix orientation: `rows_current_state_columns_next_state`

## Example Channel
### Transition Matrix
```text
0.751844 0.248156
0.486193 0.513807
```
### Emission Matrix
```text
0.943933 0.056067
0.019331 0.980669
```

## Transition Matrix Results for Channels 1-6
### Channel 1
```text
0.285031 0.714969
0.216852 0.783148
```
### Channel 2
```text
0.152367 0.847633
0.846649 0.153351
```
### Channel 3
```text
0.819179 0.180821
0.820401 0.179599
```
### Channel 4
```text
0.379896 0.620104
0.379093 0.620907
```
### Channel 5
```text
0.197591 0.802409
0.802133 0.197867
```
### Channel 6
```text
0.864992 0.135008
0.856235 0.143765
```

## Emission Initialization Note
The initial emission matrix was estimated from the example-channel detector behavior in Problem 2.4, with a simple diagonally dominant fallback kept in reserve for stability.

