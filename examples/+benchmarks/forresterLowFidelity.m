function y = forresterLowFidelity(x)
% forresterLowFidelity  Cheap version of the Forrester function on [0, 1].
%
%   y = A*forrester(x) + B*(x - 0.5) - C with A = 0.5, B = 10, C = -5, the
%   values of Forrester et al. (2008) as given by the Virtual Library of
%   Simulation Experiments, https://www.sfu.ca/~ssurjano/forretal08.html
y = 0.5 * benchmarks.forrester(x) + 10 * (x - 0.5) + 5;
end
