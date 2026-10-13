classdef TrendBasisTest < matlab.unittest.TestCase
    methods (Test)
        function quadraticTermsInOrder(testCase)
            testCase.verifyEqual(kriging.internal.trendBasis([2 3], 2), [1 2 3 4 6 9]);
        end

        function linearTerms(testCase)
            testCase.verifyEqual(kriging.internal.trendBasis([2 3; 4 5], 1), [1 2 3; 1 4 5]);
        end

        function columnCounts(testCase)
            u = zeros(5, 3);
            testCase.verifySize(kriging.internal.trendBasis(u, 0), [5 1]);
            testCase.verifySize(kriging.internal.trendBasis(u, 1), [5 4]);
            testCase.verifySize(kriging.internal.trendBasis(u, 2), [5 10]);
        end
    end
end
