function y = hartmann6(x)
% hartmann6  Six-dimensional Hartmann function on [0, 1]^6.
%
%   y = -sum_i alpha(i) * exp(-sum_j A(i,j) * (x_j - P(i,j))^2)
%   Global minimum -3.32237 at (0.20169, 0.150011, 0.476874, 0.275332,
%   0.311652, 0.6573). Constants: S. Surjanovic, D. Bingham, Virtual Library
%   of Simulation Experiments, https://www.sfu.ca/~ssurjano/hart6.html
alpha = [1.0 1.2 3.0 3.2];
A = [10    3   17    3.5  1.7  8
     0.05 10   17    0.1  8   14
     3     3.5  1.7 10   17    8
     17    8    0.05 10   0.1 14];
P = 1e-4 * [1312 1696 5569  124 8283 5886
            2329 4135 8307 3736 1004 9991
            2348 1451 3522 2883 3047 6650
            4047 8828 8732 5743 1091  381];
y = zeros(size(x, 1), 1);
for i = 1:4
    y = y - alpha(i) * exp(-sum(A(i, :) .* (x - P(i, :)).^2, 2));
end
end
