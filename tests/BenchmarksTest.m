classdef BenchmarksTest < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addExamplesToPath(testCase)
            root = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, "examples")));
        end
    end

    methods (Test)
        function braninHasThreeGlobalMinima(testCase)
            x = [-pi 12.275; pi 2.275; 9.42478 2.475];
            testCase.verifyEqual(benchmarks.branin(x), 0.397887 * ones(3, 1), AbsTol=1e-5);
        end

        function hartmann6GlobalMinimum(testCase)
            x = [0.20169 0.150011 0.476874 0.275332 0.311652 0.6573];
            testCase.verifyEqual(benchmarks.hartmann6(x), -3.32237, AbsTol=1e-5);
        end

        function forresterValues(testCase)
            testCase.verifyEqual(benchmarks.forrester([0; 1]), [4 * sin(-4); 16 * sin(8)], AbsTol=1e-12);
            testCase.verifyEqual(benchmarks.forresterLowFidelity([0; 1]), ...
                [2 * sin(-4); 8 * sin(8) + 10], AbsTol=1e-12);
        end

        function braninPairAtOrigin(testCase)
            % branin(0, 0) = 36 + 10 * (1 - 1/(8*pi)) + 10
            base = 56 - 10 / (8 * pi);
            testCase.verifyEqual(benchmarks.braninHighFidelity([0 0]), base, AbsTol=1e-12);
            testCase.verifyEqual(benchmarks.braninLowFidelity([0 0]), base + 16.2 - 50, AbsTol=1e-12);
        end
    end
end
