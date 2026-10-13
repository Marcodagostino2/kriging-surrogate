function [L, ok] = factorize(K)
% factorize  Lower Cholesky factor of a symmetric matrix.
%   ok is false when K is not numerically positive definite; L is then
%   incomplete and must not be used.
[L, flag] = chol(K, "lower");
ok = flag == 0;
end
