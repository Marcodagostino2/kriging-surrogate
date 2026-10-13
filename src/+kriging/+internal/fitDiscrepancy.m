function [gp, rho, info] = fitDiscrepancy(u, y, yLowAtHigh, opts)
% fitDiscrepancy  Discrepancy model and scale of AR(1) co-Kriging.
%
%   y(x) = rho * yLow(x) + delta(x) (Kennedy and O'Hagan, 2000). The
%   low-fidelity prediction at the high-fidelity points enters the trend as
%   an extra regressor, so rho is profiled out by generalized least squares
%   together with the trend of delta and the fit is an ordinary Kriging fit.
%   gp describes delta: its coef holds the trend coefficients only.
[gp, info] = kriging.internal.fitProcess(u, y, opts, yLowAtHigh);
rho = gp.coef(end);
gp.coef = gp.coef(1:end-1);
end
