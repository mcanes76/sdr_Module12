# Problem 2.3 Probability of Detection

## Problem Summary
This step computes the theoretical probability of detection for the energy detector using the saved noise variance estimates from Problem 2.1 and the saved thresholds from Problem 2.2.

## Equations Used
The Marcum-Q formulation from the assignment was used:
`P_D = Q_K(sqrt(Es)/sigma_n, sqrt(eta)/sigma_n)`
`P_MD = 1 - P_D`

## Parameters
- `K = 10` complex samples per measurement
- `Es = K * signal_power = 10` with `signal_power = 1`
- `sigma_n^2` came from Problem 2.1
- `eta` came from Problem 2.2

## Computed P_D Values
| Channel | Noise Variance | Threshold | P_D |
| --- | ---: | ---: | ---: |
| 1 | 0.199687919633 | 3.13614199472 | 0.999999518542 |
| 2 | 0.316107506737 | 4.96453680595 | 0.999881327354 |
| 3 | 0.251593606238 | 3.95133203639 | 0.999988828434 |
| 4 | 0.794220689995 | 12.4734078233 | 0.981808766435 |
| 5 | 0.500708822246 | 7.86374041784 | 0.997128113403 |
| 6 | 0.631326269422 | 9.91511569424 | 0.991769212568 |

## Plot
The bar chart below shows all 6 channels.
![Energy Detector Probability of Detection](probability_detection_bar.png)

