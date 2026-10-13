function y = forrester(x)
% forrester  One-dimensional test function of Forrester et al. on [0, 1].
%
%   y = (6x - 2)^2 * sin(12x - 4). A. Forrester, A. Sobester, A. Keane,
%   Engineering Design via Surrogate Modelling, Wiley, 2008.
y = (6 * x - 2).^2 .* sin(12 * x - 4);
end
