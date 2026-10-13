classdef ProcessTest < matlab.unittest.TestCase
    methods (Test)
        function interpolatesWithTinyNugget(testCase)
            u = linspace(0, 1, 8)';
            y = sin(2 * pi * u);
            gp = kriging.internal.buildProcess(u, y, 10, 2, 1e-10, 0);
            [mu, s2] = kriging.internal.predictProcess(gp, u);
            testCase.verifyEqual(mu, y, AbsTol=1e-6);
            testCase.verifyLessThan(s2, 1e-6);
        end

        function varianceGrowsAwayFromData(testCase)
            gp = kriging.internal.buildProcess([0; 0.1; 0.2], [0; 1; 0], 20, 2, 1e-8, 0);
            [~, s2] = kriging.internal.predictProcess(gp, [0.1; 0.3; 0.6]);
            testCase.verifyLessThan(s2(1), s2(2));
            testCase.verifyLessThan(s2(2), s2(3));
        end

        function extraRegressorJoinsTheTrend(testCase)
            u = linspace(0, 1, 10)';
            c = cos(3 * u);
            gp = kriging.internal.buildProcess(u, 2 * c + 1, 5, 2, 1e-6, 0, c);
            testCase.verifyEqual(gp.coef, [1; 2], AbsTol=1e-6);
        end

        function rejectsIndefiniteMatrix(testCase)
            testCase.verifyError(@() kriging.internal.buildProcess( ...
                [0; 0.5; 1], [1; 2; 3], 1, 2, -0.9, 0), ...
                "kriging:buildProcess:NotPositiveDefinite");
        end

        function fitRecoversSmoothFunction(testCase)
            f = @(u) sin(3 * u(:, 1)) + u(:, 2).^2;
            u = kriging.latinHypercube(20, 2, Seed=2);
            [gp, info] = kriging.internal.fitProcess(u, f(u), kriging.FitOptions(NumStarts=3));
            uq = kriging.latinHypercube(200, 2, Seed=3);
            testCase.verifyLessThan(max(abs(kriging.internal.predictProcess(gp, uq) - f(uq))), 0.05);
            testCase.verifyNumElements(info.starts, 3);
        end
    end
end
