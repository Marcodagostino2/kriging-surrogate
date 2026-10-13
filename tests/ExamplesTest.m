classdef ExamplesTest < matlab.unittest.TestCase
    properties (TestParameter)
        example = {"braninKriging", "hartmann6Convergence", "airfoilNoise", ...
            "forresterCoKriging", "braninCoKriging"}
    end

    methods (TestClassSetup)
        function setUp(testCase)
            root = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, "src")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, "examples")));
            visibility = get(groot, "DefaultFigureVisible");
            testCase.addTeardown(@() set(groot, "DefaultFigureVisible", visibility));
            set(groot, "DefaultFigureVisible", "off");
        end
    end

    methods (Test)
        function runsAndReportsFiniteResults(testCase, example)
            results = feval(example);
            testCase.addTeardown(@() close(results.figure));
            testCase.verifyClass(results.figure, "matlab.ui.Figure");
            values = struct2cell(rmfield(results, "figure"));
            for k = 1:numel(values)
                testCase.verifyTrue(all(isfinite(values{k})));
            end
        end
    end
end
