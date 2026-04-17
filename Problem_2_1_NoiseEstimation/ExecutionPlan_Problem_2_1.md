# Execution Plan: Module 12 Problem 2.1

## 1. Execution Goal
Implement Problem 2.1 later using the Module 11 MDL eigenvalue estimator as the primary noise-variance algorithm, while also saving timeslot energies for downstream energy-detection problems. The work should preserve a strict separation between:

- MDL noise estimation for Problem 2.1,
- timeslot-energy preparation for Problems 2.2 to 2.4.

## 2. Development Order
Recommended build order:

1. Confirm the Module 12 MAT-file variables and dimensions.
2. Create the problem-per-directory scaffolding plus shared `utilities`.
3. Bring forward the Module 11 MDL estimator components into `utilities`.
4. Define the Problem 2.1 driver and results schema.
5. Define the shared timeslot-energy helpers for later problems.
6. Validate the example-channel MDL estimate against truth.
7. Run the MDL estimator across the six unknown channels.
8. Save both MDL outputs and timeslot energies for reuse.

This order keeps the primary estimator aligned with the assignment while still preparing the later energy-detection pipeline.

## 3. Concrete Milestones
### Milestone 1: Data inspection
Inspect the Module 12 data file and confirm:

- exact variable names,
- orientation of `channelized_samples`,
- shape of `example_channel_samples`,
- shape and indexing of `example_channel_state_sequence`,
- consistency of the 10-sample timeslot assumption for downstream work.

Review gate:

- stop after data inspection if the stored variable names or shapes differ from the expected contract.

### Milestone 2: Repository structure setup
Adopt the required Module 12 layout:

- `data/`
- `utilities/`
- `Problem_2_1_NoiseEstimation/`
- `Problem_2_2_CFARThreshold/`
- `Problem_2_3_ProbabilityDetection/`
- `Problem_2_4_EnergyDetection/`
- `Problem_2_5_HMM_Estimation/`
- `Problem_2_6_IdleProbabilityPrediction/`
- `Problem_2_7_LongWhitespace/`
- `Problem_2_8_ModulationClassifier/`

Review gate:

- confirm that shared helpers truly belong in `utilities` and not inside a single problem folder.

### Milestone 3: Reuse Module 11 MDL components
Prepare the shared MDL pieces in `utilities` by reusing the Module 11 Problem 2.3 design:

- `EstimateNoiseMDL`
- `calcKMin`
- covariance construction flow
- eigenvalue sorting flow
- MDL curve evaluation flow

At this stage, only the architecture and interface contracts are fixed; MATLAB implementation comes later.

Review gate:

- confirm the reused components match the assignment intent before wiring them into the driver.

### Milestone 4: Define Problem 2.1 driver behavior
Specify `Problem_2_1_NoiseEstimation/main_problem_2_1.m` responsibilities:

- load data,
- run MDL noise estimation on the example channel,
- compute relative error versus `example_channel_noise_power`,
- run MDL noise estimation on all six unknown channels,
- compute timeslot energies for all channels,
- save a downstream-friendly results package,
- produce report-ready summaries.

Review gate:

- confirm the driver stays thin and pushes shared logic into `utilities`.

### Milestone 5: Define the downstream energy-preparation path
Specify the shared helpers:

- `reshape_timeslots`
- `compute_timeslot_energy`

These helpers exist in Problem 2.1 so later problems do not recompute the same slot-energy inputs. They are not part of the Problem 2.1 noise estimator.

Review gate:

- confirm the documentation clearly separates this path from MDL noise estimation.

### Milestone 6: Example-channel validation design
Specify the validation outputs for the example channel:

- MDL noise estimate,
- truth noise variance,
- relative error,
- pass/fail against 5%.

Recommended diagnostics:

- sorted eigenvalues,
- MDL curve,
- selected `k`,
- observation count and length.

Review gate:

- stop if the validation section does not make the 5% requirement explicit.

### Milestone 7: Six-channel run design
Specify the production outputs for the six unknown channels:

- one MDL noise estimate per channel,
- associated MDL metadata,
- stored timeslot energies for later thresholding and occupancy detection.

Review gate:

- confirm there is no dependency on truth labels outside the example-channel validation step.

## 4. Pipeline Definitions to Preserve
### Pipeline A: Noise Estimation

```text
raw samples
    ->
EstimateNoiseMDL
    ->
noise_variance_per_channel
```

Detailed internal flow for `EstimateNoiseMDL`:

1. reshape samples into observation vectors,
2. compute covariance matrix,
3. compute eigenvalues,
4. sort eigenvalues,
5. evaluate MDL,
6. estimate signal-subspace dimension `k`,
7. compute `mean(lambda(k+1:end))`.

### Pipeline B: Energy Detection Preparation

```text
raw samples
    ->
reshape_timeslots
    ->
compute_timeslot_energy
    ->
thresholding (Problem 2.2)
    ->
occupancy detection (Problem 2.4)
```

Pipeline B is prepared during Problem 2.1 but used later.

## 5. Expected Artifacts
When implementation begins, the planned files are:

- `sdr_Module12/data/module12_data.mat`
- `sdr_Module12/utilities/EstimateNoiseMDL.m`
- `sdr_Module12/utilities/calcKMin.m`
- `sdr_Module12/utilities/reshape_timeslots.m`
- `sdr_Module12/utilities/compute_timeslot_energy.m`
- `sdr_Module12/Problem_2_1_NoiseEstimation/main_problem_2_1.m`
- `sdr_Module12/Problem_2_1_NoiseEstimation/report_problem_2_1.md`

Later problems will add their own `main_problem_2_x.m` driver and report inside their own folder.

## 6. Results Schema to Plan For
Problem 2.1 should save a structured results package containing at least:

- `example_channel.noise_variance_estimate`
- `example_channel.noise_variance_truth`
- `example_channel.relative_error`
- `example_channel.mdl`
- `example_channel.timeslot_energy`
- `channels(i).noise_variance_estimate`
- `channels(i).mdl`
- `channels(i).timeslot_energy`
- `metadata.samples_per_timeslot`
- `metadata.mdl_observation_length`

This schema supports both immediate grading needs and downstream reuse.

## 7. Module 11 Reuse Notes
The Module 11 code inspection showed that the reusable MDL flow already exists and should be treated as the baseline reference for Problem 2.1. The following are intended to carry over directly in concept:

- observation-vector reshape before covariance construction,
- covariance estimate from stacked observations,
- eigenvalue extraction and descending sort,
- MDL objective evaluation through `calcKMin`,
- noise estimate from the trailing eigenvalue mean.

What does not carry over from Module 11:

- the old repository layout,
- the single-problem-local helper placement,
- the assumption that only the noise estimate matters.

Module 12 additionally needs stored timeslot energies for later stages.

## 8. Review Gates
The work should pause for review at these points once coding starts:

- after data inspection,
- after finalizing the shared `utilities` contracts,
- after defining the Problem 2.1 results schema,
- after example-channel validation,
- after the six-channel results packaging is defined.

These review gates protect against the main failure mode here: drifting back into a timeslot-energy noise estimator instead of the required MDL estimator.

## 9. Explicit Non-Goals for Problem 2.1
Problem 2.1 should not:

- use idle-slot timeslot energy as the primary noise estimator,
- merge the MDL and energy pipelines into one estimator,
- define CFAR thresholding logic yet,
- define occupancy detection logic yet,
- implement HMM estimation or prediction logic yet.

Those belong to later problems even though Problem 2.1 prepares shared inputs for them.
