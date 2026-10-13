function [mu, s2] = predictProcess(gp, uq)
% predictProcess  Kriging mean and latent variance in normalized coordinates.
%
%   s2 = sigma2 * (1 - r' K^-1 r + v' (F' K^-1 F)^-1 v), v = f - F' K^-1 r,
%   with K = R + lambda*I: the variance of the latent function, without the
%   nugget, clipped at zero. It is computed only when asked for.
r = kriging.internal.correlation(gp.u, uq, gp.theta, gp.p);
fq = kriging.internal.trendBasis(uq, gp.degree);
mu = fq * gp.coef + r' * gp.weights;
if nargout > 1
    F = kriging.internal.trendBasis(gp.u, gp.degree);
    solve = @(b) gp.L' \ (gp.L \ b);
    Kr = solve(r);
    G = F' * solve(F);
    v = fq' - F' * Kr;
    s2 = gp.sigma2 * (1 - sum(r .* Kr, 1)' + sum(v .* (G \ v), 1)');
    s2 = max(s2, 0);
end
end
