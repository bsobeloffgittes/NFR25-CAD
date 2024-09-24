function alpha_diff = ackermann_alpha(delta,param)
%ALPHA_DIFF Calculates difference in front slip angles
%   INPUTS:
%       delta - front steering angle (degrees)
%       param - parameter struct
%   OUTPUTS:
%       alpha_diff - difference in front slip angles from central angle


    % Calculate turning radius of rear of car
    r_rc = param.track(1) * sqrt(1 ./ (sind(delta) .^ 2) - 1);

    % Calculate inner wheel angle for full Ackermann
%     delta_it = asind(2 * param.track(1) ./ sqrt(4 * (r_rc .^ 2) ...
%         - 4 * r_rc * param.track(2) ...
%         + (param.track(2) .^ 2) + 4 * (param.track(2) .^ 2)));
    delta_it = atand(param.track(1) * tand(delta) ./ (param.track(1) - 0.5 * param.track(2) * tan(delta)));

%     delta_ot = asind(2 * param.track(1) ./ sqrt(4 * (r_rc .^ 2) ...
%         + 4 * r_rc * param.track(2) ...
%         + (param.track(2) .^ 2) + 4 * (param.track(2) .^ 2)));
    delta_ot = atand(param.track(1) * tand(delta) ./ (param.track(1) + 0.5 * param.track(2) * tan(delta)));

    delta_ot_mod = delta_it - param.ackermann_percent * (delta_it - delta);
%     A = [1 ./ (delta_it - delta), -1  ./ (delta_it - delta); 0.5 0.5];
%     b = [param.ackermann_percent; delta];
% 
%     delta_acker = A \ b;
% 
%     delta_diff = (delta_acker(1) - delta_acker(2)) ./ 2;

    alpha_diff = delta_diff - (delta_it - delta_ot);



end