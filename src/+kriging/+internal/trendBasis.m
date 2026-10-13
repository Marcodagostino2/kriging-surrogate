function F = trendBasis(u, degree)
% trendBasis  Design matrix of the polynomial trend.
%
%   degree 0: [1]; 1: [1, u]; 2: [1, u, u_i .* u_j for i <= j], the
%   quadratic terms ordered as find(triu(ones(d))).
n = size(u, 1);
switch degree
    case 0
        F = ones(n, 1);
    case 1
        F = [ones(n, 1), u];
    case 2
        [i, j] = find(triu(ones(size(u, 2))));
        F = [ones(n, 1), u, u(:, i) .* u(:, j)];
end
end
