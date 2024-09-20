function C = get_cornering_stiffness(Fz, alpha_degrees)
%GET_CORNERING_STIFFNESS Calculate instantaneous cornering stiffness
%   Cornering stiffness is d(Fy)/d(alpha)
%   Note: this function takes DEGREES AS INPUT, but OUTPUTS WITH RADIANS
%
%   Variables used:
%       alpha: slip angle in degrees
%       C: Usually C_f or C_r - cornering stiffness
    
    % Convert to radians
    alpha = alpha_degrees * pi/180;

    % Set differential step size
    delta = 0.001;

    % Calculate change in lateral grip for 2*delta change in alpha
    dFy = tire_response_fy(alpha + delta, Fz) - tire_response_fy(alpha - delta, Fz);

    % Finish evaluating derivative
    C = dFy / (2 * delta);
end