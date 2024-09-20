function [F, Mz, SA, solved] = get_forces_accel(v, accel, delta, param)
% GET_FORCES_ACCEL Get forces on all tires required to cause given
% longitudinal and lateral acceleration under acceleration
%   Inputs:
%       v: car's velocity
%       a: acceleration vector - [ax, ay]
%       const: constants struct
%   Outputs: 
%       F: 3x4 matrix of all forces acting on the tires

    % Front tire axis transformation

    a = [(cosd(delta)), (-sind(delta)); (sind(delta)), (cosd(delta))] * [1; 0];
    b = [(cosd(delta)), (-sind(delta)); (sind(delta)), (cosd(delta))] * [0; 1];
    a = [a' 0]';
    b = [b' 0]';
    i = [1; 0; 0];
    j = [0; 1; 0];
    k = [0; 0; 1];


    % Calculate geometry for load transfer
    NRA = param.rrc - param.frc;
    t = (param.cg(1) - param.frc(1)) / NRA(1);
    %H = const.cg(3) - (const.frc(3) + NRA(3) * t);
    
    % longitudinal distance from CG to front TCPs
    %a = abs(const.fr.tcp(1) - const.cg(1));
    % longitudinal distance from CG to rear TCPs
    %b = abs(const.rr.tcp(1) - const.cg(1));

    [dW_f, dW_r] = get_load_transfer(accel, param);

    % AERO

    [L, D, dL_x] = aero_force(v, param);

    % ACCELERATION ----------------------------------------------------

    f_accel = @(x) ...
        [Rz(x(13)) * x(1:3) + Rz(x(14)) * x(4:6) + Rz(x(15)) * x(7:9) + Rz(x(16)) * x(10:12) + [- D - param.m .* accel(1); - param.m .* accel(2); param.W - L];
        ((x(3) - x(6)) / 2) - dW_f;
        ((x(9) - x(12)) / 2) - dW_r;
        x(3) + x(6) - ((x(3) + x(6) + x(9) + x(12)) .* param.front_percent) - param.cg(3) .* param.W .* accel(1) ./ (param.track(1) .* param.g) + dL_x;
        dot(cross(param.r1, Rz(x(13)) * (x(1) * a + x(2) * b)), k) + dot(cross(param.r2, Rz(x(14)) * (x(4) * a + x(5) * b)), k) + dot(cross(param.r3, Rz(x(15)) * (x(7) * i + x(8) * j)), k) + dot(cross(param.r4, Rz(x(16)) * (x(10) * i + x(11) * j)), k) + x(17) + x(18) + x(19) + x(20);
        x(1);
        x(4);
        x(7) - x(10);
        x(13) - x(14);
        x(15) - x(16);
        x(2) - tire_response_fy(x(13), x(3));
        x(5) - tire_response_fy(x(14), x(6));
        x(8) - tire_response_fy(x(15), x(9));
        x(11) - tire_response_fy(x(16), x(12));
        x(17) - tire_response_mz(x(13), x(3));
        x(18) - tire_response_mz(x(14), x(6));
        x(19) - tire_response_mz(x(15), x(9));
        x(20) - tire_response_mz(x(16), x(12))];


    x_init = [0 100 -100 0 100 -100 100 100 -100 100 100 -100 0 0 0 0 0 0 0 0]';

    options = optimset('Display', 'off', 'MaxFunEvals', 1.6e+04, 'MaxIter', 2.0e+02, 'TolFun', 1e-03);
    [x_drive, ~, flag, ~] = fsolve(f_accel, x_init, options);

    solved = flag >= 1;

    F = reshape(x_drive(1:12), 3, 4);

    % Calculate Mz (aligning moment)
    SA = x_drive(13:16);

    Mz = x_drive(17:20);

end