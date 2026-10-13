function y = braninHighFidelity(x)
% braninHighFidelity  High-fidelity member of the two-fidelity Branin pair.
%
%   y = branin(x) - 22.5*x2 on [-5, 10] x [0, 15]. H. Dong, B. Song, P. Wang
%   et al., Multi-fidelity information fusion based on prediction of
%   kriging, Struct. Multidisc. Optim. 51, 1267-1280 (2015); formula as in
%   the mf2 package (S. J. van Rijn, S. Schmitt, JOSS 5(52), 2020).
y = benchmarks.branin(x) - 22.5 * x(:, 2);
end
