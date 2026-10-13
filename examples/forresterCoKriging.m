function results = forresterCoKriging()
% forresterCoKriging  Co-Kriging on the one-dimensional Forrester function.
%
%   The textbook case of Forrester, Sobester and Keane (2008): 11 samples of
%   a cheap version of the function and 4 of the function itself.
%   Co-Kriging is compared with Kriging fitted on the 4 expensive samples
%   alone.
xLow = (0:0.1:1)';
xHigh = [0; 0.4; 0.6; 1];
yLow = benchmarks.forresterLowFidelity(xLow);
yHigh = benchmarks.forrester(xHigh);
bounds = [0; 1];
opts = kriging.FitOptions();

coKriging = kriging.CoKrigingModel.fit(xLow, yLow, xHigh, yHigh, ...
    LowFidelity=opts, Discrepancy=opts, InputBounds=bounds);
krigingOnly = kriging.KrigingModel.fit(xHigh, yHigh, opts, InputBounds=bounds);

xq = linspace(0, 1, 201)';
yTrue = benchmarks.forrester(xq);
yCo = coKriging.predict(xq);
yKr = krigingOnly.predict(xq);
co = kriging.errorMetrics(yTrue, yCo);
kr = kriging.errorMetrics(yTrue, yKr);
fprintf("Forrester: RMSE %.3f with co-Kriging, %.3f with Kriging on the expensive samples (rho = %.2f)\n", ...
    co.RMSE, kr.RMSE, coKriging.Rho);

fig = figure(Name="Forrester: co-Kriging");
ax = axes(fig);
plot(ax, xq, yTrue, "k-", LineWidth=1.5);
hold(ax, "on");
plot(ax, xq, benchmarks.forresterLowFidelity(xq), "k:", LineWidth=1);
plot(ax, xq, yCo, "-", LineWidth=1.5);
plot(ax, xq, yKr, "--", LineWidth=1.5);
plot(ax, xLow, yLow, "ko");
plot(ax, xHigh, yHigh, "ks", MarkerFaceColor="k");
grid(ax, "on");
xlabel(ax, "x");
ylabel(ax, "y");
legend(ax, ["Expensive function", "Cheap function", "Co-Kriging", ...
    "Kriging, expensive samples only", "Cheap samples", "Expensive samples"], ...
    Location="northwest");

results = struct("nLow", numel(xLow), "nHigh", numel(xHigh), "rmseCoKriging", co.RMSE, ...
    "rmseKriging", kr.RMSE, "rho", coKriging.Rho, "figure", fig);
end
