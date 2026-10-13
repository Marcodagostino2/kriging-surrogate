function [loss, grad] = concentratedNll(z, u, y, H)
% concentratedNll  Concentrated negative log-likelihood and its gradient.
%
%   [loss, grad] = concentratedNll(z, u, y, H) with z = [log10(theta), p,
%   lambda], inputs u (n-by-d, unit cube), standardized outputs y and trend
%   matrix H. The trend coefficients and the process variance are profiled
%   out by generalized least squares:
%       loss = 0.5 * (n*log(sigma2) + log(det(R + lambda*I)))
%   For the co-Kriging discrepancy H also carries the low-fidelity
%   prediction as its last column, so rho is profiled out the same way.
%
%   The gradient is analytic (Forrester et al., 2008); by the envelope
%   theorem the profiled coefficients do not contribute to it. When
%   R + lambda*I is not positive definite the loss is 1e6 and the gradient
%   zero, which sends the optimizer back.
[n, d] = size(u);
[theta, p, lambda] = kriging.internal.decodeHyperparameters(z, d);
R = kriging.internal.correlation(u, u, theta, p);
[L, ok] = kriging.internal.factorize(R + lambda * eye(n));
if ~ok
    loss = 1e6;
    grad = zeros(size(z));
    return
end
[~, weights, sigma2, logDetHalf] = kriging.internal.glsSolve(L, H, y);
loss = 0.5 * (n * log(sigma2) + 2 * logDetHalf);

if nargout > 1
    W = L' \ (L \ eye(n)) - (weights * weights') / sigma2;
    WR = W .* R;
    gradLogTheta = zeros(1, d);
    gradP = zeros(1, d);
    for k = 1:d
        delta = abs(u(:, k) - u(:, k)');
        gradTheta = -sum(sum(WR .* delta.^p(k)));
        gradLogTheta(k) = gradTheta * theta(k) * log(10);
        % Coincident pairs (delta = 0) contribute nothing to dR/dp.
        nonzero = delta > 0;
        termP = zeros(n, n);
        termP(nonzero) = theta(k) * (delta(nonzero).^p(k)) .* log(delta(nonzero));
        gradP(k) = -sum(sum(WR .* termP));
    end
    gradLambda = trace(W);
    grad = 0.5 * [gradLogTheta, gradP, gradLambda];
end
end
