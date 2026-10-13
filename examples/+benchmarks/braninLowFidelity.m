function y = braninLowFidelity(x)
% braninLowFidelity  Low-fidelity member of the two-fidelity Branin pair.
%
%   y = branin(0.7*x) - 15.75*x2 + 20*(0.9 + x1)^2 - 50 on [-5, 10] x [0, 15].
%   Dong et al. (2015), as in the mf2 package; see braninHighFidelity.
y = benchmarks.branin(0.7 * x) - 15.75 * x(:, 2) + 20 * (0.9 + x(:, 1)).^2 - 50;
end
