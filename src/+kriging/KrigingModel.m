classdef KrigingModel
    % KrigingModel  Kriging surrogate of a scalar function.
    %
    %   [model, info] = kriging.KrigingModel.fit(x, y)
    %   [model, info] = kriging.KrigingModel.fit(x, y, opts, InputBounds=bounds)
    %   [yHat, s2] = model.predict(xq)
    %
    %   x is n-by-d in physical units and y is n-by-1. The inputs are mapped
    %   to the unit cube through InputBounds (2-by-d, default: the range of
    %   x) and the output is standardized; predict undoes both, so yHat and
    %   s2 are in the units of y. s2 is the variance of the latent function:
    %   the nugget is not added to it. The hyperparameters maximize the
    %   concentrated likelihood with the settings in opts (kriging.FitOptions).
    %
    %   info.fval is the best negative log-likelihood and info.starts lists
    %   the outcome of every optimizer start.

    properties (SetAccess = private)
        Options          % kriging.FitOptions used for the fit
        InputBounds      % 2-by-d lower and upper bounds of the inputs
        Theta            % 1-by-d correlation parameters, unit-cube inputs
        Exponents        % 1-by-d kernel exponents
        Nugget           % nugget, relative to the process variance
        ProcessVariance  % process variance, in squared units of y
    end

    properties (Access = private)
        Process          % fitted model in normalized coordinates
        OutputMean
        OutputScale
    end

    methods (Static)
        function [model, info] = fit(x, y, opts, options)
            arguments
                x (:,:) double {mustBeFinite, mustBeNonempty}
                y (:,1) double {mustBeFinite}
                opts (1,1) kriging.FitOptions = kriging.FitOptions()
                options.InputBounds (2,:) double {mustBeFinite} = [min(x, [], 1); max(x, [], 1)]
            end
            [n, d] = size(x);
            if numel(y) ~= n
                error("kriging:KrigingModel:SizeMismatch", ...
                    "x has %d rows but y has %d values.", n, numel(y));
            end
            bounds = options.InputBounds;
            if size(bounds, 2) ~= d
                error("kriging:KrigingModel:BoundsSize", ...
                    "InputBounds has %d columns but x has %d.", size(bounds, 2), d);
            end
            if any(bounds(2, :) <= bounds(1, :))
                error("kriging:KrigingModel:DegenerateBounds", ...
                    "Every input needs an upper bound above its lower bound: remove constant inputs or pass InputBounds.");
            end
            nTrend = size(kriging.internal.trendBasis(zeros(1, d), opts.TrendDegree), 2);
            if n <= nTrend
                error("kriging:KrigingModel:TooFewPoints", ...
                    "A trend of degree %d in %d inputs needs more than %d points, got %d.", ...
                    opts.TrendDegree, d, nTrend, n);
            end
            outputMean = mean(y);
            outputScale = std(y);
            if outputScale == 0
                error("kriging:KrigingModel:ConstantOutput", ...
                    "y is constant: there is nothing to model.");
            end

            u = kriging.internal.toUnit(x, bounds);
            [gp, info] = kriging.internal.fitProcess(u, (y - outputMean) / outputScale, opts);
            model = kriging.KrigingModel(opts, bounds, gp, outputMean, outputScale);
        end
    end

    methods
        function [yHat, s2] = predict(obj, xq)
            arguments
                obj (1,1) kriging.KrigingModel
                xq (:,:) double {mustBeFinite}
            end
            if size(xq, 2) ~= size(obj.InputBounds, 2)
                error("kriging:KrigingModel:InputSize", ...
                    "The model has %d inputs but xq has %d columns.", ...
                    size(obj.InputBounds, 2), size(xq, 2));
            end
            uq = kriging.internal.toUnit(xq, obj.InputBounds);
            if nargout > 1
                [mu, s2] = kriging.internal.predictProcess(obj.Process, uq);
                s2 = s2 * obj.OutputScale^2;
            else
                mu = kriging.internal.predictProcess(obj.Process, uq);
            end
            yHat = mu * obj.OutputScale + obj.OutputMean;
        end
    end

    methods (Access = private)
        function obj = KrigingModel(opts, bounds, gp, outputMean, outputScale)
            obj.Options = opts;
            obj.InputBounds = bounds;
            obj.Theta = gp.theta;
            obj.Exponents = gp.p;
            obj.Nugget = gp.lambda;
            obj.ProcessVariance = gp.sigma2 * outputScale^2;
            obj.Process = gp;
            obj.OutputMean = outputMean;
            obj.OutputScale = outputScale;
        end
    end
end
