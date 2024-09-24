clear
close all

param = define_params();


ay_max = 1.55; % max accel in g

[dW_f, dW_r, ~, phi, lltd, rr] = get_load_transfer([0, ay_max * param.g], param);

tire_travel_roll = phi * param.track(2) / 2;

% Braking

ax_brake = -1.8;

[~, ~, dW_x, ~, ~, ~] = get_load_transfer([ax_brake * param.g, 0], param);

tire_travel_brake = [(1 - param.anti_pitch) * dW_x / (2 * param.k_wf), ...
    -(1 - param.anti_squat) * dW_x / (2 * param.k_wr)];

% Braking pitch angle in radians
theta_brake = asin(tire_travel_brake * [1; -1] / param.track(1));


% Acceleration

ax_accel = 1.35;

[~, ~, dW_x, ~, ~, ~] = get_load_transfer([ax_accel * param.g, 0], param);

tire_travel_accel = [(1 - param.anti_pitch) * dW_x / (2 * param.k_wf), ...
    -(1 - param.anti_squat) * dW_x / (2 * param.k_wr)];

% Braking pitch angle in radians
theta_accel = asin(tire_travel_accel * [1; -1] / param.track(1));


% 1 degree roll, 1-1.5 pitch

% 1 degree = 0.0175 rad
% 1.5 degree = 0.0262 rad


% Assume everything is at 60 mph for aero purposes
[L, D, dL_x] = aero_force(1056, param);

% [front travel, rear travel]
aero_travel = [((L / 2) - dL_x) / (2 * param.k_wf), ((L / 2) + dL_x) / (2 * param.k_wr)];



