# Execution Plan for Module 12 Problem 2.2

## 1. Goal

Implement Problem 2.2 so that it computes the energy-detector threshold for the example channel and all six unknown channels using the noise variance estimates already saved by Problem 2.1, validates the example threshold against the provided truth, and saves the results in a form that can be reused by Problems 2.3 and 2.4.

## 2. Development Order

Recommended build sequence:

1. Inspect the saved Problem 2.1 outputs and identify the exact fields that hold noise variance estimates and timeslot energies.
2. Lock the detector statistic convention before writing any threshold code.
3. Verify the threshold formula convention for complex noise with measurement length 10 and fixed assignment value `target_pfa = 0.05`.
4. Compute the example threshold first.
5. Validate that the achieved false alarm probability falls within 0.049 to 0.051.
6. Check the example threshold against `example_cfa_threshold` as a secondary consistency check.
7. Compute thresholds for the six unknown channels.
8. Save results in a compact `.mat` file.
9. Generate a short markdown report from the saved results.

The key decision early on is the statistic convention:
- Use summed timeslot energy over 10 samples.
- Keep that convention fixed everywhere afterward.

## 3. Concrete Milestones

### Milestone 1: Inspect inputs and saved outputs

Confirm what Problem 2.2 will consume from:
- `data/hw12_test_data.mat`
- `Problem_2_1_NoiseEstimation/problem_2_1_results.mat`

Expected outcome:
- exact field names are known
- the required example truth values are identified
- the saved timeslot energy format is understood
- the implementation plan assumes `target_pfa = 0.05` unless a dataset field is explicitly confirmed later

### Milestone 2: Lock the detector statistic convention

Decide and document:
- detector uses summed timeslot energy
- timeslot length = 10
- noise variance is treated as per complex sample
- threshold comes from the gamma / chi-square upper-tail model under `H0`
- planned threshold formula metadata is `gaminv(1-target_pfa,N,sigma2_hat)`

Expected outcome:
- no scaling ambiguity remains before implementation starts

### Milestone 3: Implement threshold calculation path

Create the cleanest path for threshold generation:
- either compute directly inside `main_problem_2_2.m`
- or use a tiny helper such as `utilities/compute_energy_threshold.m`

Expected outcome:
- one clear formula path exists for both example and six-channel calculations

### Milestone 4: Example-channel validation

Use the example noise variance estimate from Problem 2.1 to compute the threshold, then compare against `example_cfa_threshold`.
Use the example noise variance estimate from Problem 2.1 to compute the threshold, then check the achieved `Pfa` under the same model.

Expected outcome:
- achieved `Pfa` is confirmed to lie within 0.049 to 0.051
- threshold agreement with `example_cfa_threshold` is quantified as a secondary check

### Milestone 5: Six-channel threshold generation

Run the same threshold calculation on each of the six channel noise estimates.

Expected outcome:
- one threshold per channel
- simple sanity checks completed

### Milestone 6: Save results and prepare markdown report

Save a reusable results structure and create a short markdown summary.

Expected outcome:
- `problem_2_2_results.mat` is ready for later problems
- `report_problem_2_2.md` records formula assumptions and outputs

## 4. Review Gates

Recommended pause points for human review:

Review Gate A:
- After inspecting Problem 2.1 outputs
- Confirm that reusing saved noise variance estimates is the intended workflow

Review Gate B:
- After locking the detector statistic convention
- Confirm that summed energy over 10 samples is the agreed convention

Review Gate C:
- After matching the example threshold formula
- Confirm that the chosen gamma / chi-square scaling produces achieved `Pfa` inside 0.049 to 0.051 before applying it to all channels

Review Gate D:
- After six-channel thresholds are computed
- Sanity-check threshold ordering and magnitudes before moving into Problems 2.3 and 2.4

## 5. Expected Artifacts

Files expected in the future implementation:
- `Problem_2_2_CFARThreshold/main_problem_2_2.m`
- `Problem_2_2_CFARThreshold/problem_2_2_results.mat`
- `Problem_2_2_CFARThreshold/report_problem_2_2.md`
- optionally `utilities/compute_energy_threshold.m`

These should be enough for the homework workflow. No extra framework or heavy structure is needed.

## 6. Planned Result Schema

Expected saved fields:

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

Helpful metadata text:
- `gaminv(1-target_pfa,N,sigma2_hat)`
- `summed_timeslot_energy`
- `per_complex_sample_variance`
- `gamma_equivalent_to_scaled_chi_square`

## 7. Future Reuse

Problem 2.3:
- will use the saved threshold values together with the same detector statistic to study probability of detection
- should not re-derive thresholds independently if Problem 2.2 already locked the scaling convention

Problem 2.4:
- will use each channel threshold directly for occupancy decisions on per-timeslot energies
- should reuse the timeslot energies from Problem 2.1 and the thresholds from Problem 2.2 without any extra scaling

Most important continuity rule:
- keep the detector statistic as summed timeslot energy everywhere so Problems 2.2, 2.3, and 2.4 stay consistent.
