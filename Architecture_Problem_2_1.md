# Architecture: Module 12 Problem 2.1

## 1. Purpose
Problem 2.1 estimates noise variance for the example channel and the six unknown channels in Module 12. The primary estimator must be the covariance-eigenvalue MDL method used in Module 11 Problem 2.3, because the assignment explicitly points to the lecture and `Wireless Coexistence` noise-variance algorithm.

Problem 2.1 also needs to prepare reusable timeslot-energy data for later problems, but timeslot energy is not the noise estimator in this problem. The architecture therefore separates:

- Pipeline A: MDL-based noise estimation for Problem 2.1.
- Pipeline B: timeslot-energy preparation for Problems 2.2 to 2.4.

## 2. Required Repository Structure
Module 12 should use one subfolder per problem, with shared helpers in a common `utilities` folder:

```text
sdr_Module12/
    data/
        module12_data.mat

    utilities/
        reshape_timeslots.m
        compute_timeslot_energy.m
        EstimateNoiseMDL.m
        calcKMin.m

    Problem_2_1_NoiseEstimation/
        main_problem_2_1.m
        report_problem_2_1.md

    Problem_2_2_CFARThreshold/
        main_problem_2_2.m

    Problem_2_3_ProbabilityDetection/
        main_problem_2_3.m

    Problem_2_4_EnergyDetection/
        main_problem_2_4.m

    Problem_2_5_HMM_Estimation/
        main_problem_2_5.m

    Problem_2_6_IdleProbabilityPrediction/
        main_problem_2_6.m

    Problem_2_7_LongWhitespace/
        main_problem_2_7.m

    Problem_2_8_ModulationClassifier/
        main_problem_2_8.m
```

Each problem folder owns its driver script and report. Shared signal-processing logic stays in `utilities`.

## 3. Data Interpretation
Expected Module 12 data items:

- `example_channel_samples`
- `example_channel_noise_power`
- `example_channel_state_sequence`
- `channelized_samples`

Assumptions to confirm during implementation:

- channels are stored as columns,
- timeslot length is `10` samples for downstream energy detection,
- the example truth sequence aligns with those 10-sample timeslots,
- samples may be complex, so energy uses `abs(x).^2`.

These assumptions affect Pipeline B directly, but they do not replace the MDL estimator required for Pipeline A.

## 4. Primary Algorithm for Problem 2.1
The primary noise estimator is the MDL eigenvalue method reused from Module 11 Problem 2.3.

### Required process
For each channel:

1. reshape samples into observation vectors,
2. compute the sample covariance matrix,
3. compute covariance eigenvalues,
4. sort eigenvalues in descending order,
5. evaluate the MDL criterion,
6. estimate the signal-subspace dimension `k`,
7. estimate noise variance from the trailing eigenvalues.

### Noise estimate formula

```text
noise_variance = mean(lambda(k+1:end))
```

where `lambda` is the sorted eigenvalue vector and `k` is the MDL-selected signal-subspace dimension.

### What is explicitly not allowed as the primary estimator
Timeslot-energy idle-slot methods must not be used to estimate noise variance in Problem 2.1. Those methods belong to later problems and should only appear here as preparatory data products for reuse.

## 5. Explicit Reuse from Module 11
Problem 2.1 should explicitly reuse the following Module 11 components and logic:

- `EstimateNoiseMDL`
- `calcKMin`
- observation-vector reshaping for covariance construction
- covariance matrix construction
- eigenvalue computation and descending sort
- MDL curve evaluation

The inspected Module 11 implementation already follows the required flow:

- reshape capture into fixed-length observations,
- subtract per-row mean before covariance construction,
- compute covariance with observation snapshots,
- compute and sort eigenvalues,
- run `calcKMin`,
- average `lambda(k+1:end)`.

What changes in Module 12:

- the driver script must process the example channel plus six unknown channels,
- the repository layout moves shared helpers into `utilities`,
- Problem 2.1 must also precompute timeslot energies for later problems.

## 6. Pipeline Separation
The architecture must keep two separate pipelines with different purposes.

### Pipeline A: Noise Estimation

```text
raw samples
    ->
EstimateNoiseMDL
    ->
noise_variance_per_channel
```

This is the authoritative Problem 2.1 estimation path.

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

Problem 2.1 should still compute and store timeslot energies so later problems do not recompute them, but those energies are not used to produce the Problem 2.1 noise estimate.

## 7. Proposed Software Architecture
### `utilities/EstimateNoiseMDL.m`
Purpose: shared MDL-based noise estimator reused from Module 11, adapted only as needed for Module 12 naming and packaging.

Inputs:

- one channel sample vector,
- optional observation-length configuration.

Outputs:

- scalar `noise_variance`,
- metadata structure containing at least:
  - observation length,
  - number of observations,
  - covariance dimensions,
  - sorted eigenvalues,
  - MDL objective values,
  - selected `k`.

### `utilities/calcKMin.m`
Purpose: shared MDL helper reused from Module 11 to evaluate the MDL curve and return the minimizing `k`.

### `utilities/reshape_timeslots.m`
Purpose: reshape one channel into 10-sample timeslots for downstream energy-detection work.

Outputs:

- timeslot matrix,
- number of complete timeslots used,
- truncation metadata if needed.

### `utilities/compute_timeslot_energy.m`
Purpose: compute per-timeslot energy for later thresholding and occupancy detection.

Outputs:

- per-timeslot energy vector,
- any chosen normalization metadata.

### `Problem_2_1_NoiseEstimation/main_problem_2_1.m`
Purpose: thin driver for Problem 2.1.

Responsibilities:

- load Module 12 data,
- run `EstimateNoiseMDL` on the example channel,
- compare against `example_channel_noise_power`,
- run `EstimateNoiseMDL` on each unknown channel,
- compute timeslot energies for the example channel and each unknown channel,
- save a results package for downstream problems,
- generate report-ready summaries.

### `Problem_2_1_NoiseEstimation/report_problem_2_1.md`
Purpose: document the MDL estimator, example-channel validation, and six-channel results while also noting that timeslot energies were stored for later reuse.

## 8. Data Flow
Recommended Problem 2.1 flow:

1. Load Module 12 data from `data/module12_data.mat`.
2. Extract `example_channel_samples` and `channelized_samples`.
3. Run Pipeline A on the example channel:
   - reshape into observation vectors,
   - build covariance,
   - compute and sort eigenvalues,
   - evaluate MDL,
   - select `k`,
   - estimate noise variance.
4. Compare the example estimate against `example_channel_noise_power`.
5. Run Pipeline A independently on each of the six channels.
6. Run Pipeline B on the example channel and all six channels:
   - reshape into 10-sample timeslots,
   - compute timeslot energies.
7. Save both outputs in one structured results package.

## 9. Outputs That Problem 2.1 Should Save
Problem 2.1 should save enough information for both immediate validation and downstream reuse.

Required saved outputs:

- example-channel MDL noise estimate,
- example-channel true noise power,
- example-channel relative error,
- six-channel MDL noise estimates,
- per-channel MDL metadata,
- example-channel timeslot energies,
- six-channel timeslot energies,
- samples-per-timeslot metadata,
- observation-length metadata used by MDL.

Downstream-facing intent:

- Problems 2.2 to 2.4 consume stored timeslot energies instead of recomputing them.
- Problems 2.2 and 2.3 consume the stored noise-variance estimates from the MDL pipeline.

## 10. Validation Strategy
Example-channel validation for Problem 2.1 should include:

- estimated noise variance from `EstimateNoiseMDL`,
- truth value `example_channel_noise_power`,
- relative error,
- explicit pass/fail against the 5% requirement.

Recommended diagnostics to save:

- sorted eigenvalue spectrum,
- MDL curve values,
- selected `k`,
- number of observations used,
- observation length used.

Timeslot-energy validation in Problem 2.1 is limited to consistency checks:

- confirm timeslot reshape dimensions,
- confirm energy vector length matches expected slot count,
- confirm saved energy format is ready for Problems 2.2 to 2.4.

## 11. Risks and Open Checks
- Confirm the exact Module 12 MAT-file variable names during implementation.
- Confirm the preferred MDL observation length for Module 12 if the homework specifies one; otherwise use the same design logic as Module 11.
- Confirm whether the Module 11 mean-removal step should be preserved exactly in Module 12.
- Confirm that saved timeslot energies use the same scaling convention needed by CFAR thresholding later.
- Keep the two pipelines separate in code and documentation so later energy-detection work does not accidentally replace the MDL estimator.
