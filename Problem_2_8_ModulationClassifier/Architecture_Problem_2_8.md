# Architecture for Module 12 Extra Credit Problem 2.8

## 1. Purpose

Problem 2.8 measures how the pre-trained modulation classifier performs as SNR changes when the input is BPSK only.

The goal is not to train a new network. The goal is to reuse the pre-trained live-lab classifier and test its accuracy over the SNR sweep:

- 10 dB
- 9.5 dB
- 9.0 dB
- ...
- 3.0 dB

This gives 15 total SNR points.

Accuracy here means:
- out of 1000 BPSK vectors at a given SNR, how many are classified correctly as BPSK

## 2. Inputs and Dependencies

Inputs from `Lab12_files/trainedModulationClassificationNetwork.mat`:
- the pre-trained network used for classification

Inputs from `Lab12_files/TestData.mat`:
- useful for understanding expected input formatting
- directly useful because it provides `bpsk_signal` and `bpsk_signal_labels`
- this should be the primary BPSK source for Problem 2.8

Inputs from the CNN live-lab scripts:
- signal tensor formatting
- network loading pattern
- classification call pattern
- example noise injection strategy

Recommended test strategy:
- adapt the live-lab BPSK testing pipeline rather than building a brand-new generation path
- reuse the provided `bpsk_signal` and `bpsk_signal_labels` from `TestData.mat`
- keep the classifier input formatting exactly aligned with the live-lab scripts

Recommended new helper:
- an optional helper such as `utilities/evaluate_modulation_classifier_accuracy.m` is reasonable
- if added, it should stay small and just evaluate one SNR setting cleanly

## 3. Live Lab Relevance

What is useful from `modulation_classification_in_noise.m`:
- how the pre-trained network is loaded
- how BPSK signal data is reshaped into the network input format
- how I/Q data is split into separate real and imaginary channels
- how AWGN is added at a chosen SNR
- how classification accuracy is computed from predicted labels

What is useful from `modulation_classification_confusion_matrix_experiment.m`:
- how the test frames are stacked into the 4D tensor expected by the classifier
- how `classify(...)` is called
- how labels appear in the live-lab workflow

What is useful from `SDR Live Lab 12.pdf`:
- the overall idea that the classifier is already trained and is meant to be evaluated, not retrained, for this homework
- the modulation-classification context and expected I/Q formatting

Key CNN input-format detail from the live-lab scripts:
- the classifier expects data in a 4D tensor
- the live-lab scripts use shape:
  - 1 row
  - 1024 columns
  - 2 pages for real and imaginary parts
  - 1000 frames

HMM-related live-lab files:
- not relevant to Problem 2.8
- those belong to Problems 2.5 through 2.7, not the modulation-classifier task

## 4. Signal Generation / Test Data Strategy

Recommended strategy:
- reuse the live-lab BPSK test-data path directly
- start from the provided `bpsk_signal` and `bpsk_signal_labels`
- generate the noisy inputs at each SNR by adding AWGN to that fixed BPSK signal set of 1000 vectors, each 1024 samples long

This is the cleanest path because:
- it matches the live-lab classifier expectations
- it avoids introducing a different signal-generation pipeline right at the end of the module
- it keeps the experiment as close as possible to `modulation_classification_in_noise.m`

Fairness across SNR values:
- use the same clean `bpsk_signal` base vectors at every SNR
- only change the added noise level
- that way the accuracy comparison across SNR reflects noise level, not a changing signal set

Recommended normalization approach:
- keep the provided clean BPSK signal at a consistent amplitude
- add AWGN scaled to the target SNR in dB using the same style as the live-lab script

SNR control should be explicit:
- define the SNR vector directly as `10:-0.5:3`
- for each SNR point, generate a noisy version of the same 1000 BPSK vectors

## 5. Classifier Input Formatting

The planning should assume the network expects the same format used in the live-lab scripts:

- size `1 x 1024 x 2 x 1000`

Interpretation:
- dimension 1: singleton row
- dimension 2: 1024 complex samples per vector
- dimension 3:
  - page 1 = real part
  - page 2 = imaginary part
- dimension 4: frame index for the 1000 test vectors

This means the future implementation should:
1. start from the provided complex `bpsk_signal`
2. reshape it into `1024 x 1000`
3. place real and imaginary parts into the two-page tensor format

Labels:
- the true labels come from `bpsk_signal_labels`
- in practice these should all correspond to BPSK for the 1000-vector experiment
- the classifier output should be checked against the BPSK label representation used by the live-lab data

## 6. Accuracy Definition

Accuracy at one SNR is:

`accuracy = number_of_correct_BPSK_predictions / 1000`

This should be evaluated independently at each SNR point.

Recommended saved values:
- correct count at each SNR
- accuracy as a fraction between 0 and 1

That makes it easy to generate either a fraction plot or a percent plot later.

## 7. Proposed Software Architecture

Keep Problem 2.8 simple and aligned with the rest of the homework.

Recommended files:
- `Problem_2_8_ModulationClassifier/main_problem_2_8.m`
- `Problem_2_8_ModulationClassifier/generate_problem_2_8_report.m`
- `Problem_2_8_ModulationClassifier/report_problem_2_8.md`
- optional helper: `utilities/evaluate_modulation_classifier_accuracy.m`

Recommended responsibilities:
- `main_problem_2_8.m`
  Loads the pre-trained network and test data, formats the provided `bpsk_signal` exactly as in the live-lab script, varies only the AWGN level at each SNR, classifies the inputs, computes accuracy, saves results, and generates the main accuracy plot.
- `generate_problem_2_8_report.m`
  Loads the saved results and writes a short markdown report.
- `evaluate_modulation_classifier_accuracy.m` if added
  Inputs:
  - clean BPSK vectors from `bpsk_signal`
  - SNR value
  - network
  - true labels from `bpsk_signal_labels`
  Outputs:
  - correct count
  - accuracy
  - optional predicted labels

The helper should stay small if used. This is homework code, so the main goal is to keep the SNR loop easy to follow.

## 8. Data Flow

Recommended Problem 2.8 flow:

1. Load `trainedModulationClassificationNetwork.mat`.
2. Load `TestData.mat`.
3. Extract the provided `bpsk_signal` and `bpsk_signal_labels`.
4. Reshape `bpsk_signal` exactly as in `modulation_classification_in_noise.m` to build the clean `1 x 1024 x 2 x 1000` tensor.
4. Define the SNR sweep:
   - `10:-0.5:3`
5. For each SNR value:
   - add AWGN to the same clean BPSK vectors
   - keep the network input formatting fixed
   - classify the 1000 vectors
   - count how many predictions match `bpsk_signal_labels`
   - store accuracy
6. Save results to `Problem_2_8_ModulationClassifier/problem_2_8_results.mat`.
7. Generate an accuracy-vs-SNR plot.
8. Generate a markdown report.

## 9. Results Structure

Proposed saved structure in `Problem_2_8_ModulationClassifier/problem_2_8_results.mat`:

- `results.snr_db`
- `results.num_vectors`
- `results.vector_length`
- `results.correct_counts`
- `results.accuracy`

Optional fields if they help:
- `results.predicted_labels`
- `results.true_label`

- `results.metadata.network_source`
- `results.metadata.input_format`
- `results.metadata.snr_range_definition`

Suggested metadata values:
- `network_source = 'Lab12_files/trainedModulationClassificationNetwork.mat'`
- `input_format = '1x1024x2x1000_real_imag_tensor'`
- `snr_range_definition = '10_to_3_dB_in_0p5_dB_steps'`

## 10. Plotting Plan

Required plot:
- x-axis = SNR in dB
- y-axis = accuracy
- title similar to:
  - `Pre-trained Modulation Classifier Accuracy vs SNR (BPSK)`

Recommended plotting choice:
- store accuracy as a fraction in the `.mat` results
- plot either fraction or percent, but percent may be easier to read in the report

Keep plotting simple:
- one line plot with markers is enough

## 11. Improvement Discussion

Possible ways to improve low-SNR performance:
- fine-tune or retrain the classifier with more low-SNR BPSK examples
- use data augmentation across a wider SNR range
- improve normalization before classification
- add denoising or front-end preprocessing
- use longer observation vectors than 1024 samples if the classifier design allows it
- use a larger or more noise-robust network architecture

For the final report, the explanation should stay practical:
- low SNR makes I/Q structure harder to distinguish
- more low-SNR training coverage and better preprocessing would likely help the most

## 12. Validation / Sanity Checks

Recommended checks:
- exactly 15 SNR points from 10 dB down to 3 dB in 0.5 dB steps
- exactly 1000 vectors per SNR
- exactly 1024 samples per vector
- all accuracy values are between 0 and 1
- high-SNR accuracy should generally be better than low-SNR accuracy
- the BPSK label used for evaluation matches the live-lab label encoding

Main ambiguity to resolve before coding:
- confirm that the provided `bpsk_signal` reshapes cleanly into 1000 vectors of length 1024 exactly as in the live-lab script

Recommended choice:
- reuse the provided `bpsk_signal` and `bpsk_signal_labels` from `TestData.mat`
- format them exactly as in `modulation_classification_in_noise.m`
- vary only the AWGN level across the required SNR sweep
