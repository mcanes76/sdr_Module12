# Problem 2.1 Noise Estimation

## Objective
Estimate the noise variance in the provided captures using the MDL eigenvalue noise estimator from lecture and the Wireless Coexistence paper. The example channel is validated against the provided ground-truth noise power, and the same estimator is then applied to the six unknown channels.

## MDL Estimator Summary
The estimator reshapes the capture into 10-sample observations, forms a sample covariance matrix, computes and sorts the covariance eigenvalues, and uses the MDL criterion to choose the signal-subspace dimension. The noise variance estimate is the mean of the trailing eigenvalues beyond the selected signal subspace.

## Example Channel Validation
- Estimated noise variance: `0.315746968375`
- Ground-truth noise variance: `0.316227766017`
- Relative error: `|estimate - truth| / |truth| = 0.00152042` (0.1520%)
- Meets 5% requirement: `Yes`

## Six Unknown Channel Noise Estimates
| Channel | Estimated Noise Variance |
| --- | ---: |
| 1 | 0.199687919633 |
| 2 | 0.316107506737 |
| 3 | 0.251593606238 |
| 4 | 0.794220689995 |
| 5 | 0.500708822246 |
| 6 | 0.631326269422 |

## Downstream Data
Timeslot energies were computed with `samples_per_timeslot = 10` for the example channel and each of the six unknown channels, then saved into `problem_2_1_results.mat` for later problems. These energies were not used as the Problem 2.1 noise estimator.

