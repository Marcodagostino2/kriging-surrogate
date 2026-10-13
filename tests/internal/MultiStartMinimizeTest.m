classdef MultiStartMinimizeTest < matlab.unittest.TestCase
    methods (Test)
        function findsMinimumInsideBox(testCase)
            c = [0.3 -1.2 2];
            opts = kriging.FitOptions(NumStarts=3);
            [z, info] = kriging.internal.multiStartMinimize(@(z) quadratic(z, c), ...
                [-5 -5 -5], [5 5 5], opts);
            testCase.verifyEqual(z, c, AbsTol=1e-6);
            testCase.verifyEqual(info.fval, 0, AbsTol=1e-10);
            testCase.verifyNumElements(info.starts, 3);
        end

        function firstStartIsMidpoint(testCase)
            [~, info] = kriging.internal.multiStartMinimize(@(z) quadratic(z, [0 0]), ...
                [0 2], [4 6], kriging.FitOptions(NumStarts=2));
            testCase.verifyEqual(info.starts(1).z0, [2 4]);
        end

        function startsDependOnlyOnSeed(testCase)
            opts = kriging.FitOptions(NumStarts=4, Seed=9);
            objective = @(z) quadratic(z, [0 0]);
            [~, a] = kriging.internal.multiStartMinimize(objective, [-1 -1], [1 1], opts);
            [~, b] = kriging.internal.multiStartMinimize(objective, [-1 -1], [1 1], opts);
            testCase.verifyEqual(vertcat(b.starts.z0), vertcat(a.starts.z0));
        end

        function keepsFixedVariablesFixed(testCase)
            z = kriging.internal.multiStartMinimize(@(z) quadratic(z, [1 1]), ...
                [0 2], [3 2], kriging.FitOptions(NumStarts=1));
            testCase.verifyEqual(z, [1 2], AbsTol=1e-8);
        end
    end
end

function [f, g] = quadratic(z, c)
f = sum((z - c).^2);
g = 2 * (z - c);
end
