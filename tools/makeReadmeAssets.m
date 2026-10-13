function makeReadmeAssets()
% makeReadmeAssets  Run the examples, save their figures under docs/figures
% and print the results table of README.md.
root = fileparts(fileparts(mfilename("fullpath")));
oldPath = addpath(fullfile(root, "src"), fullfile(root, "examples"));
restorePath = onCleanup(@() path(oldPath));
figureDir = fullfile(root, "docs", "figures");
if ~isfolder(figureDir)
    mkdir(figureDir);
end

branin = braninKriging();
hartmann = hartmann6Convergence();
airfoil = airfoilNoise();
forrester = forresterCoKriging();
braninPair = braninCoKriging();

saveAndClose(branin.figure, fullfile(figureDir, "branin-kriging.png"));
saveAndClose(hartmann.figure, fullfile(figureDir, "hartmann6-convergence.png"));
saveAndClose(airfoil.figure, fullfile(figureDir, "airfoil-parity.png"));
saveAndClose(forrester.figure, fullfile(figureDir, "forrester-cokriging.png"));
saveAndClose(braninPair.figure, fullfile(figureDir, "branin-cokriging.png"));

fprintf("\n| Example | Data | Result |\n|---|---|---|\n");
fprintf("| `braninKriging` | %d samples of the Branin function | RMSE %.3f on a 50 x 50 grid, R<sup>2</sup> %.4f |\n", ...
    branin.nTrain, branin.rmse, branin.r2);
fprintf("| `hartmann6Convergence` | %s samples of the 6-D Hartmann function | test RMSE from %.3f to %.3f |\n", ...
    strjoin(string(hartmann.sizes), ", "), hartmann.rmse(1), hartmann.rmse(end));
fprintf("| `airfoilNoise` | %d measured rows | test RMSE %.2f dB, R<sup>2</sup> %.3f, noise from the nugget %.2f dB |\n", ...
    airfoil.nTrain, airfoil.rmse, airfoil.r2, airfoil.noiseStd);
fprintf("| `forresterCoKriging` | %d cheap and %d expensive samples | RMSE %.3f with co-Kriging (rho %.2f), %.3f with Kriging |\n", ...
    forrester.nLow, forrester.nHigh, forrester.rmseCoKriging, forrester.rho, forrester.rmseKriging);
fprintf("| `braninCoKriging` | %d cheap and %d expensive samples | RMSE %.3f with co-Kriging (rho %.3f), %.3f with Kriging: the fidelities correlate at %.2f only |\n", ...
    braninPair.nLow, braninPair.nHigh, braninPair.rmseCoKriging, braninPair.rho, ...
    braninPair.rmseKriging, braninPair.correlation);
end

function saveAndClose(fig, file)
exportgraphics(fig, file, Resolution=150, BackgroundColor="white");
close(fig);
end
