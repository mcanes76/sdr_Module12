# Architecture for Module 12 Problem 2.5

## 1. Purpose

Problem 2.5 estimates a two-state HMM transition matrix for each channel.

The main input to this problem is the binary activity sequence produced in Problem 2.4. That sequence is the observed output of the energy detector, not the hidden state sequence itself. The transition matrix is therefore not being estimated from direct state observations. It is being inferred through the observation process defined by the HMM.

Problem 2.5 prepares directly for Problem 2.6 because the estimated transition matrices are the natural inputs for limiting-distribution and future-state probability calculations.

## 2. Inputs and Dependencies

Inputs from `Problem_2_4_EnergyDetection/problem_2_4_results.mat`:
- `results.example_channel.decisions`
- `results.channels(i).decisions`
- `results.example_channel.truth_sequence` for optional sanity checking
- `results.metadata.decision_rule`

Possible inputs from earlier problems if useful for documentation or sanity checks:
- Problem 2.1 occupancy-related context is not needed directly
- Problem 2.2 thresholds are not needed directly
- Problem 2.3 detection probabilities are not needed directly

Direct dataset usage:
- not strictly required if Problem 2.4 already saved the example truth sequence
- `example_channel_state_sequence` may still be useful as a sanity check if the Problem 2.4 save file does not preserve enough detail

Recommended use of the example truth sequence:
- treat it as an optional sanity check, not the main training input
- Problem 2.5 should primarily train on the observed detector outputs from Problem 2.4
- the HMM fit should be described as inference from detector observations rather than direct estimation from truth states

Recommended new helper:
- an optional helper such as `utilities/estimate_hmm_transition_matrix.m` is reasonable if it keeps `hmmtrain` setup cleaner
- if added, it should stay small and just wrap sequence formatting, initialization, and the `hmmtrain` call

## 3. HMM Interpretation

The intended two-state model is:
- `S1 = idle / unused`
- `S2 = transmitting / occupied`

Important distinction:
- hidden states = the actual channel activity process
- observed sequence = the binary detector outputs from Problem 2.4

That distinction matters because the detector is imperfect:
- an idle state can still emit an occupied observation because of false alarms
- an occupied state can still emit an idle observation because of missed detections

For Problem 2.5, the binary energy-detector decisions from Problem 2.4 should become the observed sequence passed into `hmmtrain`.

That means:
- `hmmtrain` is not being given the hidden idle / occupied state sequence directly
- `hmmtrain` is instead asked to infer the state-transition behavior from the noisy detector outputs
- the estimated transition matrix should be interpreted as an HMM estimate conditioned on the observation model, not as a direct count of hidden-state transitions

Recommended observation encoding for `hmmtrain`:
- use `1` and `2`, not `0` and `1`
- for example:
  - observation `1 = idle`
  - observation `2 = occupied`

This matches the live-lab HMM scripts, which use 1-based categorical labels and fits MATLAB’s HMM functions naturally.

Transition matrix structure:

`A(i,j) = P(state at time k+1 = Sj | state at time k = Si)`

Recommended row / column interpretation:
- rows = current state
- columns = next state

That means:
- row 1 describes transitions starting from idle
- row 2 describes transitions starting from occupied

This orientation should be written clearly in the saved metadata later so Problem 2.6 does not accidentally flip the matrix.

## 4. Live Lab Relevance

What was found in the HMM-related live-lab scripts:

From `experiment_training_a_hmm_model.m`:
- the script uses a 2x2 transition matrix
- it uses a 2x2 emission matrix
- it initializes the transition matrix with a simple uniform guess such as `[0.5 0.5; 0.5 0.5]`
- it calls `hmmtrain` with:
  - observed sequence
  - initial transition matrix guess
  - emission matrix estimate
  - `'Algorithm','BaumWelch'`
  - `'Maxiterations', 5000`
  - `'Tolerance', 1e-5`
- observed sequences are encoded as `1` and `2`

From `experiment_hmm_limiting_distribution.m`:
- states are also encoded as `1` and `2`
- the script uses the same row-to-next-state matrix convention
- it shows how transition probabilities connect to limiting state probabilities later, which is directly relevant to Problem 2.6

About the live-lab material:
- `SDR Live Lab 12.pdf` is part of the intended live-lab context for this module, and its HMM discussion is relevant to Problem 2.5
- the MATLAB HMM scripts in `Lab12_files/` give the clearest concrete patterns to reuse during implementation
- the planning here therefore uses the script-level conventions directly while treating the live-lab HMM material as supporting context

Useful concepts to reuse from the live-lab scripts:
- 1-based state / observation encoding
- simple uniform transition-matrix initialization
- explicit emission-matrix initialization
- straightforward `hmmtrain` call with Baum-Welch

Non-HMM live-lab files:
- `modulation_classification_confusion_matrix_experiment.m` and `modulation_classification_in_noise.m` are not relevant to Problem 2.5
- they are CNN / modulation-classification examples and fit much better with Problem 2.8

## 5. Emission Matrix Discussion

An HMM needs both:
- transition probabilities between hidden states
- emission probabilities from hidden states to observed symbols

That matters here because the observed detector decisions are not the same thing as the hidden activity states.

The live-lab HMM scripts make this explicit with an emission matrix of the form:

`B = [P(obs=idle | state=idle), P(obs=occupied | state=idle);
      P(obs=idle | state=occupied), P(obs=occupied | state=occupied)]`

This ties nicely to earlier detector behavior:
- idle state can emit occupied because of false alarms
- occupied state can emit idle because of missed detections

Possible approaches for Problem 2.5:
- assume a simple fixed emission matrix
- derive an emission matrix from earlier detector metrics
- initialize an emission matrix and let `hmmtrain` refine it

Recommended simplest approach for this homework:
- build a reasonable emission-matrix estimate from the example-channel detector behavior in Problem 2.4
- use that as the primary initialization for all channels
- allow `hmmtrain` to refine it if needed

Why this is a good compromise:
- it respects the detector-imperfection idea from the live lab
- it stays simple
- it uses actual homework-derived detector behavior rather than a totally arbitrary emission model

Fallback if the data-driven initialization is unstable:
- use a fixed diagonally dominant emission matrix
- keep the focus on estimating the transition matrix, since that is what the assignment explicitly asks for

Example fallback style:
- high probability of observing idle from the idle state
- high probability of observing occupied from the occupied state
- smaller off-diagonal entries to represent false alarms and missed detections

## 6. Proposed Software Architecture

Keep Problem 2.5 simple and aligned with the rest of the homework.

Recommended files:
- `Problem_2_5_HMM/main_problem_2_5.m`
- `Problem_2_5_HMM/generate_problem_2_5_report.m`
- `Problem_2_5_HMM/report_problem_2_5.md`
- optional helper: `utilities/estimate_hmm_transition_matrix.m`

Recommended responsibilities:
- `main_problem_2_5.m`
  Loads Problem 2.4 decisions, formats them as 1-based observation sequences, initializes transition and emission matrices, runs `hmmtrain` for the example channel and all six channels, and saves the estimated transition matrices.
- `generate_problem_2_5_report.m`
  Loads saved results and generates a compact markdown summary.
- `estimate_hmm_transition_matrix.m` if added
  Inputs:
  - `observed_sequence`
  - `initial_transition_matrix`
  - `initial_emission_matrix`
  Outputs:
  - `transition_matrix`
  - `emission_matrix`
  - optional training info

The helper should stay small. This is homework code, so the main goal is to keep the HMM setup easy to follow.

## 7. Data Flow

Recommended Problem 2.5 flow:

1. Load `Problem_2_4_EnergyDetection/problem_2_4_results.mat`.
2. Read the saved decision vectors for the example channel and the six channels.
3. Convert detector outputs from binary `0/1` into HMM observation symbols `1/2`.
4. Define initial transition and emission matrices.
5. Run `hmmtrain` on the example observed sequence.
6. Run `hmmtrain` on each of the six channel observed sequences.
7. Save the observed sequences and estimated matrices into `Problem_2_5_HMM/problem_2_5_results.mat`.

Optional example sanity path:
- compare the example observed sequence against the saved truth sequence informally
- do not let that replace the main HMM estimation workflow

Important interpretation:
- the saved transition matrices are inferred from observed detector outputs through the HMM model
- they are not direct transition counts from known hidden states

## 8. Results Structure

Proposed saved structure in `Problem_2_5_HMM/problem_2_5_results.mat`:

- `results.example_channel.observed_sequence`
- `results.example_channel.transition_matrix`
- `results.example_channel.emission_matrix`
- `results.example_channel.truth_sequence`

- `results.channels(i).observed_sequence`
- `results.channels(i).transition_matrix`
- `results.channels(i).emission_matrix`

- `results.metadata.state_definition`
- `results.metadata.observation_definition`
- `results.metadata.hmmtrain_settings`
- `results.metadata.transition_matrix_orientation`

Suggested metadata text:
- `state_definition = 'S1_idle_S2_occupied'`
- `observation_definition = 'O1_idle_detector_output_O2_occupied_detector_output'`
- `transition_matrix_orientation = 'rows_current_state_columns_next_state'`

For `hmmtrain_settings`, store a compact struct or text note that records:
- algorithm
- max iterations
- tolerance
- initial matrix choice

## 9. Validation / Sanity Checks

Since there may not be a provided truth transition matrix, recommended checks are:
- each row of every transition matrix sums to 1
- all probabilities stay between 0 and 1
- each emission matrix row sums to 1
- the estimated transition matrices look reasonable relative to the occupancy behavior from Problem 2.4
- example-channel results can be compared informally to the example truth activity sequence if useful

Most important check:
- verify matrix orientation carefully

It is easy to get confused about whether MATLAB returns:
- rows = current state, columns = next state
or the reverse

That should be confirmed and written explicitly into the saved metadata.

## 10. Continuity to Problem 2.6

Problem 2.6 will likely reuse the estimated transition matrices directly for limiting-distribution or future-state probability calculations.

That means Problem 2.5 should save:
- clean transition matrices
- clear state definitions
- clear matrix orientation metadata

If those are saved carefully here, Problem 2.6 can focus on the probability analysis instead of re-deriving HMM conventions.

## 11. Risks / Open Checks

Main ambiguities to settle before coding:
- exact state encoding for hidden states
- exact symbol encoding for observed detector outputs
- initial transition-matrix choice
- initial emission-matrix choice
- whether to let `hmmtrain` refine the emission matrix or keep it fixed
- whether the example truth sequence should be used only for sanity checking or for emission initialization

What should be verified before coding:
- confirm that `hmmtrain` in this MATLAB install expects observation symbols encoded as positive integers starting at 1
- confirm the row / column interpretation of the saved transition matrices
- confirm the initial emission matrix is compatible with the detector behavior seen in Problem 2.4
- confirm that using Problem 2.4 decision sequences as observations is the intended homework interpretation
