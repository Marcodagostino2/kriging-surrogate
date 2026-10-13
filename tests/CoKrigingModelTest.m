classdef CoKrigingModelTest < matlab.unittest.TestCase
    methods (Test)
        function recoversScaleOfLinearRelation(testCase)
            f = @(x) sin(8 * x) + x;
            xLow = linspace(0, 1, 15)';
            xHigh = xLow(1:3:end);
            model = kriging.CoKrigingModel.fit(xLow, f(xLow), xHigh, 2 * f(xHigh) + 1);
            testCase.verifyEqual(model.Rho, 2, AbsTol=0.05);
        end

        function interpolatesHighFidelityData(testCase)
            [xLow, yLow, xHigh, yHigh] = forresterData();
            opts = kriging.FitOptions(NuggetBounds=[1e-10 1e-8]);
            model = kriging.CoKrigingModel.fit(xLow, yLow, xHigh, yHigh, ...
                LowFidelity=opts, Discrepancy=opts);
            [yHat, s2] = model.predict(xHigh);
            testCase.verifyEqual(yHat, yHigh, AbsTol=1e-3);
            testCase.verifyLessThan(s2, 1e-3);
        end

        function beatsKrigingOnExpensiveDataAlone(testCase)
            [xLow, yLow, xHigh, yHigh] = forresterData();
            coKriging = kriging.CoKrigingModel.fit(xLow, yLow, xHigh, yHigh);
            krigingOnly = kriging.KrigingModel.fit(xHigh, yHigh);
            xq = linspace(0, 1, 101)';
            co = kriging.errorMetrics(forrester(xq), coKriging.predict(xq));
            kr = kriging.errorMetrics(forrester(xq), krigingOnly.predict(xq));
            testCase.verifyLessThan(co.RMSE, 0.5 * kr.RMSE);
        end

        function fitIsReproducible(testCase)
            [xLow, yLow, xHigh, yHigh] = forresterData();
            testCase.verifyEqual(kriging.CoKrigingModel.fit(xLow, yLow, xHigh, yHigh), ...
                kriging.CoKrigingModel.fit(xLow, yLow, xHigh, yHigh));
        end

        function rejectsDifferentInputCounts(testCase)
            testCase.verifyError(@() kriging.CoKrigingModel.fit(rand(10, 2), rand(10, 1), ...
                rand(4, 3), rand(4, 1)), "kriging:CoKrigingModel:InputSize");
        end

        function rejectsMismatchedSizes(testCase)
            testCase.verifyError(@() kriging.CoKrigingModel.fit(rand(10, 2), rand(10, 1), ...
                rand(4, 2), rand(5, 1)), "kriging:CoKrigingModel:SizeMismatch");
        end

        function rejectsConstantHighFidelityOutput(testCase)
            [xLow, yLow, xHigh] = forresterData();
            testCase.verifyError(@() kriging.CoKrigingModel.fit(xLow, yLow, xHigh, ones(4, 1)), ...
                "kriging:CoKrigingModel:ConstantOutput");
        end

        function rejectsTooFewHighFidelityPoints(testCase)
            [xLow, yLow] = forresterData();
            opts = kriging.FitOptions(TrendDegree=1);
            testCase.verifyError(@() kriging.CoKrigingModel.fit(xLow, yLow, [0; 0.5; 1], ...
                forrester([0; 0.5; 1]), Discrepancy=opts), "kriging:CoKrigingModel:TooFewPoints");
        end

        function singleQueryGivesScalars(testCase)
            [xLow, yLow, xHigh, yHigh] = forresterData();
            model = kriging.CoKrigingModel.fit(xLow, yLow, xHigh, yHigh);
            [yHat, s2] = model.predict(0.3);
            testCase.verifySize(yHat, [1 1]);
            testCase.verifySize(s2, [1 1]);
        end
    end
end

function [xLow, yLow, xHigh, yHigh] = forresterData()
% The textbook case of Forrester et al. (2008).
xLow = (0:0.1:1)';
xHigh = [0; 0.4; 0.6; 1];
yLow = 0.5 * forrester(xLow) + 10 * (xLow - 0.5) + 5;
yHigh = forrester(xHigh);
end

function y = forrester(x)
y = (6 * x - 2).^2 .* sin(12 * x - 4);
end
