classdef GlsSolveTest < matlab.unittest.TestCase
    methods (Test)
        function identityCovarianceIsOrdinaryLeastSquares(testCase)
            y = [1; 2; 4; 7];
            H = [ones(4, 1), (1:4)'];
            [coef, weights, sigma2, logDetHalf] = kriging.internal.glsSolve(eye(4), H, y);
            expected = H \ y;
            testCase.verifyEqual(coef, expected, AbsTol=1e-12);
            testCase.verifyEqual(weights, y - H * expected, AbsTol=1e-12);
            testCase.verifyEqual(sigma2, sum((y - H * expected).^2) / 4, AbsTol=1e-12);
            testCase.verifyEqual(logDetHalf, 0);
        end

        function returnsHalfLogDeterminant(testCase)
            K = [4 2; 2 3];
            [~, ~, ~, logDetHalf] = kriging.internal.glsSolve(chol(K, "lower"), ones(2, 1), [1; 2]);
            testCase.verifyEqual(2 * logDetHalf, log(det(K)), AbsTol=1e-12);
        end

        function factorizeFlagsIndefiniteMatrix(testCase)
            [~, ok] = kriging.internal.factorize([1 2; 2 1]);
            testCase.verifyFalse(ok);
        end

        function factorizeReturnsLowerFactor(testCase)
            K = [4 2; 2 3];
            [L, ok] = kriging.internal.factorize(K);
            testCase.verifyTrue(ok);
            testCase.verifyEqual(L, tril(L));
            testCase.verifyEqual(L * L.', K, AbsTol=1e-12);
        end
    end
end
