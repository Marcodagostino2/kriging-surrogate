classdef CoKrigingModel
    % CoKrigingModel  AR(1) co-Kriging of an expensive function helped by a
    % cheap approximation of it.
    %
    %   [model, info] = kriging.CoKrigingModel.fit(xLow, yLow, xHigh, yHigh)
    %   [model, info] = kriging.CoKrigingModel.fit(..., LowFidelity=optsLow, ...
    %       Discrepancy=optsDisc, InputBounds=bounds)
    %   [yHat, s2] = model.predict(xq)
    %
    %   The expensive response is modelled as yHigh(x) = rho*yLow(x) +
    %   delta(x), with one Kriging model for the cheap data and one for the
    %   discrepancy delta (Kennedy and O'Hagan, 2000). LowFidelity and
    %   Discrepancy are the kriging.FitOptions of the two models. Both data
    %   sets share the unit-cube scaling of InputBounds (default: the range
    %   of [xLow; xHigh]) and are standardized with the mean and spread of
    %   yHigh. predict returns the high-fidelity mean and latent variance in
    %   the units of yHigh.
    %
    %   info.LowFidelity and info.Discrepancy are the optimizer reports of
    %   the two fits.

    properties (SetAccess = private)
        LowFidelityOptions   % kriging.FitOptions of the cheap model
        DiscrepancyOptions   % kriging.FitOptions of the discrepancy
        InputBounds          % 2-by-d lower and upper bounds of the inputs
        Rho                  % scale between the two fidelities
    end

    properties (Access = private)
        Process              % joint model in normalized coordinates
        OutputMean
        OutputScale
    end

    methods (Static)
        function [model, info] = fit(xLow, yLow, xHigh, yHigh, options)
            arguments
                xLow (:,:) double {mustBeFinite, mustBeNonempty}
                yLow (:,1) double {mustBeFinite}
                xHigh (:,:) double {mustBeFinite, mustBeNonempty}
                yHigh (:,1) double {mustBeFinite}
                options.LowFidelity (1,1) kriging.FitOptions = kriging.FitOptions()
                options.Discrepancy (1,1) kriging.FitOptions = kriging.FitOptions()
                options.InputBounds (2,:) double {mustBeFinite} = zeros(2, 0)
            end
            d = size(xLow, 2);
            if size(xHigh, 2) ~= d
                error("kriging:CoKrigingModel:InputSize", ...
                    "xLow has %d columns but xHigh has %d.", d, size(xHigh, 2));
            end
            if numel(yLow) ~= size(xLow, 1) || numel(yHigh) ~= size(xHigh, 1)
                error("kriging:CoKrigingModel:SizeMismatch", ...
                    "Each y needs one value per row of its x.");
            end
            bounds = options.InputBounds;
            if isempty(bounds)
                bounds = [min([xLow; xHigh], [], 1); max([xLow; xHigh], [], 1)];
            end
            if size(bounds, 2) ~= d
                error("kriging:CoKrigingModel:BoundsSize", ...
                    "InputBounds has %d columns but the data have %d.", size(bounds, 2), d);
            end
            if any(bounds(2, :) <= bounds(1, :))
                error("kriging:CoKrigingModel:DegenerateBounds", ...
                    "Every input needs an upper bound above its lower bound: remove constant inputs or pass InputBounds.");
            end
            nLowTrend = size(kriging.internal.trendBasis(zeros(1, d), ...
                options.LowFidelity.TrendDegree), 2);
            nDiscTrend = size(kriging.internal.trendBasis(zeros(1, d), ...
                options.Discrepancy.TrendDegree), 2) + 1;
            if numel(yLow) <= nLowTrend || numel(yHigh) <= nDiscTrend
                error("kriging:CoKrigingModel:TooFewPoints", ...
                    "Need more than %d low-fidelity and %d high-fidelity points, got %d and %d.", ...
                    nLowTrend, nDiscTrend, numel(yLow), numel(yHigh));
            end
            outputMean = mean(yHigh);
            outputScale = std(yHigh);
            if outputScale == 0 || std(yLow) == 0
                error("kriging:CoKrigingModel:ConstantOutput", ...
                    "yLow and yHigh must both vary: there is nothing to model.");
            end

            uLow = kriging.internal.toUnit(xLow, bounds);
            uHigh = kriging.internal.toUnit(xHigh, bounds);
            zLow = (yLow - outputMean) / outputScale;
            zHigh = (yHigh - outputMean) / outputScale;
            info = struct();
            [gpLow, info.LowFidelity] = kriging.internal.fitProcess(uLow, zLow, options.LowFidelity);
            zLowAtHigh = kriging.internal.predictProcess(gpLow, uHigh);
            [gpDisc, rho, info.Discrepancy] = kriging.internal.fitDiscrepancy( ...
                uHigh, zHigh, zLowAtHigh, options.Discrepancy);
            cg = kriging.internal.assembleCoKriging(gpLow, gpDisc, rho, zLow, zHigh);
            model = kriging.CoKrigingModel(options.LowFidelity, options.Discrepancy, ...
                bounds, cg, outputMean, outputScale);
        end
    end

    methods
        function [yHat, s2] = predict(obj, xq)
            arguments
                obj (1,1) kriging.CoKrigingModel
                xq (:,:) double {mustBeFinite}
            end
            if size(xq, 2) ~= size(obj.InputBounds, 2)
                error("kriging:CoKrigingModel:InputSize", ...
                    "The model has %d inputs but xq has %d columns.", ...
                    size(obj.InputBounds, 2), size(xq, 2));
            end
            uq = kriging.internal.toUnit(xq, obj.InputBounds);
            if nargout > 1
                [mu, s2] = kriging.internal.predictCoKriging(obj.Process, uq);
                s2 = s2 * obj.OutputScale^2;
            else
                mu = kriging.internal.predictCoKriging(obj.Process, uq);
            end
            yHat = mu * obj.OutputScale + obj.OutputMean;
        end
    end

    methods (Access = private)
        function obj = CoKrigingModel(optsLow, optsDisc, bounds, cg, outputMean, outputScale)
            obj.LowFidelityOptions = optsLow;
            obj.DiscrepancyOptions = optsDisc;
            obj.InputBounds = bounds;
            obj.Rho = cg.rho;
            obj.Process = cg;
            obj.OutputMean = outputMean;
            obj.OutputScale = outputScale;
        end
    end
end
