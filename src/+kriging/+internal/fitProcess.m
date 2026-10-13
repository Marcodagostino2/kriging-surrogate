function [gp, info] = fitProcess(u, y, opts, extra)
% fitProcess  Fit a Kriging model in normalized coordinates by maximum likelihood.
%
%   [gp, info] = fitProcess(u, y, opts) estimates theta, p and lambda for
%   inputs u in the unit cube and standardized outputs y with the settings
%   in opts (kriging.FitOptions), then builds the model with buildProcess.
%   extra (n-by-m, optional) adds regressors to the polynomial trend; their
%   coefficients close gp.coef. info is the report of multiStartMinimize.
arguments
    u (:,:) double
    y (:,1) double
    opts (1,1) kriging.FitOptions
    extra (:,:) double = zeros(size(u, 1), 0)
end
d = size(u, 2);
H = [kriging.internal.trendBasis(u, opts.TrendDegree), extra];
[lb, ub] = kriging.internal.hyperparameterBounds(opts, d);
objective = @(z) kriging.internal.concentratedNll(z, u, y, H);
[z, info] = kriging.internal.multiStartMinimize(objective, lb, ub, opts);
[theta, p, lambda] = kriging.internal.decodeHyperparameters(z, d);
gp = kriging.internal.buildProcess(u, y, theta, p, lambda, opts.TrendDegree, extra);
end
