function cg = assembleCoKriging(gpLow, gpDisc, rho, yLow, yHigh)
% assembleCoKriging  Joint Gaussian process of AR(1) co-Kriging.
%
%   Stacks the low- and high-fidelity data, with covariance
%       C = [ sL*(RLL + lamL*I)   rho*sL*RLH
%             rho*sL*RLH'         rho^2*sL*RHH + sD*(RDD + lamD*I) ]
%   where sL, sD are the process variances of the low-fidelity model and
%   of the discrepancy. The low-fidelity trend is re-estimated from both
%   data sets by generalized least squares, the discrepancy trend is kept.
%   The result holds what predictCoKriging needs.
uL = gpLow.u;
uH = gpDisc.u;
nL = size(uL, 1);
nH = size(uH, 1);
sL = gpLow.sigma2;
sD = gpDisc.sigma2;
RLL = kriging.internal.correlation(uL, uL, gpLow.theta, gpLow.p);
RLH = kriging.internal.correlation(uL, uH, gpLow.theta, gpLow.p);
RHH = kriging.internal.correlation(uH, uH, gpLow.theta, gpLow.p);
RDD = kriging.internal.correlation(uH, uH, gpDisc.theta, gpDisc.p);
C = [sL * (RLL + gpLow.lambda * eye(nL)), rho * sL * RLH
     rho * sL * RLH', rho^2 * sL * RHH + sD * (RDD + gpDisc.lambda * eye(nH))];
[L, ok] = kriging.internal.factorize(C);
if ~ok
    error("kriging:assembleCoKriging:NotPositiveDefinite", ...
        "The co-Kriging covariance is not positive definite: raise the lower nugget bounds or remove duplicate points.");
end
H = [kriging.internal.trendBasis(uL, gpLow.degree)
     rho * kriging.internal.trendBasis(uH, gpLow.degree)];
K = [zeros(nL, numel(gpDisc.coef))
     kriging.internal.trendBasis(uH, gpDisc.degree)];
[coefLow, weights] = kriging.internal.glsSolve(L, H, [yLow; yHigh] - K * gpDisc.coef);

cg.uLow = uL;
cg.uHigh = uH;
cg.rho = rho;
cg.thetaLow = gpLow.theta;
cg.pLow = gpLow.p;
cg.sigma2Low = sL;
cg.degreeLow = gpLow.degree;
cg.coefLow = coefLow;
cg.thetaDisc = gpDisc.theta;
cg.pDisc = gpDisc.p;
cg.sigma2Disc = sD;
cg.degreeDisc = gpDisc.degree;
cg.coefDisc = gpDisc.coef;
cg.L = L;
cg.H = H;
cg.CinvH = L' \ (L \ H);
cg.weights = weights;
end
