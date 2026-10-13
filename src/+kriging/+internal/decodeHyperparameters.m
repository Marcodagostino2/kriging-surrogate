function [theta, p, lambda] = decodeHyperparameters(z, d)
% decodeHyperparameters  Split z = [log10(theta), p, lambda] for d inputs.
theta = 10.^z(1:d);
p = z(d+1:2*d);
lambda = z(2*d+1);
end
