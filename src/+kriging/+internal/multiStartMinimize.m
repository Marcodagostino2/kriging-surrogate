function [zBest, info] = multiStartMinimize(objective, lb, ub, opts)
% multiStartMinimize  Minimize a smooth function on a box from several starts.
%
%   [zBest, info] = multiStartMinimize(objective, lb, ub, opts) runs the SQP
%   algorithm of fmincon from opts.NumStarts points and keeps the best
%   result; objective returns the value and the gradient. The first start
%   is the centre of the box, the others form a Latin hypercube drawn with
%   opts.Seed, so the starts depend only on the options. opts.Display =
%   "iter" prints one line per start.
%
%   info.fval   best objective value
%   info.starts one element per start, with fields z0, z, fval, exitflag
%               and iterations
nStarts = opts.NumStarts;
starts = repmat(lb + 0.5 * (ub - lb), nStarts, 1);
if nStarts > 1
    unit = kriging.latinHypercube(nStarts - 1, numel(lb), Seed=opts.Seed);
    starts(2:end, :) = lb + unit .* (ub - lb);
end
solverOptions = optimoptions("fmincon", Algorithm="sqp", ...
    SpecifyObjectiveGradient=true, OptimalityTolerance=1e-6, ...
    StepTolerance=1e-6, MaxIterations=1000, Display="off");

info.fval = inf;
info.starts = struct("z0", cell(1, nStarts), "z", [], "fval", [], ...
    "exitflag", [], "iterations", []);
zBest = starts(1, :);
for s = 1:nStarts
    [z, fval, exitflag, output] = fmincon(objective, starts(s, :), ...
        [], [], [], [], lb, ub, [], solverOptions);
    info.starts(s) = struct("z0", starts(s, :), "z", z, "fval", fval, ...
        "exitflag", exitflag, "iterations", output.iterations);
    if opts.Display == "iter"
        fprintf("Start %d of %d: loss %.6g, exit flag %d, %d iterations\n", ...
            s, nStarts, fval, exitflag, output.iterations);
    end
    if fval < info.fval
        info.fval = fval;
        zBest = z;
    end
end
end
