function probability_curve = compute_idle_run_probability_curve(input_data, k_values, mode, P11)
%COMPUTE_IDLE_RUN_PROBABILITY_CURVE Compute observed or predicted idle-run probabilities.

switch lower(mode)
    case 'observed'
        % Use overlapping windows so a longer idle run contributes multiple
        % shorter windows when the window slides across the sequence.
        decisions = input_data(:).';
        idle_flags = double(decisions == 0);
        probability_curve = zeros(size(k_values));

        for idx = 1:numel(k_values)
            k = k_values(idx);
            window_idle_counts = conv(idle_flags, ones(1, k), 'valid');
            probability_curve(idx) = mean(window_idle_counts == k);
        end

    case 'markov'
        % Once the first slot is idle, the next k-1 slots must stay idle,
        % so the curve follows pi_idle * P11^(k-1).
        pi_idle = input_data;
        probability_curve = pi_idle .* (P11 .^ (k_values - 1));

    otherwise
        error('Unknown mode. Use ''observed'' or ''markov''.')
end

end
