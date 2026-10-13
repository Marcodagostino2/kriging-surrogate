classdef FitOptions
    % FitOptions  Settings for fitting a Kriging model.
    %
    %   opts = kriging.FitOptions(Name=Value)
    %
    %   TrendDegree     degree of the polynomial trend: 0 (constant, ordinary
    %                   Kriging), 1 (linear) or 2 (quadratic with cross
    %                   terms). Default 0.
    %   ExponentBounds  bounds on the kernel exponents p, inside (0, 2]. A
    %                   pair [lower upper] applies to every input, a 2-by-d
    %                   matrix sets one column per input; equal bounds fix p.
    %                   Default [2 2], the Gaussian kernel.
    %   LogThetaBounds  bounds on log10(theta), same shapes. Default [-5 3].
    %   NuggetBounds    pair of bounds on the nugget. Default [1e-5 1e-2].
    %   NumStarts       number of optimizer starts. Default 5.
    %   Seed            seed of the random starts. Default 0.
    %   Display         "off" or "iter" (one line per start). Default "off".
    %
    %   theta and the nugget refer to inputs scaled to the unit cube and to
    %   the standardized output. Pairs are stored as 2-by-1 columns.

    properties (SetAccess = immutable)
        TrendDegree
        ExponentBounds
        LogThetaBounds
        NuggetBounds
        NumStarts
        Seed
        Display
    end

    methods
        function obj = FitOptions(options)
            arguments
                options.TrendDegree (1,1) double {mustBeMember(options.TrendDegree, [0 1 2])} = 0
                options.ExponentBounds (:,:) double = [2 2]
                options.LogThetaBounds (:,:) double = [-5 3]
                options.NuggetBounds (:,:) double = [1e-5 1e-2]
                options.NumStarts (1,1) double {mustBeInteger, mustBePositive} = 5
                options.Seed (1,1) double {mustBeInteger, mustBeNonnegative} = 0
                options.Display (1,1) string {mustBeMember(options.Display, ["off" "iter"])} = "off"
            end
            obj.TrendDegree = options.TrendDegree;
            obj.ExponentBounds = boundMatrix(options.ExponentBounds, "ExponentBounds");
            if any(obj.ExponentBounds(:) <= 0 | obj.ExponentBounds(:) > 2)
                error("kriging:FitOptions:InvalidBounds", ...
                    "ExponentBounds must lie in (0, 2].");
            end
            obj.LogThetaBounds = boundMatrix(options.LogThetaBounds, "LogThetaBounds");
            obj.NuggetBounds = boundMatrix(options.NuggetBounds, "NuggetBounds");
            if size(obj.NuggetBounds, 2) ~= 1 || obj.NuggetBounds(1) < 0
                error("kriging:FitOptions:InvalidBounds", ...
                    "NuggetBounds must be a pair of non-negative values.");
            end
            obj.NumStarts = options.NumStarts;
            obj.Seed = options.Seed;
            obj.Display = options.Display;
        end
    end
end

function b = boundMatrix(b, name)
% A pair [lower upper] becomes a 2-by-1 column; a 2-by-d matrix is kept.
if isequal(size(b), [1 2])
    b = b(:);
elseif size(b, 1) ~= 2 || isempty(b)
    error("kriging:FitOptions:InvalidBounds", ...
        "%s must be a pair [lower upper] or a 2-by-d matrix.", name);
end
if any(~isfinite(b(:))) || any(b(1, :) > b(2, :))
    error("kriging:FitOptions:InvalidBounds", ...
        "%s must be finite, with lower <= upper.", name);
end
end
