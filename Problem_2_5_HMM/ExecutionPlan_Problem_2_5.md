# Execution Plan for Module 12 Problem 2.5

## 1. Goal

Implement Problem 2.5 so that it uses the saved binary detector outputs from Problem 2.4 as observation sequences, estimates a two-state HMM transition matrix for the example channel and all six channels with MATLAB’s `hmmtrain`, saves the estimated transition matrices and emission matrices, and prepares those results for Problem 2.6.

The key modeling point is that the transition matrix is inferred from observed detector outputs through the HMM, not measured from direct hidden-state observations.

## 2. Development Order

Recommended build sequence:

1. Inspect Problem 2.4 saved outputs.
2. Inspect the live-lab HMM materials for state conventions, observation formatting, and `hmmtrain` usage.
3. Lock the hidden-state and observed-sequence conventions.
4. Decide how the emission matrix will be initialized.
5. Implement example-channel HMM estimation first.
6. Extend the same training flow to the six channels.
7. Save results in a reusable `.mat` file.
8. Generate a short markdown report from the saved results.

## 3. Concrete Milestones

### Milestone 1: Inspect inputs and live-lab patterns

Confirm what Problem 2.5 will consume from:
- `Problem_2_4_EnergyDetection/problem_2_4_results.mat`
- the HMM live-lab scripts in `Lab12_files/`

Expected outcome:
- field names are known
- detector decisions are confirmed as the observed sequence source
- useful `hmmtrain` patterns from the live lab are identified
- it is clear that training is based on observed detector outputs rather than direct hidden-state labels

### Milestone 2: Lock conventions for states, observations, and matrix orientation

Decide and document:
- hidden states use a two-state idle / occupied model
- observations come from Problem 2.4 detector outputs
- observation symbols passed to `hmmtrain` use `1/2`, not `0/1`
- transition matrices are saved as rows = current state, columns = next state

Expected outcome:
- no ambiguity remains in sequence encoding or matrix interpretation

### Milestone 3: Define initial transition and emission matrices

Choose simple initialization values:
- transition matrix initial guess
- emission matrix initial guess from Problem 2.4-derived detector behavior
- diagonally dominant fallback emission matrix if the data-driven initialization is unstable
- `hmmtrain` settings

Expected outcome:
- one clear HMM training configuration is ready for all channels

### Milestone 4: Implement example-channel HMM estimation

Train the HMM on the example observed sequence first.

Expected outcome:
- example transition matrix is estimated
- example emission matrix is estimated
- the result looks numerically valid

### Milestone 5: Run HMM estimation for six channels

Apply the same process to all six channel observation sequences.

Expected outcome:
- six estimated transition matrices
- six estimated emission matrices

### Milestone 6: Save results and prepare markdown report

Save the observed sequences and estimated matrices in a `.mat` file and generate a short markdown report.

Expected outcome:
- `problem_2_5_results.mat` is ready for later use
- `report_problem_2_5.md` captures the main HMM outputs

## 4. Review Gates

Recommended pause points for human review:

Review Gate A:
- After inspecting Problem 2.4 outputs and the live-lab scripts
- Confirm that Problem 2.5 should train on observed detector outputs, not raw energies

Review Gate B:
- After locking the state / observation conventions
- Confirm the `1/2` encoding and transition-matrix orientation before implementation continues

Review Gate C:
- After choosing the initial emission matrix
- Confirm that the emission assumptions are reasonable for the homework before running all channels

Review Gate D:
- After the example-channel HMM estimate
- Confirm that the estimated matrices look sensible before scaling out to all six channels

## 5. Expected Artifacts

Files expected in the later implementation:
- `Problem_2_5_HMM/main_problem_2_5.m`
- `Problem_2_5_HMM/generate_problem_2_5_report.m`
- `Problem_2_5_HMM/report_problem_2_5.md`
- optionally `utilities/estimate_hmm_transition_matrix.m`
- `Problem_2_5_HMM/problem_2_5_results.mat`

These should be enough for the homework workflow. No extra structure is needed.

## 6. Planned Result Schema

Expected saved fields:

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

Helpful metadata text:
- `S1_idle_S2_occupied`
- `O1_idle_detector_output_O2_occupied_detector_output`
- `rows_current_state_columns_next_state`

## 7. Future Reuse

Problem 2.6:
- will likely reuse the estimated transition matrices directly to compute limiting distributions or predicted idle / occupied probabilities
- will benefit from having the state definitions and matrix orientation saved clearly

Most important continuity rule:
- save the estimated transition matrices and the observation-sequence conventions clearly so Problem 2.6 can use them without reinterpreting the HMM setup.
