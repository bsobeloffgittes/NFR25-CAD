function [dW_f, dW_r, dW_x, phi, LLTD, roll_rate, theta] = get_load_transfer(accel, param)
%GET_LOAD_TRANSFER Compute lateral and longitudinal load transfers
%   Inputs: 
%       accel - acceleration vector
%       const - car position struct
%       const - car and natural constant struct
%   Outputs:
%       dW_f - front lateral weight transfer
%       dW_r - right lateral weight transfer
%       dW_x - longitudinal weight transfer
%       
% dW_f and dW_r are subtracted from right and added to left
% dW_x is subtracted from rears and added to fronts
% This is because tire weights should be negative
%
% Read RCVD 18.4 to understand this
% Note: Written in IPS

    % LATERAL LOAD TRANSFER 
    
    NRA = param.rrc - param.frc;
    t = (param.cg(1) - param.frc(1)) / NRA(1);
    H = param.cg(3) - (param.frc(3) + NRA(3) * t);

    total_K = param.K_f + param.K_r;

    a = abs(param.fr.tcp(1) - param.cg(1));
    b = abs(param.rr.tcp(1) - param.cg(1));

    % RCVD 18.4, roll angle produced (simplified model producing ~2% error)
%     phi = (accel(2) / const.g) * (const.W * H) / (total_K);
% 
%     rr = phi / (accel(2) / const.g)

    roll_rate = (param.m_s * param.g * H) / (total_K);

    phi = roll_rate * accel(2) / param.g;

    % Front weight transfer
    dW_f = (accel(2) / param.g) * (param.W / param.track(2)) ...
        * (H * param.K_f / total_K + b * param.frc(3) / param.track(1));

    % Rear weight transfer
    dW_r = (accel(2) / param.g) * (param.W / param.track(2)) ...
        * (H * param.K_r / total_K + a * param.rrc(3) / param.track(1));

    LLTD = dW_f ./ dW_r;

    % LONGITUDINAL LOAD TRANSFER
    
    dW_x = param.cg(3) * param.W * accel(1) / (param.track(1) * param.g);

    

end