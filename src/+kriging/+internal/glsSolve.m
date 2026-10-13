function [coef, weights, sigma2, logDetHalf] = glsSolve(L, H, y)
% glsSolve  Generalized least squares with covariance K = L*L'.
%
%   coef       = (H' K^-1 H) \ (H' K^-1 y)      trend coefficients
%   weights    = K^-1 (y - H*coef)              residual weights
%   sigma2     = (y - H*coef)' * weights / n    concentrated process variance
%   logDetHalf = sum(log(diag(L)))              half of log(det(K))
solve = @(b) L' \ (L \ b);
coef = (H' * solve(H)) \ (H' * solve(y));
residuals = y - H * coef;
weights = solve(residuals);
sigma2 = (residuals' * weights) / numel(y);
logDetHalf = sum(log(diag(L)));
end
