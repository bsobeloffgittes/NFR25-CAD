clear;
coilover_lengths = [7.233,7.137,7.041,6.945,6.849,6.753,6.657,6.561,6.465,6.37,6.274,6.178,6.083,5.988,5.894,5.801,5.708,5.615,5.524,5.434,5.346];
jounce_vals = linspace(0.9,-1,20);

coilover_deltas = zeros(1,length(coilover_lengths)-1);

for i = 1:length(coilover_lengths)-1
    coilover_deltas(i) = coilover_lengths(i+1) - coilover_lengths(i);
end

% motion ratio = wheel displacement / coilover displacement

motion_ratios = (0.1./coilover_deltas).*-1;

% jounce_vals = flip(jounce_vals);
% motion_ratios = flip(motion_ratios);

% plot(flip(jounce_vals),flip(motion_ratios))
plot(jounce_vals,motion_ratios)
xlabel('jounce, in (negative = compression)');
ylabel('motion ratio (wheel displacement / coilover displacement)');