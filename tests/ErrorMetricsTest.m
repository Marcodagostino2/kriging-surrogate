classdef ErrorMetricsTest < matlab.unittest.TestCase
    methods (Test)
        function matchesHandComputedValues(testCase)
            m = kriging.errorMetrics([1; 2; 3; 4], [1; 2; 3; 5]);
            testCase.verifyEqual(m.RMSE, 0.5, AbsTol=1e-15);
            testCase.verifyEqual(m.MAE, 0.25, AbsTol=1e-15);
            testCase.verifyEqual(m.R2, 0.8, AbsTol=1e-15);
        end

        function perfectPrediction(testCase)
            m = kriging.errorMetrics([3; 1; 2], [3; 1; 2]);
            testCase.verifyEqual([m.RMSE m.MAE m.R2], [0 0 1]);
        end

        function rejectsDifferentLengths(testCase)
            testCase.verifyError(@() kriging.errorMetrics([1; 2; 3], [1; 2]), ...
                "kriging:errorMetrics:SizeMismatch");
        end
    end
end
