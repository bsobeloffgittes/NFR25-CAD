function fr = resultant_tire_friction(P,X)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    fr = (P(1) + P(2)/1000*X).*X;
end