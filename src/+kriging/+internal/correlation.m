function R = correlation(A, B, theta, p)
% correlation  Power-exponential correlation between two sets of points.
%
%   R(i,j) = exp(-sum_k theta(k) * |A(i,k) - B(j,k)|^p(k)), with A nA-by-d,
%   B nB-by-d and R nA-by-nB. The loop over dimensions keeps memory at one
%   nA-by-nB array.
D = zeros(size(A, 1), size(B, 1));
for k = 1:numel(theta)
    D = D + theta(k) * abs(A(:, k) - B(:, k).').^p(k);
end
R = exp(-D);
end
