classdef HyperparametersTest < matlab.unittest.TestCase
    methods (Test)
        function defaultBounds(testCase)
            [lb, ub] = kriging.internal.hyperparameterBounds(kriging.FitOptions(), 3);
            testCase.verifyEqual(lb, [-5 -5 -5 2 2 2 1e-5]);
            testCase.verifyEqual(ub, [3 3 3 2 2 2 1e-2]);
        end

        function perInputBounds(testCase)
            opts = kriging.FitOptions(LogThetaBounds=[-1 -2; 1 2], ExponentBounds=[1 1.5; 2 2]);
            [lb, ub] = kriging.internal.hyperparameterBounds(opts, 2);
            testCase.verifyEqual(lb, [-1 -2 1 1.5 1e-5]);
            testCase.verifyEqual(ub, [1 2 2 2 1e-2]);
        end

        function rejectsWrongNumberOfColumns(testCase)
            opts = kriging.FitOptions(LogThetaBounds=[-1 -2 -3; 1 2 3]);
            testCase.verifyError(@() kriging.internal.hyperparameterBounds(opts, 2), ...
                "kriging:FitOptions:BoundsSize");
        end

        function decodeSplitsTheVector(testCase)
            [theta, p, lambda] = kriging.internal.decodeHyperparameters([0 1 1.5 2 1e-3], 2);
            testCase.verifyEqual(theta, [1 10]);
            testCase.verifyEqual(p, [1.5 2]);
            testCase.verifyEqual(lambda, 1e-3);
        end
    end
end
