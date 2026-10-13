function applyFigureStyle(fig, widthFraction)
% applyFigureStyle  Style a README figure in place.
%
%   applyFigureStyle(fig, widthFraction) sizes fig at widthFraction of a
%   16.54 cm reference width, drawn at 1.5 times the size it is shown at
%   and keeping its aspect ratio, and applies the house style: LaTeX text,
%   9 pt tick labels (0.8 of that when the figure has more than one axes),
%   labels and titles 10% larger, legends at 0.8 below the axes, 1.5 pt
%   lines, grid, box and a white background. Lines drawn in a colour of
%   MATLAB's default colour order take the colour at the same position in
%   the palette below; any other colour, black included, is kept. Apply it
%   once per figure: marker sizes are scaled at every call.
arguments
    fig (1,1) matlab.ui.Figure
    widthFraction (1,1) double {mustBePositive, mustBeLessThanOrEqual(widthFraction, 1)}
end
scale = 1.5;
referenceWidth = 16.54;   % cm
palette = ["#4658A9", "#D3212D", "#00A86B", "#FDAF00", "#E94196", "#FF5A36", "#6CC407"];
defaultColors = get(groot, "FactoryAxesColorOrder");

fig.Units = "centimeters";
aspect = fig.Position(3) / fig.Position(4);
width = scale * referenceWidth * widthFraction;
fig.Position(3:4) = [width, width / aspect];
fig.Color = "w";

axesList = findobj(fig, "Type", "axes");
fontSize = scale * 9;
if numel(axesList) > 1
    fontSize = 0.8 * fontSize;
end
for ax = reshape(axesList, 1, [])
    set(ax, "FontSize", fontSize, "LabelFontSizeMultiplier", 1.1, ...
        "TitleFontSizeMultiplier", 1.1, "TickLabelInterpreter", "latex", ...
        "Color", "w", "LineWidth", 0.5, "Box", "on");
    grid(ax, "on");
    set([ax.XLabel, ax.YLabel, ax.Title], "Interpreter", "latex");
    for h = reshape(findobj(ax, "Type", "line"), 1, [])
        [isDefault, k] = ismember(round(h.Color, 4), round(defaultColors, 4), "rows");
        if isDefault
            h.Color = palette(k);
        end
        if h.LineStyle ~= "none"
            h.LineWidth = scale * 1.5;
        end
        h.MarkerSize = scale * h.MarkerSize;
    end
end
for cb = reshape(findobj(fig, "Type", "colorbar"), 1, [])
    set(cb, "FontSize", fontSize, "TickLabelInterpreter", "latex");
end
for lg = reshape(findobj(fig, "Type", "legend"), 1, [])
    set(lg, "Interpreter", "latex", "FontSize", 0.8 * scale * 9, "Box", "on", ...
        "Location", "southoutside", "Orientation", "horizontal", ...
        "NumColumns", min(3, numel(lg.String)), "Units", "normalized");
    % fewer columns until the legend fits the width of the figure
    drawnow;
    while lg.Position(3) > 1 && lg.NumColumns > 1
        lg.NumColumns = lg.NumColumns - 1;
        drawnow;
    end
end
end
