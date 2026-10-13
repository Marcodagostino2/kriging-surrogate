function y = branin(x)
% branin  Branin function on [-5, 10] x [0, 15].
%
%   y = (x2 - 5.1/(4*pi^2)*x1^2 + 5/pi*x1 - 6)^2 + 10*(1 - 1/(8*pi))*cos(x1) + 10
%   Three global minima, 0.397887, at (-pi, 12.275), (pi, 2.275) and
%   (9.42478, 2.475). Formula: S. Surjanovic, D. Bingham, Virtual Library of
%   Simulation Experiments, https://www.sfu.ca/~ssurjano/branin.html
x1 = x(:, 1);
x2 = x(:, 2);
y = (x2 - 5.1 / (4 * pi^2) * x1.^2 + 5 / pi * x1 - 6).^2 ...
    + 10 * (1 - 1 / (8 * pi)) * cos(x1) + 10;
end
