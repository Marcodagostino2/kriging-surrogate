classdef FitOptionsTest < matlab.unittest.TestCase
    methods (Test)
        function hasDocumentedDefaults(testCase)
            opts = kriging.FitOptions();
            testCase.verifyEqual(opts.TrendDegree, 0);
            testCase.verifyEqual(opts.ExponentBounds, [2; 2]);
            testCase.verifyEqual(opts.LogThetaBounds, [-5; 3]);
            testCase.verifyEqual(opts.NuggetBounds, [1e-5; 1e-2]);
            testCase.verifyEqual(opts.NumStarts, 5);
            testCase.verifyEqual(opts.Seed, 0);
            testCase.verifyEqual(opts.Display, "off");
        end

        function storesPairAsColumn(testCase)
            opts = kriging.FitOptions(ExponentBounds=[1.5 2]);
            testCase.verifyEqual(opts.ExponentBounds, [1.5; 2]);
        end

        function keepsPerInputMatrix(testCase)
            bounds = [-2 -3 -4; 1 2 3];
            opts = kriging.FitOptions(LogThetaBounds=bounds);
            testCase.verifyEqual(opts.LogThetaBounds, bounds);
        end

        function rejectsLowerAboveUpper(testCase)
            testCase.verifyError(@() kriging.FitOptions(LogThetaBounds=[3 -5]), ...
                "kriging:FitOptions:InvalidBounds");
        end

        function rejectsExponentAboveTwo(testCase)
            testCase.verifyError(@() kriging.FitOptions(ExponentBounds=[1 2.5]), ...
                "kriging:FitOptions:InvalidBounds");
        end

        function rejectsBadShape(testCase)
            testCase.verifyError(@() kriging.FitOptions(LogThetaBounds=[1 2 3]), ...
                "kriging:FitOptions:InvalidBounds");
        end

        function rejectsNegativeNugget(testCase)
            testCase.verifyError(@() kriging.FitOptions(NuggetBounds=[-1 1]), ...
                "kriging:FitOptions:InvalidBounds");
        end

        function rejectsUnknownTrendDegree(testCase)
            testCase.verifyError(@() kriging.FitOptions(TrendDegree=3), ?MException);
        end
    end
end
