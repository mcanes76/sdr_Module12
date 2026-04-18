# Problem 2.8 Modulation Classifier Accuracy vs SNR

## Objective
Evaluate the pretrained CNN modulation classifier on BPSK-only inputs as a function of SNR using the same signal path as the live-lab script.

## Experiment Setup
- `1000` vectors per SNR
- vector length `1024` samples
- SNR sweep: `10` down to `3` dB in `0.5` dB steps
- pretrained CNN classifier from the live lab

## Results
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

![Pre-trained Modulation Classifier Accuracy vs SNR (BPSK)](accuracy_vs_snr.png)

### Example Constellation Density Plots
![BPSK Constellation at SNR 10 dB](bpsk_constellation_snr10.png)
![BPSK Constellation at SNR 7 dB](bpsk_constellation_snr7.png)
![BPSK Constellation at SNR 5 dB](bpsk_constellation_snr5.png)
![BPSK Constellation at SNR 3 dB](bpsk_constellation_snr3.png)

## Interpretation
Accuracy decreases as SNR decreases because noise obscures the BPSK structure in the I/Q samples, which makes the constellation clusters harder for the classifier to separate.

## Improvement Ideas
- train or fine-tune with more low-SNR BPSK examples
- use data augmentation over a wider SNR range
- increase the observation length beyond 1024 samples if the model allows it
- add denoising or front-end preprocessing before classification
- use a larger or more robust CNN architecture

