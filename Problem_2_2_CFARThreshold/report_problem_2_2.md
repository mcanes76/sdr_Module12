# Problem 2.2 CFAR Threshold

## Objective
Compute the energy-detector threshold for each channel at `target_pfa = 0.05` while reusing the saved noise variance estimates from Problem 2.1 instead of recomputing them from raw data.

## Threshold Theory
The detector statistic is summed timeslot energy over 10 samples, not average energy.
Under the noise-only model, the summed complex-sample energy over one timeslot is treated as gamma distributed with shape `N = 10` and scale $\sigma^2$ per complex sample, implemented in MATLAB as `sigma2_hat`.
The threshold was computed with `gaminv(1-target_pfa,N,sigma2_hat)`.

## Example Channel Validation
- Threshold estimate: `4.95887447296`
- Threshold truth: `4.96642550398`
- Relative error vs truth: `0.00152042` (0.1520%)
- Achieved false alarm probability: `0.05000000`
- Passes required Pfa range [0.049, 0.051]: `Yes`

## Six Channel Threshold Table
| Channel | Noise Variance Estimate | Threshold Estimate |
| --- | ---: | ---: |
| 1 | 0.199687919633 | 3.13614199472 |
| 2 | 0.316107506737 | 4.96453680595 |
| 3 | 0.251593606238 | 3.95133203639 |
| 4 | 0.794220689995 | 12.4734078233 |
| 5 | 0.500708822246 | 7.86374041784 |
| 6 | 0.631326269422 | 9.91511569424 |

## Continuity
These thresholds are ready for Problem 2.3 probability-of-detection work and Problem 2.4 occupancy decisions.
Those later problems should reuse the same summed-timeslot-energy statistic and the same Problem 2.1 noise inputs so the scaling stays consistent.

