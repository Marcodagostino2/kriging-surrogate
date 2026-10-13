function m = errorMetrics(y, yHat)
% errorMetrics  RMSE, MAE and coefficient of determination of a prediction.
%
%   m = kriging.errorMetrics(y, yHat) returns a struct with fields RMSE,
%   MAE and R2 for the true values y and the predictions yHat.
arguments
    y (:,1) double
    yHat (:,1) double
end
if numel(y) ~= numel(yHat)
    error("kriging:errorMetrics:SizeMismatch", ...
        "y has %d values but yHat has %d.", numel(y), numel(yHat));
end
residuals = y - yHat;
m.RMSE = sqrt(mean(residuals.^2));
m.MAE = mean(abs(residuals));
m.R2 = 1 - sum(residuals.^2) / sum((y - mean(y)).^2);
end
