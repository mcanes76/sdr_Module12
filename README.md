# SDR Module 12 Run Guide

This repository is organized one folder per homework problem. Each problem has a `main_problem_*.m` script that performs the calculation and saves results.

The important thing is that the scripts are not fully independent. Several later problems reuse saved results from earlier problems, so the safest way to run the module is in the order below.

## Recommended Run Order

Run these from MATLAB with `sdr_Module12` as the working folder, or `cd` into each problem folder before calling its main script.

```matlab
cd('C:/REPO/sdr_Module12')

cd Problem_2_1_NoiseEstimation
main_problem_2_1

cd ../Problem_2_2_CFARThreshold
main_problem_2_2

cd ../Problem_2_3_ProbabilityDetection
main_problem_2_3

cd ../Problem_2_4_EnergyDetection
main_problem_2_4

cd ../Problem_2_5_HMM
main_problem_2_5

cd ../Problem_2_6_IdlePrediction
main_problem_2_6

cd ../Problem_2_7_LongWhitespace
main_problem_2_7

cd ../Problem_2_8_ModulationClassifier
main_problem_2_8
```

## Dependency Notes

- Problem 2.1 estimates noise variance and saves timeslot energies.
- Problem 2.2 uses the Problem 2.1 noise estimates to compute CFAR thresholds.
- Problem 2.3 uses the Problem 2.1 noise estimates and Problem 2.2 thresholds to compute theoretical probability of detection.
- Problem 2.4 uses the Problem 2.1 timeslot energies and Problem 2.2 thresholds to create binary occupancy decisions.
- Problem 2.5 uses the Problem 2.4 binary decisions as HMM observations.
- Problem 2.6 uses the Problem 2.5 transition matrices and compares against Problem 2.4 observed occupancy.
- Problem 2.7 uses Problems 2.4, 2.5, and 2.6 to compare observed and Markov-predicted long whitespace probabilities.
- Problem 2.8 is mostly independent of Problems 2.1–2.7. It uses the live-lab files in `Lab12_files/`, especially `TestData.mat` and `trainedModulationClassificationNetwork.mat`.

## Figure Display Note

Some of the main scripts generate figures. These have been chained so that plots display and remain open during the script run, allowing to inspect them directly instead of only seeing saved image files.

The figure-producing scripts are:

- `Problem_2_3_ProbabilityDetection/main_problem_2_3.m`
- `Problem_2_7_LongWhitespace/main_problem_2_7.m`
- `Problem_2_8_ModulationClassifier/main_problem_2_8.m`

The generated image files are also saved in their problem folders.

## Individual Problem Outputs

Each main script saves a results file in its own problem folder:

| Problem | Main Result File |
| --- | --- |
| 2.1 | `Problem_2_1_NoiseEstimation/problem_2_1_results.mat` |
| 2.2 | `Problem_2_2_CFARThreshold/problem_2_2_results.mat` |
| 2.3 | `Problem_2_3_ProbabilityDetection/problem_2_3_results.mat` |
| 2.4 | `Problem_2_4_EnergyDetection/problem_2_4_results.mat` |
| 2.5 | `Problem_2_5_HMM/problem_2_5_results.mat` |
| 2.6 | `Problem_2_6_IdlePrediction/problem_2_6_results.mat` |
| 2.7 | `Problem_2_7_LongWhitespace/problem_2_7_results.mat` |
| 2.8 | `Problem_2_8_ModulationClassifier/problem_2_8_results.mat` |

## Data Files

The main homework dataset is:

```text
data/hw12_test_data.mat
```

The live-lab classifier files used by Problem 2.8 are:

```text
Lab12_files/TestData.mat
Lab12_files/trainedModulationClassificationNetwork.mat
```
