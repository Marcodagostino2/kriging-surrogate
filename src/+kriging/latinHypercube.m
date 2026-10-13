function X = latinHypercube(n, d, options)
% latinHypercube  Space-filling Latin hypercube design on the unit cube.
%
%   X = kriging.latinHypercube(n, d) returns n points in (0, 1)^d. Each
%   dimension is cut into n equal strata and every stratum holds exactly
%   one point, at its centre. Among options.Candidates random designs the
%   one whose smallest pairwise distance is largest is kept (maximin).
%
%   Options: Seed (default 0), Candidates (default 20). The design depends
%   only on these; the global random state is not used.
arguments
    n (1,1) double {mustBeInteger, mustBePositive}
    d (1,1) double {mustBeInteger, mustBePositive}
    options.Seed (1,1) double {mustBeInteger, mustBeNonnegative} = 0
    options.Candidates (1,1) double {mustBeInteger, mustBePositive} = 20
end
stream = RandStream("mt19937ar", Seed=options.Seed);
X = [];
bestDistance = -inf;
for c = 1:options.Candidates
    candidate = zeros(n, d);
    for k = 1:d
        candidate(:, k) = (randperm(stream, n)' - 0.5) / n;
    end
    distance = smallestDistance(candidate);
    if distance > bestDistance
        X = candidate;
        bestDistance = distance;
    end
end
end

function m = smallestDistance(X)
n = size(X, 1);
if n < 2
    m = inf;
    return
end
G = X * X.';
squared = diag(G) + diag(G).' - 2 * G;
squared(1:n+1:end) = inf;
m = sqrt(max(min(squared(:)), 0));
end
