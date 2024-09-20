function [Rz] = Rz(alpha)
%RZ Creates rotation matrix about z-axis
%   INPUT:
%       alpha - rotation angle in degrees
%   OUtPUT:
%       Rz - 3x3 rotation matrix


Rz = [cosd(alpha), -sind(alpha), 0;
      sind(alpha), cosd(alpha), 0;
      0, 0, 1];
end