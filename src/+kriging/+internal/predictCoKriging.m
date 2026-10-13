function [mu, s2] = predictCoKriging(cg, uq)
% predictCoKriging  High-fidelity mean and latent variance of AR(1) co-Kriging.
%
%   The query is a high-fidelity point: its covariance with the cheap data
%   is rho*sL*R_L and with the expensive data rho^2*sL*R_L + sD*R_D. The
%   variance adds the correction for the estimated low-fidelity trend and
%   leaves out the nuggets; it is clipped at zero and computed only when
%   asked for.
cLow = cg.rho * cg.sigma2Low ...
    * kriging.internal.correlation(cg.uLow, uq, cg.thetaLow, cg.pLow);
cHigh = cg.rho^2 * cg.sigma2Low ...
    * kriging.internal.correlation(cg.uHigh, uq, cg.thetaLow, cg.pLow) ...
    + cg.sigma2Disc * kriging.internal.correlation(cg.uHigh, uq, cg.thetaDisc, cg.pDisc);
c = [cLow; cHigh];
fLow = kriging.internal.trendBasis(uq, cg.degreeLow);
fDisc = kriging.internal.trendBasis(uq, cg.degreeDisc);
mu = cg.rho * (fLow * cg.coefLow) + fDisc * cg.coefDisc + c' * cg.weights;
if nargout > 1
    prior = cg.rho^2 * cg.sigma2Low + cg.sigma2Disc;
    Cc = cg.L' \ (cg.L \ c);
    G = cg.H' * cg.CinvH;
    v = cg.rho * fLow' - cg.CinvH' * c;
    s2 = prior - sum(c .* Cc, 1)' + sum(v .* (G \ v), 1)';
    s2 = max(s2, 0);
end
end
