function limiting_distribution = compute_limiting_distribution(transition_matrix)
%COMPUTE_LIMITING_DISTRIBUTION Compute the two-state steady-state distribution.

% For a two-state chain with rows = current state and columns = next state,
% a is the idle->occupied jump and b is the occupied->idle jump.
a = transition_matrix(1, 2);
b = transition_matrix(2, 1);

% The limiting distribution tells us the long-term fraction of time
% spent idle and occupied once the chain settles down.
pi_idle = b / (a + b);
pi_occupied = a / (a + b);

limiting_distribution = [pi_idle, pi_occupied];

end
