function u = toUnit(x, bounds)
% toUnit  Map points from the box bounds(1,:)..bounds(2,:) to the unit cube.
%   Points outside the box map outside [0, 1]; nothing is clipped.
u = (x - bounds(1, :)) ./ (bounds(2, :) - bounds(1, :));
end
