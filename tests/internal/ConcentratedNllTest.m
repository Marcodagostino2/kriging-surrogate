classdef ConcentratedNllTest < matlab.unittest.TestCase
    properties
        U
        Y
    end

    methods (TestMethodSetup)
        function makeData(testCase)
            testCase.U = reshape(mod((1:30) * 0.6180339887498949, 1), 15, 2);
            y = sin(3 * testCase.U(:, 1)) + testCase.U(:, 2).^2;
            testCase.Y = (y - mean(y)) / std(y);
        end
    end

    methods (Test)
        function gradientMatchesFiniteDifferences(testCase)
            H = kriging.internal.trendBasis(testCase.U, 1);
            testCase.checkGradient([0.2 -0.3 1.7 1.9 1e-3], H);
        end

        function gradientWithExtraRegressor(testCase)
            H = [kriging.internal.trendBasis(testCase.U, 0), cos(2 * testCase.U(:, 1))];
            testCase.checkGradient([0.5 0.1 2 2 1e-2], H);
        end

        function lossMatchesDefinition(testCase)
            u = testCase.U;
            y = testCase.Y;
            H = ones(15, 1);
            R = exp(-(10^0.2 * (u(:, 1) - u(:, 1)').^2 + 10^-0.3 * (u(:, 2) - u(:, 2)').^2));
            K = R + 1e-3 * eye(15);
            coef = (H' * (K \ H)) \ (H' * (K \ y));
            r = y - H * coef;
            sigma2 = r' * (K \ r) / 15;
            expected = 0.5 * (15 * log(sigma2) + log(det(K)));
            loss = kriging.internal.concentratedNll([0.2 -0.3 2 2 1e-3], u, y, H);
            testCase.verifyEqual(loss, expected, RelTol=1e-8);
        end

        function penaltyWhenNotPositiveDefinite(testCase)
            % A negative nugget makes R + lambda*I indefinite.
            [loss, grad] = kriging.internal.concentratedNll([0 0 2 2 -0.5], ...
                testCase.U, testCase.Y, ones(15, 1));
            testCase.verifyEqual(loss, 1e6);
            testCase.verifyEqual(grad, zeros(1, 5));
        end
    end

    methods
        function checkGradient(testCase, z, H)
            nll = @(z) kriging.internal.concentratedNll(z, testCase.U, testCase.Y, H);
            [~, grad] = nll(z);
            fd = zeros(size(z));
            for k = 1:numel(z)
                h = 1e-6 * max(1, abs(z(k)));
                zp = z;
                zp(k) = zp(k) + h;
                zm = z;
                zm(k) = zm(k) - h;
                fd(k) = (nll(zp) - nll(zm)) / (2 * h);
            end
            testCase.verifyEqual(grad, fd, RelTol=1e-4, AbsTol=1e-6);
        end
    end
end
