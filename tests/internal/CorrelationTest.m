classdef CorrelationTest < matlab.unittest.TestCase
    properties
        U = reshape(mod((1:36) * 0.6180339887498949, 1), 12, 3)
    end

    methods (Test)
        function matchesFormulaForOnePair(testCase)
            actual = kriging.internal.correlation([0.1 0.7], [0.4 0.2], [2 0.5], [2 1.5]);
            expected = exp(-(2 * 0.3^2 + 0.5 * 0.5^1.5));
            testCase.verifyEqual(actual, expected, RelTol=1e-14);
        end

        function isSymmetricWithUnitDiagonal(testCase)
            R = kriging.internal.correlation(testCase.U, testCase.U, [1 3 0.2], [2 1.8 1.2]);
            testCase.verifyEqual(R, R.');
            testCase.verifyEqual(diag(R), ones(12, 1));
        end

        function crossBlockMatchesFullMatrix(testCase)
            theta = [4 0.7 2];
            p = [2 1.6 1.9];
            full = kriging.internal.correlation(testCase.U, testCase.U, theta, p);
            cross = kriging.internal.correlation(testCase.U(1:4, :), testCase.U(5:end, :), theta, p);
            testCase.verifyEqual(cross, full(1:4, 5:end), AbsTol=1e-15);
        end
    end
end
