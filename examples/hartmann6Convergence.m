function results = hartmann6Convergence()
% hartmann6Convergence  Kriging error on the 6-D Hartmann function against
% the number of training samples.
%
%   results = hartmann6Convergence() fits Kriging models on 25 to 400 Latin
%   hypercube samples and scores each on the same 2000 test points.
sizes = [25 50 100 200 400];
bounds = [zeros(1, 6); ones(1, 6)];
xTest = kriging.latinHypercube(2000, 6, Seed=100);
yTest = benchmarks.hartmann6(xTest);
rmse = zeros(size(sizes));
for k = 1:numel(sizes)
    x = kriging.latinHypercube(sizes(k), 6, Seed=k);
    model = kriging.KrigingModel.fit(x, benchmarks.hartmann6(x), kriging.FitOptions(), ...
        InputBounds=bounds);
    metrics = kriging.errorMetrics(yTest, model.predict(xTest));
    rmse(k) = metrics.RMSE;
    fprintf("Hartmann 6-D, %3d samples: test RMSE %.4f\n", sizes(k), rmse(k));
end

fig = figure(Name="Hartmann 6-D: convergence");
ax = axes(fig);
loglog(ax, sizes, rmse, "o-", LineWidth=1.5);
grid(ax, "on");
xlabel(ax, "Training samples");
ylabel(ax, "Test RMSE");
title(ax, "Kriging on the 6-D Hartmann function");

results = struct("sizes", sizes, "rmse", rmse, "figure", fig);
end
