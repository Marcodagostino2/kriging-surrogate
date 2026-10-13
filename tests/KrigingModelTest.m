classdef KrigingModelTest < matlab.unittest.TestCase
    methods (Test)
        function interpolatesTrainingData(testCase)
            x = linspace(-3, 5, 9)';
            y = 10 * sin(x) + 50;
            opts = kriging.FitOptions(NuggetBounds=[1e-10 1e-8]);
            model = kriging.KrigingModel.fit(x, y, opts);
            [yHat, s2] = model.predict(x);
            testCase.verifyEqual(yHat, y, AbsTol=1e-3);
            testCase.verifyLessThan(s2, 1e-4);
        end

        function invariantToAffineInputScaling(testCase)
            x = kriging.latinHypercube(15, 2, Seed=1);
            y = sin(4 * x(:, 1)) .* x(:, 2);
            xq = kriging.latinHypercube(30, 2, Seed=2);
            scale = [1000 0.01];
            shift = [-50 3];
            a = kriging.KrigingModel.fit(x, y, kriging.FitOptions(), InputBounds=[0 0; 1 1]);
            b = kriging.KrigingModel.fit(x .* scale + shift, y, kriging.FitOptions(), ...
                InputBounds=[shift; scale + shift]);
            testCase.verifyEqual(b.predict(xq .* scale + shift), a.predict(xq), AbsTol=1e-4);
        end

        function fitIsReproducible(testCase)
            x = kriging.latinHypercube(12, 2, Seed=4);
            y = x(:, 1).^2 - x(:, 2);
            testCase.verifyEqual(kriging.KrigingModel.fit(x, y), kriging.KrigingModel.fit(x, y));
        end

        function reportsProcessVarianceInOutputUnits(testCase)
            x = kriging.latinHypercube(15, 2, Seed=6);
            y = cos(3 * x(:, 1)) + x(:, 2);
            a = kriging.KrigingModel.fit(x, y);
            b = kriging.KrigingModel.fit(x, 100 * y);
            testCase.verifyEqual(b.Theta, a.Theta, RelTol=1e-4);
            testCase.verifyEqual(b.ProcessVariance, 1e4 * a.ProcessVariance, RelTol=1e-4);
        end

        function rejectsMismatchedSizes(testCase)
            testCase.verifyError(@() kriging.KrigingModel.fit(rand(10, 2), rand(9, 1)), ...
                "kriging:KrigingModel:SizeMismatch");
        end

        function rejectsBoundsOfWrongWidth(testCase)
            x = kriging.latinHypercube(10, 2);
            testCase.verifyError(@() kriging.KrigingModel.fit(x, x(:, 1), ...
                kriging.FitOptions(), InputBounds=[0 0 0; 1 1 1]), ...
                "kriging:KrigingModel:BoundsSize");
        end

        function rejectsConstantInput(testCase)
            x = kriging.latinHypercube(10, 2);
            x(:, 2) = 0.5;
            testCase.verifyError(@() kriging.KrigingModel.fit(x, x(:, 1)), ...
                "kriging:KrigingModel:DegenerateBounds");
        end

        function rejectsConstantOutput(testCase)
            x = kriging.latinHypercube(10, 2);
            testCase.verifyError(@() kriging.KrigingModel.fit(x, 3 * ones(10, 1)), ...
                "kriging:KrigingModel:ConstantOutput");
        end

        function rejectsTooFewPoints(testCase)
            x = kriging.latinHypercube(5, 2);
            testCase.verifyError(@() kriging.KrigingModel.fit(x, x(:, 1), ...
                kriging.FitOptions(TrendDegree=2)), "kriging:KrigingModel:TooFewPoints");
        end

        function rejectsNonFiniteData(testCase)
            x = kriging.latinHypercube(10, 2);
            x(3, 1) = NaN;
            testCase.verifyError(@() kriging.KrigingModel.fit(x, rand(10, 1)), ?MException);
        end

        function rejectsQueryOfWrongWidth(testCase)
            x = kriging.latinHypercube(10, 2);
            model = kriging.KrigingModel.fit(x, sum(x, 2));
            testCase.verifyError(@() model.predict(rand(4, 3)), "kriging:KrigingModel:InputSize");
        end

        function rejectsNonFiniteQuery(testCase)
            x = kriging.latinHypercube(10, 2);
            model = kriging.KrigingModel.fit(x, sum(x, 2));
            testCase.verifyError(@() model.predict([NaN 0.5]), ?MException);
        end

        function toleratesDuplicatePoints(testCase)
            x = linspace(0, 1, 8)';
            x = [x; x(3)];
            model = kriging.KrigingModel.fit(x, sin(4 * x));
            testCase.verifyTrue(all(isfinite(model.predict(x))));
        end

        function extrapolatesWithGrowingVariance(testCase)
            x = linspace(0, 1, 8)';
            model = kriging.KrigingModel.fit(x, sin(4 * x));
            [yHat, s2] = model.predict([0.5; 1.1; 3]);
            testCase.verifyTrue(all(isfinite(yHat)));
            testCase.verifyLessThan(s2(1), s2(2));
            testCase.verifyLessThan(s2(2), s2(3));
        end

        function singleQueryGivesScalars(testCase)
            x = linspace(0, 1, 8)';
            model = kriging.KrigingModel.fit(x, sin(4 * x));
            [yHat, s2] = model.predict(0.3);
            testCase.verifySize(yHat, [1 1]);
            testCase.verifySize(s2, [1 1]);
        end
    end
end
