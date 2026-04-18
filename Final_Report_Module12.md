# Module 12 Final Report

## 1. Introduction

This module pulled together several ideas that build on each other. It started with estimating the noise variance in the captures, then used that estimate to build a CFAR-style energy detector threshold, then used the threshold to study probability of detection and actual time-slot occupancy. After that, the occupancy sequence was used as the observed sequence for a two-state HMM, which made it possible to estimate transition matrices and then compute limiting distributions for long-term channel usage. The extra-credit parts extended that same chain of ideas to long whitespace opportunities and to a pretrained modulation classifier tested across SNR.

What I liked about this module is that the problems connected in a very natural way. Problem 2.1 produced the noise estimates and timeslot energies, Problems 2.2 through 2.4 turned those into detection and occupancy results, Problems 2.5 and 2.6 turned the occupancy sequence into a Markov model and long-term prediction, and the extra-credit problems showed how those same results can be used to think about channel access opportunities and classifier robustness.

## 2. Problem 2.1 – Noise Estimation

The goal of Problem 2.1 was to estimate the noise variance in the example channel and the six unknown channels. The main requirement here was to reuse the MDL eigenvalue noise estimator from Module 11 instead of switching to a different estimator.

The basic idea was to reshape the capture into short observation vectors, build a sample covariance matrix, compute its eigenvalues, and then use the MDL criterion to decide where the signal subspace ends and the noise-only eigenvalues begin. Once that split is chosen, the noise variance estimate is the average of the trailing eigenvalues.

The main equations behind that idea are

$$
\mathbf{R} = \frac{1}{N}\mathbf{X}\mathbf{X}^H
$$

and

$$
\hat{\sigma}_n^2 = \frac{1}{L-k}\sum_{i=k+1}^{L}\lambda_i
$$

where $\lambda_i$ are the sorted covariance eigenvalues and $k$ is the MDL-selected signal-subspace dimension.

The MDL estimator reused here is the same implementation developed in Module 11. In this module, the implementation used 10-sample observations so that the estimator lined up cleanly with the 10-sample timeslot structure used later in the detector problems. Problem 2.1 also saved the per-timeslot energies for later reuse, but those energies were not used as the actual noise estimator.

### Example Channel Validation

- Estimated noise variance: `0.315746968375`
- Ground-truth noise variance: `0.316227766017`
- Relative error: `|estimate - truth| / |truth| = 0.00152042` (0.1520%)
- Meets 5% requirement: `Yes`

### Six Unknown Channel Noise Estimates

| Channel | Estimated Noise Variance |
| --- | ---: |
| 1 | 0.199687919633 |
| 2 | 0.316107506737 |
| 3 | 0.251593606238 |
| 4 | 0.794220689995 |
| 5 | 0.500708822246 |
| 6 | 0.631326269422 |

### Note

The main assumption that mattered here was that the MDL estimator from Module 11 could be reused directly as long as the observation length matched the Module 12 timeslot structure. Once that was settled, the rest of the module could build on the saved noise estimates and saved timeslot energies without recomputing them.

## 3. Problem 2.2 – CFAR Threshold

Problem 2.2 used the saved noise variance estimates from Problem 2.1 to compute an energy-detector threshold for each channel at a target false alarm probability of 0.05. The important part here was to keep the detector statistic convention fixed as summed timeslot energy over one 10-sample timeslot.

The detector statistic was

$$
T = \sum_{n=1}^{N} |x[n]|^2
$$

with $N = 10$. Under noise-only conditions, the summed complex-sample energy was modeled as gamma distributed with shape $N$ and scale $\sigma_n^2$ per complex sample. That made the threshold calculation

$$
P(T > \lambda \mid H_0) = P_{FA}
$$

and in MATLAB form

$$
\lambda = \mathrm{gaminv}(1-P_{FA}, N, \hat{\sigma}_n^2)
$$

For this homework, the target false alarm probability was fixed at

$$
P_{FA} = 0.05
$$

The reason the summed-timeslot-energy convention mattered is that the saved timeslot energies from Problem 2.1 and the thresholds from Problem 2.2 had to use the same scaling. If I had switched to average energy here, the later detection and occupancy steps would have been inconsistent.

### Example Channel Validation

- Threshold estimate: `4.95887447296`
- Threshold truth: `4.96642550398`
- Relative error vs truth: `0.00152042` (0.1520%)
- Achieved false alarm probability: `0.05000000`
- Passes required Pfa range [0.049, 0.051]: `Yes`

### Six Channel Threshold Table

| Channel | Noise Variance Estimate | Threshold Estimate |
| --- | ---: | ---: |
| 1 | 0.199687919633 | 3.13614199472 |
| 2 | 0.316107506737 | 4.96453680595 |
| 3 | 0.251593606238 | 3.95133203639 |
| 4 | 0.794220689995 | 12.4734078233 |
| 5 | 0.500708822246 | 7.86374041784 |
| 6 | 0.631326269422 | 9.91511569424 |

### Note

The main validation priority here was not just matching the example threshold value, but making sure the achieved false alarm probability landed in the required range. Matching the example threshold was still a useful secondary check.

## 4. Problem 2.3 – Probability of Detection

Problem 2.3 used the saved noise estimates from Problem 2.1 and the saved thresholds from Problem 2.2 to compute the theoretical probability of detection for each channel.

The textbook expressions used were

$$
P_D = Q_K\!\left(\frac{\sqrt{E_s}}{\sigma_n}, \frac{\sqrt{\eta}}{\sigma_n}\right)
$$

and

$$
P_{MD} = 1 - P_D
$$

where $Q_K(\cdot,\cdot)$ is the generalized Marcum-$Q$ function. In this problem,

$$
K = 10
$$

and because the assignment stated unit average signal power over a 10-sample measurement,

$$
E_s = K \cdot 1 = 10
$$

This detail mattered. At first glance it would be easy to use $E_s = 1$, but the correct interpretation here is total signal energy over the full 10-sample measurement window.

As the noise variance increases or the threshold gets larger, the two Marcum-$Q$ arguments change in a way that generally lowers $P_D$. That is why noisier channels or more conservative thresholds lead to lower detection probability.

### Computed $P_D$ Values

| Channel | Noise Variance | Threshold | P_D |
| --- | ---: | ---: | ---: |
| 1 | 0.199687919633 | 3.13614199472 | 0.999999518542 |
| 2 | 0.316107506737 | 4.96453680595 | 0.999881327354 |
| 3 | 0.251593606238 | 3.95133203639 | 0.999988828434 |
| 4 | 0.794220689995 | 12.4734078233 | 0.981808766435 |
| 5 | 0.500708822246 | 7.86374041784 | 0.997128113403 |
| 6 | 0.631326269422 | 9.91511569424 | 0.991769212568 |

### Plot

![Energy Detector Probability of Detection](Problem_2_3_ProbabilityDetection/probability_detection_bar.png)

## 5. Problem 2.4 – Energy Detection / Occupancy

Problem 2.4 applied the saved thresholds from Problem 2.2 to the saved timeslot energies from Problem 2.1 in order to decide whether each timeslot was occupied or idle.

The detector rule was just a direct threshold test:

$$
T > \lambda \quad \text{(decide occupied)}
$$

$$
T \le \lambda \quad \text{(decide idle)}
$$

or more explicitly,

$$
\text{decide occupied if } T > \lambda
$$

where $T$ is the summed energy over one 10-sample timeslot.

This step was important because it produced the first full binary activity sequence for each channel. Those saved decision vectors became the observed sequences used later for the HMM work.

For the example channel, the truth sequence was available, so I could directly compare the detector output against the actual state sequence. One subtle point here was that the example truth labels were coded as two state labels rather than simple 0/1 values, so the larger label had to be treated as the occupied state before computing agreement and confusion counts.

### Example Channel Validation

- Percent occupied: `36.8515%`
- Percent idle: `63.1485%`
- Percent agreement with truth: `96.6568%`
- True positives: `21960`
- True negatives: `41385`
- False alarms: `2191`
- Missed detections: `0`

### Occupied / Idle Percentages

| Channel | Percent Occupied | Percent Idle |
| --- | ---: | ---: |
| 1 | 79.6967 | 20.3033 |
| 2 | 52.5146 | 47.4854 |
| 3 | 14.5111 | 85.4889 |
| 4 | 63.4003 | 36.5997 |
| 5 | 51.7441 | 48.2559 |
| 6 | 9.5779 | 90.4221 |

### Note

Saving the full decision vectors mattered more than it might seem at first. The percentages were useful summaries, but Problems 2.5 and 2.6 really needed the actual slot-by-slot observation sequence rather than just aggregate occupancy numbers.

## 6. Problem 2.5 – Hidden Markov Model Estimation

Problem 2.5 estimated a two-state HMM for the channel activity process using the detector decisions from Problem 2.4 as the observation sequence.

The hidden-state interpretation was

- $S_1$ = idle
- $S_2$ = occupied

The key modeling point here is that the detector outputs from Problem 2.4 are not the hidden states themselves. They are observations generated from those hidden states through an imperfect detector. That is why an emission matrix is needed in addition to the transition matrix.

The transition matrix notation was

$$
A(i,j) = P(S_{k+1}=S_j \mid S_k=S_i)
$$

with the convention:

- rows = current state
- columns = next state

This means each row must sum to 1 because it contains all possible next-state probabilities from the current state.

The emission matrix had the form

$$
B =
\begin{array}{cc}
P(O=\text{idle}\mid S=\text{idle}) & P(O=\text{occ}\mid S=\text{idle}) \\
P(O=\text{idle}\mid S=\text{occ}) & P(O=\text{occ}\mid S=\text{occ})
\end{array}
$$

Conceptually, this ties back to earlier problems:

- false alarms mean an idle state can emit an occupied observation
- missed detections mean an occupied state can emit an idle observation

`hmmtrain` was then used to estimate the model from detector observations, not from direct hidden-state truth labels. That is an important distinction, because the transition matrices here are inferred through the observation model rather than counted directly from known state sequences.

### Example Channel

#### Transition Matrix

```text
0.751844 0.248156
0.486193 0.513807
```

#### Emission Matrix

```text
0.943933 0.056067
0.019331 0.980669
```

### Transition Matrix Results for Channels 1-6

#### Channel 1

```text
0.285031 0.714969
0.216852 0.783148
```

#### Channel 2

```text
0.152367 0.847633
0.846649 0.153351
```

#### Channel 3

```text
0.819179 0.180821
0.820401 0.179599
```

#### Channel 4

```text
0.379896 0.620104
0.379093 0.620907
```

#### Channel 5

```text
0.197591 0.802409
0.802133 0.197867
```

#### Channel 6

```text
0.864992 0.135008
0.856235 0.143765
```

### Note

The emission matrix was initialized from the example-channel detector behavior, with a diagonally dominant fallback available if needed. That kept the HMM setup simple while still respecting the fact that the detector is not perfect.

## 7. Problem 2.6 – Limiting Distribution

Problem 2.6 used the transition matrices estimated in Problem 2.5 to compute the long-term steady-state occupancy of each channel.

The limiting distribution $\pi$ satisfies

$$
\pi = \pi A,
\qquad
\sum_i \pi_i = 1
$$

For the two-state chain with

$$
A =
\begin{bmatrix}[
1-a & a \\
b & 1-b]
\end{bmatrix}
$$

the steady-state shortcut is

$$
\pi_{\text{idle}} = \frac{b}{a+b},
\qquad
\pi_{\text{occupied}} = \frac{a}{a+b}
$$

This was the main implementation method because it is simple and matches the live-lab limiting-distribution script directly.

The resulting steady-state probabilities are predictions of the long-term fraction of time the channel should spend idle and occupied. These can differ from the observed percentages from Problem 2.4 because:

- the observed sequence is finite
- the detector makes false alarms and missed detections
- the HMM was estimated from observations rather than hidden truth states
- the limiting distribution is a steady-state quantity, while the measured sequence may contain transient effects

### Example Channel Results

The predicted steady-state percentages are very close to the truth-derived percentages, which is a good sign that the HMM model is capturing the channel behavior fairly well.

| Quantity | Idle % | Occupied % |
| --- | ---: | ---: |
| Predicted | 66.2073 | 33.7927 |
| Observed | 63.1485 | 36.8515 |
| Truth | 66.4917 | 33.5083 |

### Six Channel Predictions

| Channel | Predicted Idle % | Predicted Occupied % | Observed Idle % | Observed Occupied % |
| --- | ---: | ---: | ---: | ---: |
| 1 | 23.2719 | 76.7281 | 20.3033 | 79.6967 |
| 2 | 49.9710 | 50.0290 | 47.4854 | 52.5146 |
| 3 | 81.9400 | 18.0600 | 85.4889 | 14.5111 |
| 4 | 37.9398 | 62.0602 | 36.5997 | 63.4003 |
| 5 | 49.9914 | 50.0086 | 48.2559 | 51.7441 |
| 6 | 86.3799 | 13.6201 | 90.4221 | 9.5779 |

### Quietest Channels

The two channels with the lowest predicted occupied probability are **Channel 6** and **Channel 3**. That means they look like the best choices for secondary user access in the long run.

## 8. Problem 2.7 – Long Whitespace Probability

Problem 2.7 asked for the probability of getting a string of 4 consecutive empty slots in two different ways:

- directly from the observed detector decisions
- from the Markov model

The important event definition was that the count uses overlapping sliding windows. So if 5 slots in a row are idle, that contributes 2 successful length-4 windows instead of just 1 disjoint run.

For the observation-based method, the estimate was

$$
P_{\text{observed}}(4\ \text{idle})
=
\frac{\text{number of all-idle 4-slot windows}}{N-3}
$$

For the Markov-model method, this is not an IID problem, so the correct shortcut is not $(\pi_{\text{idle}})^4$. Instead, with state 1 = idle and transition probability $P_{11}$ for idle-to-idle,

$$
P_{\text{predicted}}(4\ \text{idle})
=
\pi_{\text{idle}} P_{11}^3
$$

More generally, for a run of length $k$,

$$
P(k\ \text{idle}) = \pi_{\text{idle}} P_{11}^{k-1}
$$

This is a nice shortcut because once the first slot is idle, every extra idle slot just adds another factor of $P_{11}$. That also explains why the Markov-model curve decays exponentially with $k$.

### Example Channel

- Observed probability of 4 idle slots: `0.22796149`
- Predicted Markov-model probability: `0.28137685`
- Difference (observed - predicted): `-0.05341537`

### Observed vs Markov Curve

Looking at the full run-length curve gives a broader picture than just the single $k=4$ point.

![Example Channel Idle-Run Probability: Observed vs Markov Prediction](Problem_2_7_LongWhitespace/example_idle_run_probability_curve.png)

![Predicted Idle-Run Probability by Channel](Problem_2_7_LongWhitespace/predicted_idle_run_probability_by_channel.png)

### All Channels

| Channel | Observed P(4 idle) | Predicted P(4 idle) | Difference |
| --- | ---: | ---: | ---: |
| 1 | 0.00282301 | 0.00538902 | -0.00256602 |
| 2 | 0.00128180 | 0.00176761 | -0.00048581 |
| 3 | 0.53280027 | 0.45043588 | 0.08236439 |
| 4 | 0.01841820 | 0.02080124 | -0.00238304 |
| 5 | 0.00439473 | 0.00385654 | 0.00053819 |
| 6 | 0.66958632 | 0.55904692 | 0.11053939 |

### Are the Two Different?

Yes, they are different for some channels.

That makes sense here because the observation-based result comes from a finite detector output sequence, while the Markov-model result comes from a steady-state approximation built from an HMM that was itself estimated from detector observations rather than hidden truth states. Detector errors, finite sample length, model mismatch, and steady-state assumptions can all contribute to the difference.

## 9. Problem 2.8 – Modulation Classifier Accuracy vs SNR

Problem 2.8 evaluated the pretrained modulation classifier on BPSK-only inputs over the SNR sweep from 10 dB down to 3 dB in 0.5 dB steps. The implementation reused the exact BPSK signal path from the live-lab script, including the same `1 \times 1024 \times 2 \times 1000` input tensor format.

This means:

- 1000 vectors per SNR
- each vector length 1024
- BPSK only
- same clean BPSK data reused at every SNR
- only the AWGN level changed across the sweep

Accuracy at each SNR was just the fraction of the 1000 vectors classified correctly as BPSK.

### SNR vs Accuracy

| SNR (dB) | Correct Count | Accuracy |
| --- | ---: | ---: |
| 10.0 | 1000 | 1.0000 |
| 9.5 | 1000 | 1.0000 |
| 9.0 | 1000 | 1.0000 |
| 8.5 | 992 | 0.9920 |
| 8.0 | 970 | 0.9700 |
| 7.5 | 914 | 0.9140 |
| 7.0 | 768 | 0.7680 |
| 6.5 | 554 | 0.5540 |
| 6.0 | 301 | 0.3010 |
| 5.5 | 140 | 0.1400 |
| 5.0 | 58 | 0.0580 |
| 4.5 | 16 | 0.0160 |
| 4.0 | 8 | 0.0080 |
| 3.5 | 0 | 0.0000 |
| 3.0 | 0 | 0.0000 |

![Pre-trained Modulation Classifier Accuracy vs SNR (BPSK)](Problem_2_8_ModulationClassifier/accuracy_vs_snr.png)

### Constellation Density Plots

![BPSK Constellation at SNR 10 dB](Problem_2_8_ModulationClassifier/bpsk_constellation_snr10.png)

![BPSK Constellation at SNR 7 dB](Problem_2_8_ModulationClassifier/bpsk_constellation_snr7.png)

![BPSK Constellation at SNR 5 dB](Problem_2_8_ModulationClassifier/bpsk_constellation_snr5.png)

![BPSK Constellation at SNR 3 dB](Problem_2_8_ModulationClassifier/bpsk_constellation_snr3.png)

### Interpretation

The accuracy drops as SNR decreases because noise spreads out the I/Q clusters and makes the BPSK structure harder for the CNN to recognize. At high SNR the classifier is almost perfect, but once the noise starts overlapping the constellation clusters more heavily, the classifier performance falls quickly. 

This matches the general idea that low SNR makes the modulation pattern less visually distinct in the complex plane.
Something that I learned is that the classifier is solving a harder problem than simple BPSK symbol detection because it must identify the modulation type rather than just detect the sign of the symbol.

### How Could These Results Be Improved?

The most practical improvements would be:

- train or fine-tune the classifier with more low-SNR BPSK examples
- use data augmentation over a wider SNR range
- use longer observation windows if the model allows it
- add preprocessing or denoising before classification
- use a larger or more robust CNN architecture

## 10. Conclusion

Module 12 tied together detector design, statistical modeling, and signal classification in a way that felt very connected from problem to problem. The MDL estimator produced the noise variance needed for threshold design, the energy detector turned that into occupancy decisions, the HMM turned the observed detector output into a simple state model, and the limiting-distribution and long-whitespace calculations turned that model into practical channel-availability predictions.

The final classifier experiment added a different angle by showing how learned I/Q classification behaves when noise gets stronger. Overall, the module showed how raw samples can be turned into increasingly higher-level decisions: first noise estimates, then thresholds, then occupancy, then Markov predictions, then channel-access style metrics, and finally classifier accuracy versus SNR.

## References

- *Wireless Coexistence* textbook, especially the energy detector and probability expressions discussed around page 133.
- `Homework_12.pdf`
- `Lab12_files/SDR Live Lab 12.pdf`
- `Lab12_files/experiment_hmm_limiting_distribution.m`
- `Lab12_files/experiment_training_a_hmm_model.m`
- `Lab12_files/modulation_classification_in_noise.m`
- `Lab12_files/modulation_classification_confusion_matrix_experiment.m`
