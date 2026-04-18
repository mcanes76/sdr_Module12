# Execution Plan for Module 12 Extra Credit Problem 2.8

## 1. Goal

Implement Problem 2.8 so that it evaluates the pre-trained modulation classifier on BPSK-only inputs across the SNR sweep from 10 dB down to 3 dB in 0.5 dB steps, computes the accuracy at each of the 15 SNR points, saves the results, generates the accuracy plot, and prepares a short markdown report.

## 2. Development Order

Recommended build sequence:

1. Inspect the live-lab CNN scripts and the pre-trained network usage.
2. Lock the classifier input format.
3. Lock the BPSK test-vector source as the provided `bpsk_signal` and `bpsk_signal_labels` from `TestData.mat`.
4. Lock the SNR sweep definition.
5. Implement a one-SNR classification test first.
6. Extend the logic to the full SNR sweep.
7. Save results in a reusable `.mat` file.
8. Generate the accuracy plot.
9. Generate the markdown report.

## 3. Concrete Milestones

### Milestone 1: Inspect inputs and live-lab patterns

Confirm what Problem 2.8 will consume from:
- `Lab12_files/trainedModulationClassificationNetwork.mat`
- `Lab12_files/TestData.mat`
- `Lab12_files/modulation_classification_in_noise.m`
- `Lab12_files/modulation_classification_confusion_matrix_experiment.m`

Expected outcome:
- network loading pattern is clear
- input tensor formatting is clear
- `bpsk_signal` and `bpsk_signal_labels` are confirmed as the BPSK data path

### Milestone 2: Lock signal-generation and input-format conventions

Decide and document:
- reuse the provided `bpsk_signal` and `bpsk_signal_labels`
- exact tensor shape passed to the network
- how real and imaginary parts are arranged exactly as in `modulation_classification_in_noise.m`
- how the BPSK labels are checked against classifier output
- that only the AWGN level changes across the SNR sweep

Expected outcome:
- no ambiguity remains in how the classifier input is built

### Milestone 3: Implement one-SNR classification test

Run the full path for a single SNR value first.

Expected outcome:
- one noisy BPSK batch is classified correctly
- the returned predictions can be compared against the BPSK label

### Milestone 4: Extend to all 15 SNR points

Loop over:
- `10, 9.5, 9.0, ..., 3.0`

Expected outcome:
- one correct count and one accuracy value per SNR

### Milestone 5: Generate plot and results file

Save the results and create the accuracy-vs-SNR plot.

Expected outcome:
- `problem_2_8_results.mat` is ready
- the main plot file is generated

### Milestone 6: Prepare markdown report

Summarize the setup, accuracy curve, and improvement ideas.

Expected outcome:
- `report_problem_2_8.md` is ready for final-report drafting

## 4. Review Gates

Recommended pause points for human review:

Review Gate A:
- After inspecting the live-lab scripts
- Confirm that the network input formatting and BPSK source are correct

Review Gate B:
- After the one-SNR test
- Confirm that the predictions and BPSK label handling look correct before sweeping all SNRs

Review Gate C:
- After the full SNR sweep
- Confirm that the accuracy trend versus SNR looks reasonable

Review Gate D:
- Before finalizing the report
- Confirm that the low-SNR improvement discussion answers the homework prompt clearly

## 5. Expected Artifacts

Files expected in the later implementation:
- `Problem_2_8_ModulationClassifier/main_problem_2_8.m`
- `Problem_2_8_ModulationClassifier/generate_problem_2_8_report.m`
- `Problem_2_8_ModulationClassifier/report_problem_2_8.md`
- optionally `utilities/evaluate_modulation_classifier_accuracy.m`
- `Problem_2_8_ModulationClassifier/problem_2_8_results.mat`
- a plot image file for accuracy vs SNR

These should be enough for the homework workflow. No extra structure is needed.

## 6. Planned Result Schema

Expected saved fields:

- `results.snr_db`
- `results.num_vectors`
- `results.vector_length`
- `results.correct_counts`
- `results.accuracy`

Optional saved fields:
- `results.predicted_labels`
- `results.true_label`

- `results.metadata.network_source`
- `results.metadata.input_format`
- `results.metadata.snr_range_definition`

## 7. Discussion Prompt

The final report should explicitly answer:
- how the classifier accuracy changes as SNR decreases
- what changes could improve classifier performance at lower SNR

The clearest expected conclusion is:
- accuracy should generally fall as SNR drops
- improvements likely require better low-SNR training coverage, preprocessing, or a more robust model/input design
