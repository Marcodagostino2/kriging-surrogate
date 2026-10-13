function [lb, ub] = hyperparameterBounds(opts, d)
% hyperparameterBounds  Box bounds of z = [log10(theta), p, lambda] for d inputs.
logTheta = perInput(opts.LogThetaBounds, d, "LogThetaBounds");
p = perInput(opts.ExponentBounds, d, "ExponentBounds");
lb = [logTheta(1, :), p(1, :), opts.NuggetBounds(1)];
ub = [logTheta(2, :), p(2, :), opts.NuggetBounds(2)];
end

function b = perInput(b, d, name)
if size(b, 2) == 1
    b = repmat(b, 1, d);
elseif size(b, 2) ~= d
    error("kriging:FitOptions:BoundsSize", ...
        "%s has %d columns but the data have %d inputs.", name, size(b, 2), d);
end
end
