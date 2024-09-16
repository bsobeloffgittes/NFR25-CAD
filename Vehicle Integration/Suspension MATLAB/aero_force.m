function [L, D, dL_x] = aero_force(v,param)
%AERO_DOWNFORCE Gets the downforce from aero acting on each tire
%   Inputs:
%       v: scalar velocity of the car (in/s)
%       const: constants struct
%
%   Outputs:
%       F_z: row vector of the downforce from aero on each wheel (lbf),
%           - values are negative


% longitudinal distance from CP to front TCPs
a_cp = abs(param.fr.tcp(1) - param.cp(1));
% longitudinal distance from CP to rear TCPs
b_cp = abs(param.rr.tcp(1) - param.cp(1));

L = -param.C_l .* param.rho .* (v .^ 2) .* param.wing_area .* 0.5;

D = param.C_d .* param.rho .* (v .^ 2) .* param.frontal_area .* 0.5;

F_zf = (L .* b_cp + D .* param.cp(3)) ./ (a_cp + b_cp);
F_zr = L - F_zf;

dL_x = (F_zf - F_zr) / 2;

    
end