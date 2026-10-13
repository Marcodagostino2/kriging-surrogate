function results = braninCoKriging()
% braninCoKriging  Co-Kriging on the two-fidelity Branin pair of Dong et al.
%
%   40 cheap and 10 expensive Latin hypercube samples. Co-Kriging is
%   compared with Kriging fitted on the 10 expensive samples alone, on a
%   50-by-50 grid of the expensive function.
%
%   The example shows a limit of the autoregressive model. Over the domain
%   this cheap function correlates poorly with the expensive one, so no
%   scale rho turns it into a useful predictor: rho comes out close to zero
%   and co-Kriging does no better than Kriging on the expensive samples.
bounds = [-5 0; 10 15];
xLow = bounds(1, :) + kriging.latinHypercube(40, 2, Seed=2) .* diff(bounds);
xHigh = bounds(1, :) + kriging.latinHypercube(10, 2, Seed=3) .* diff(bounds);
yLow = benchmarks.braninLowFidelity(xLow);
yHigh = benchmarks.braninHighFidelity(xHigh);
opts = kriging.FitOptions();

coKriging = kriging.CoKrigingModel.fit(xLow, yLow, xHigh, yHigh, ...
    LowFidelity=opts, Discrepancy=opts, InputBounds=bounds);
krigingOnly = kriging.KrigingModel.fit(xHigh, yHigh, opts, InputBounds=bounds);

[g1, g2] = meshgrid(linspace(bounds(1, 1), bounds(2, 1), 50), ...
    linspace(bounds(1, 2), bounds(2, 2), 50));
xGrid = [g1(:), g2(:)];
yGrid = benchmarks.braninHighFidelity(xGrid);
yCo = coKriging.predict(xGrid);
yKr = krigingOnly.predict(xGrid);
co = kriging.errorMetrics(yGrid, yCo);
kr = kriging.errorMetrics(yGrid, yKr);
r = corrcoef(yGrid, benchmarks.braninLowFidelity(xGrid));
correlation = r(1, 2);
fprintf("Two-fidelity Branin: grid RMSE %.3f with co-Kriging, %.3f with Kriging on the expensive samples (rho = %.2f, correlation of the two fidelities %.2f)\n", ...
    co.RMSE, kr.RMSE, coKriging.Rho, correlation);

fig = figure(Name="Branin: co-Kriging", Position=[100 100 1100 330]);
layout = tiledlayout(fig, 1, 3, TileSpacing="compact");
panels = {yGrid, yCo, yKr};
titles = ["Expensive function", "Co-Kriging", "Kriging, expensive samples only"];
for k = 1:3
    ax = nexttile(layout);
    contourf(ax, g1, g2, reshape(panels{k}, size(g1)), 20, LineColor="none");
    hold(ax, "on");
    plot(ax, xLow(:, 1), xLow(:, 2), "ko", MarkerSize=4);
    plot(ax, xHigh(:, 1), xHigh(:, 2), "ks", MarkerFaceColor="k", MarkerSize=5);
    title(ax, titles(k));
    xlabel(ax, "x_1");
    ylabel(ax, "x_2");
    colorbar(ax);
    clim(ax, [min(yGrid), max(yGrid)]);
end

results = struct("nLow", size(xLow, 1), "nHigh", size(xHigh, 1), "rmseCoKriging", co.RMSE, ...
    "rmseKriging", kr.RMSE, "rho", coKriging.Rho, "correlation", correlation, "figure", fig);
end
