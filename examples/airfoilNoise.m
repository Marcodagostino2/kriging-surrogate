function results = airfoilNoise()
% airfoilNoise  Kriging on measured data: the NASA airfoil self-noise set.
%
%   1503 wind-tunnel measurements of the scaled sound pressure level of an
%   airfoil (Brooks, Pope and Marcolini, 1989; UCI Machine Learning
%   Repository, CC BY 4.0). Frequency and displacement thickness span two
%   decades, so they enter the model as logarithms: preparing the inputs is
%   up to the user. The measurements are noisy, so the nugget may grow up
%   to 1, and its estimate gives the noise level the model attributes to
%   the data. 80% of the rows train the model, the rest test it.
file = fullfile(fileparts(mfilename("fullpath")), "data", "airfoil_self_noise.dat");
data = readmatrix(file, FileType="text");
x = [log10(data(:, 1)), data(:, 2:4), log10(data(:, 5))];
y = data(:, 6);

stream = RandStream("mt19937ar", Seed=0);
order = randperm(stream, size(x, 1));
nTrain = round(0.8 * numel(order));
train = order(1:nTrain);
test = order(nTrain+1:end);

opts = kriging.FitOptions(NuggetBounds=[1e-6 1], NumStarts=1);
model = kriging.KrigingModel.fit(x(train, :), y(train), opts);
yHat = model.predict(x(test, :));
metrics = kriging.errorMetrics(y(test), yHat);
noiseStd = sqrt(model.ProcessVariance * model.Nugget);
fprintf("Airfoil self-noise, %d training rows: test RMSE %.2f dB, R^2 %.3f, noise from the nugget %.2f dB\n", ...
    nTrain, metrics.RMSE, metrics.R2, noiseStd);

fig = figure(Name="Airfoil self-noise: parity");
ax = axes(fig);
plot(ax, y(test), yHat, ".", MarkerSize=8);
hold(ax, "on");
limits = [min(y), max(y)];
plot(ax, limits, limits, "k--");
grid(ax, "on");
axis(ax, "equal");
xlim(ax, limits);
ylim(ax, limits);
xlabel(ax, "Measured sound pressure level [dB]", Interpreter="latex");
ylabel(ax, "Predicted [dB]", Interpreter="latex");
title(ax, sprintf("Test set, RMSE %.2f dB", metrics.RMSE), Interpreter="latex");

results = struct("nTrain", nTrain, "rmse", metrics.RMSE, "r2", metrics.R2, ...
    "noiseStd", noiseStd, "figure", fig);
end
