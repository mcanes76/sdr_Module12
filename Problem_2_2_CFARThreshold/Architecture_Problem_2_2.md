# Architecture for Module 12 Problem 2.2

## 1. Purpose

Problem 2.2 computes the energy-detector threshold for each channel that achieves a target false alarm probability of 0.05. The threshold is channel-specific because each channel uses its own noise variance estimate.

This problem depends directly on Problem 2.1. The noise variance estimates produced in `Problem_2_1_NoiseEstimation/problem_2_1_results.mat` should be reused here instead of recomputing them from raw samples.

Problem 2.2 then feeds later work in two directions:
- Problem 2.3 will use the threshold together with the channel energy statistic to estimate probability of detection.
- Problem 2.4 will use the threshold to convert each timeslot energy into an occupied / idle decision.

## 2. Inputs and Dependencies

Inputs from the homework dataset in `data/hw12_test_data.mat`:
- `example_cfa_threshold`
- `example_channel_samples` only if needed for checking consistency with saved timeslot energies
- `channelized_samples` only if needed for bookkeeping or optional checks

Default assignment value to use in Problem 2.2 planning:
- `target_pfa = 0.05`

Inputs from `Problem_2_1_NoiseEstimation/problem_2_1_results.mat`:
- `results.example_channel.noise_variance_estimate`
- `results.example_channel.timeslot_energy`
- `results.channels(i).noise_variance_estimate`
- `results.channels(i).timeslot_energy`
- `results.metadata.samples_per_timeslot`

Existing reusable utilities:
- `EstimateNoiseMDL.m` and `calcKMin.m` already served Problem 2.1 and should not be needed again if Problem 2.2 fully reuses saved results.
- `reshape_timeslots.m` and `compute_timeslot_energy.m` are also likely not needed if Problem 2.2 trusts the saved timeslot energies from Problem 2.1.

Recommended new helper:
- A small helper such as `utilities/compute_energy_threshold.m` is recommended.
- This keeps the threshold formula in one place and makes Problems 2.3 and 2.4 less error-prone.

## 3. Detection Statistic Definition

The detector statistic should be the summed timeslot energy over 10 complex samples:

$$
T = \sum_{n=1}^{10} |x[n]|^2
$$

Recommended convention:
- Use summed energy, not average energy.

Why this convention is better here:
- `compute_timeslot_energy.m` already naturally returns summed column energy.
- The homework language describes an energy detector over a measurement window, which matches a summed-energy statistic more directly.
- The threshold theory based on chi-square / gamma scaling is cleaner when written for the sum of squared magnitudes.
- Problems 2.3 and 2.4 can reuse the exact same statistic without extra rescaling.

If average energy were used instead, the threshold would just be the summed-energy threshold divided by 10. That is valid mathematically, but it creates an unnecessary second convention. The module should keep one convention fixed everywhere, and summed timeslot energy is the simpler choice.

## 4. Threshold Theory

Under noise-only conditions, each complex sample can be written as:

$w = w_I + j w_Q$

where $w_I$ and $w_Q$ are independent zero-mean Gaussian random variables. If the total complex noise variance per sample is `sigma2`, then each real component has variance:

$var(w_I) = var(w_Q) = \sigma^2 / 2$

For one complex sample:

$|w|^2 = w_I^2 + w_Q^2$

For a timeslot of length `N = 10`, the summed energy statistic is:

$$
T = \sum_{n=1}^{N} |w[n]|^2
$$

After normalizing by the real-component variance, the statistic maps to a chi-square law with `2N` degrees of freedom because there are two independent Gaussian components per complex sample. Equivalently, `T` can be viewed as gamma-distributed with shape `N` and scale `sigma2`.

Recommended interpretation for implementation:
- Treat `T` as a gamma random variable under `H0` with:
- shape = `N`
- scale = `sigma2`

Then the threshold `lambda` is chosen so that:

$P(T > \lambda | H0) = P_{fa} = 0.05$

Equivalently:

$\lambda = gaminv(1 - P_{fa}, N, \sigma^2)$

This is the same statement as using the upper-tail chi-square relationship after the correct complex-noise scaling is applied.

How Problem 2.1 enters:
- Problem 2.1 provides `sigma2_hat`, the estimated noise variance per complex sample for each channel.
- Problem 2.2 plugs `sigma2_hat` into the threshold expression.
- For the example channel, the computed threshold should be compared against `example_cfa_threshold`.

Important scaling point:
- This architecture assumes the Problem 2.1 noise estimate is per complex sample.
- This architecture also assumes the detector statistic is summed timeslot energy over 10 samples.
- With those two conventions fixed, the gamma scale parameter is the per-complex-sample noise variance estimate.

## 5. Proposed Software Architecture

Keep Problem 2.2 simple and aligned with the rest of the homework.

Recommended files:
- `Problem_2_2_CFARThreshold/main_problem_2_2.m`
- `Problem_2_2_CFARThreshold/problem_2_2_results.mat`
- `Problem_2_2_CFARThreshold/report_problem_2_2.md`
- optional helper: `utilities/compute_energy_threshold.m`

Recommended responsibilities:
- `main_problem_2_2.m`
  Loads Problem 2.1 results and the dataset, computes the example threshold, validates against the provided truth, computes thresholds for the six channels, and saves a compact results structure.
- `report_problem_2_2.md`
  Summarizes the detector convention, formula assumptions, example validation, and six-channel threshold values.
- `compute_energy_threshold.m` if added
  Inputs:
  - `noise_variance_estimate`
  - `measurement_length`
  - `target_pfa`
  Outputs:
  - `threshold_estimate`
  - optional small info struct with distribution parameters used

The helper should stay very small. This is homework code, so the goal is clarity, not abstraction for its own sake.

## 6. Data Flow

Recommended Problem 2.2 flow:

1. Load `Problem_2_1_NoiseEstimation/problem_2_1_results.mat`.
2. Load `data/hw12_test_data.mat`.
3. Read `samples_per_timeslot = 10` from Problem 2.1 metadata and set `measurement_length = 10`.
4. Read `target_pfa`, preferably from `desired_probability_of_false_alarm`, and confirm it equals 0.05.
4. Set `target_pfa = 0.05`.
5. Compute the example-channel threshold from the example noise variance estimate.
6. Verify that the achieved false alarm probability under the same gamma / chi-square model falls within 0.049 to 0.051.
7. Compare that threshold to `example_cfa_threshold` as a secondary consistency check.
8. Compute a threshold for each of the six unknown channels from its saved noise variance estimate.
9. Save thresholds and validation metrics into `Problem_2_2_CFARThreshold/problem_2_2_results.mat`.

Results that should be saved for later problems:
- Example threshold and validation metrics
- Six channel thresholds
- Metadata describing the detector convention and probability target

## 7. Results Structure

Proposed saved structure in `Problem_2_2_CFARThreshold/problem_2_2_results.mat`:

- `results.example_channel.threshold_estimate`
- `results.example_channel.threshold_truth`
- `results.example_channel.relative_error`
- `results.example_channel.pass_requirement`
- `results.example_channel.noise_variance_estimate`

- `results.channels(i).threshold_estimate`
- `results.channels(i).noise_variance_estimate`

- `results.metadata.samples_per_timeslot`
- `results.metadata.measurement_length`
- `results.metadata.target_pfa`
- `results.metadata.threshold_formula`
- `results.metadata.statistic_definition`
- `results.metadata.noise_variance_convention`
- `results.metadata.distribution_model`

Suggested metadata values:
- `threshold_formula = 'gaminv(1-target_pfa,N,sigma2_hat)'`
- `statistic_definition = 'summed_timeslot_energy'`
- `noise_variance_convention = 'per_complex_sample_variance'`
- `distribution_model = 'gamma_equivalent_to_scaled_chi_square'`

## 8. Validation Strategy

The main validation target is the achieved false alarm probability:
- Compute the threshold using the example noise variance estimate from Problem 2.1.
- Evaluate the achieved `Pfa` under the same gamma / chi-square model used to derive the threshold.
- Confirm that the achieved `Pfa` falls within 0.049 to 0.051.

Threshold agreement with `example_cfa_threshold` is still useful, but it is a secondary validation check. The primary requirement is that the achieved `Pfa` lands inside the allowed interval under the same model assumptions.

Recommended practical checks:
- Verify the threshold formula gives achieved `Pfa` inside 0.049 to 0.051 when evaluated back through the same gamma / chi-square model.
- Check that the example threshold is reasonably close to `example_cfa_threshold`.
- Check that all six thresholds are positive.
- Check that thresholds generally increase with estimated noise variance.
- Check that no threshold is wildly inconsistent with the corresponding channel noise estimate.

## 9. Module 12 Continuity

Problem 2.3 probability of detection:
- It will need the same energy statistic and the same threshold to compute or estimate `Pd`.
- Reusing the exact threshold values from Problem 2.2 avoids drift in scaling conventions.

Problem 2.4 energy detection occupancy decisions:
- It will compare each timeslot energy against the threshold for that channel.
- If Problem 2.2 fixes the convention as summed timeslot energy, Problem 2.4 can directly use the saved timeslot energies from Problem 2.1 with no extra scaling.

## 10. Risks / Open Checks

Main ambiguities to settle before coding:
- Whether the detector statistic is summed energy or average energy
- Whether the Problem 2.1 noise estimate should be interpreted as variance per complex sample
- Whether the implementation should use a gamma inverse CDF or an equivalent chi-square expression
- How closely the example threshold should match `example_cfa_threshold` once the achieved `Pfa` requirement is already satisfied

What should be verified before coding:
- Confirm the summed-energy convention is used everywhere in Module 12.
- Confirm `example_cfa_threshold` is expressed for the same statistic convention.
- Confirm the threshold formula uses `measurement_length = 10`.
- Confirm validation is centered on achieved `Pfa` in the interval 0.049 to 0.051.
- Confirm the saved timeslot energies from Problem 2.1 are also summed energies over 10 samples.

Small recommendation for the next step:
- Explicitly lock the detector convention to summed timeslot energy and keep that choice fixed in Problems 2.2, 2.3, and 2.4.
