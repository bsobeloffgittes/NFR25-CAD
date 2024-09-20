function ax = max_accel_x_moment(weights, ay, param)
% OBSOLETE
% Get the maximum acceleration based on load transfer rather than traction
    % Returns 99% of this value in order to avoid division by zero
    % Note: Input weights should NOT already account for load transfer

    lat_transfer = tire_weight_load_transfer([0 ay], param);

    weights = weights + lat_transfer;


%     ax = -const.track(1) * max(weights(1:2)) / (const.cg(3) * const.m);

    b = param.track(1) * 0.5 + param.cg(1);
    ax = param.g * b / param.cg(3);
%     ax = (-1 * abs(lat_transfer(1)) * const.track(1) + const.W * b) / (const.m * const.cg(3));

    ax = 0.99 * ax;

    
end