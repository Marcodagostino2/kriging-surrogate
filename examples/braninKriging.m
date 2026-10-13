function results = braninKriging()
% braninKriging  Kriging on the Branin function from 20 samples.
%
%   results = braninKriging() fits a Kriging model to 20 Latin hypercube
%   samples of the Branin function, compares it with the true function on
%   a 50-by-50 grid and plots function, prediction and standard deviation.
%   Run it after addpath src examples.
bounds = [-5 0; 10 15];
nTrain = 20;
x = bounds(1, :) + kriging.latinHypercube(nTrain, 2, Seed=1) .* diff(bounds);
y = benchmarks.branin(x);

model = kriging.KrigingModel.fit(x, y, kriging.FitOptions(), InputBounds=bounds);

[g1, g2] = meshgrid(linspace(bounds(1, 1), bounds(2, 1), 50), ...
    linspace(bounds(1, 2), bounds(2, 2), 50));
xGrid = [g1(:), g2(:)];
yGrid = benchmarks.branin(xGrid);
[yHat, s2] = model.predict(xGrid);
metrics = kriging.errorMetrics(yGrid, yHat);
fprintf("Branin, %d samples: grid RMSE %.3f (output range %.0f), R^2 %.4f\n", ...
    nTrain, metrics.RMSE, max(yGrid) - min(yGrid), metrics.R2);

fig = figure(Name="Branin: Kriging", Position=[100 100 1100 330]);
layout = tiledlayout(fig, 1, 3, TileSpacing="compact");
panels = {yGrid, yHat, sqrt(s2)};
titles = ["Branin function", "Kriging prediction", "Standard deviation"];
for k = 1:3
    ax = nexttile(layout);
    contourf(ax, g1, g2, reshape(panels{k}, size(g1)), 20, LineColor="none");
    hold(ax, "on");
    plot(ax, x(:, 1), x(:, 2), "k.", MarkerSize=12);
    title(ax, titles(k));
    xlabel(ax, "x_1");
    ylabel(ax, "x_2");
    colorbar(ax);
    if k < 3
        % Function and prediction share one colour scale.
        clim(ax, [min(yGrid), max(yGrid)]);
    end
end

results = struct("nTrain", nTrain, "rmse", metrics.RMSE, "r2", metrics.R2, "figure", fig);
end
