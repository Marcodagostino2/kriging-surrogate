function gp = buildProcess(u, y, theta, p, lambda, degree, extra)
% buildProcess  Kriging model in normalized coordinates for given hyperparameters.
%
%   gp has fields u (training inputs), theta, p, lambda, degree, L (lower
%   Cholesky factor of R + lambda*I), coef (trend coefficients, followed by
%   those of the extra regressors, if any), weights ((R + lambda*I) \ the
%   trend residuals) and sigma2 (process variance).
arguments
    u (:,:) double
    y (:,1) double
    theta (1,:) double
    p (1,:) double
    lambda (1,1) double
    degree (1,1) double
    extra (:,:) double = zeros(size(u, 1), 0)
end
R = kriging.internal.correlation(u, u, theta, p);
[L, ok] = kriging.internal.factorize(R + lambda * eye(size(u, 1)));
if ~ok
    error("kriging:buildProcess:NotPositiveDefinite", ...
        "The correlation matrix is not positive definite: raise the lower nugget bound or remove duplicate points.");
end
H = [kriging.internal.trendBasis(u, degree), extra];
[coef, weights, sigma2] = kriging.internal.glsSolve(L, H, y);

gp.u = u;
gp.theta = theta;
gp.p = p;
gp.lambda = lambda;
gp.degree = degree;
gp.L = L;
gp.coef = coef;
gp.weights = weights;
gp.sigma2 = sigma2;
end
