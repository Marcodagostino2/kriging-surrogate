classdef LatinHypercubeTest < matlab.unittest.TestCase
    methods (Test)
        function hasOnePointPerStratum(testCase)
            X = kriging.latinHypercube(15, 4, Seed=3);
            testCase.verifySize(X, [15 4]);
            for k = 1:4
                testCase.verifyEqual(sort(floor(15 * X(:, k))), (0:14)');
            end
        end

        function staysInsideUnitCube(testCase)
            X = kriging.latinHypercube(30, 2);
            testCase.verifyGreaterThan(X, 0);
            testCase.verifyLessThan(X, 1);
        end

        function dependsOnlyOnSeed(testCase)
            a = kriging.latinHypercube(20, 3, Seed=7);
            testCase.verifyEqual(kriging.latinHypercube(20, 3, Seed=7), a);
            testCase.verifyNotEqual(kriging.latinHypercube(20, 3, Seed=8), a);
        end

        function leavesGlobalRandomStateAlone(testCase)
            original = rng;
            testCase.addTeardown(@() rng(original));
            rng(11);
            before = rng;
            kriging.latinHypercube(10, 2, Seed=1);
            testCase.verifyEqual(rng, before);
        end

        function singlePointIsCentre(testCase)
            testCase.verifyEqual(kriging.latinHypercube(1, 3), [0.5 0.5 0.5]);
        end
    end
end
