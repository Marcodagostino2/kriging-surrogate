classdef ToUnitTest < matlab.unittest.TestCase
    methods (Test)
        function mapsBoundsToZeroAndOne(testCase)
            u = kriging.internal.toUnit([-5 0; 10 15; 2.5 7.5], [-5 0; 10 15]);
            testCase.verifyEqual(u, [0 0; 1 1; 0.5 0.5]);
        end

        function unitBoundsLeaveDataUntouched(testCase)
            % Models trained on data that are already normalized must see
            % exactly the same numbers.
            x = [0.123456789012345 0.987654321098765];
            testCase.verifyEqual(kriging.internal.toUnit(x, [0 0; 1 1]), x);
        end
    end
end
