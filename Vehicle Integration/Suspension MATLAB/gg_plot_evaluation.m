% All units are IPS

% Order of tires: [fl fr rl  rr]

clear;
close all;

% Define constants
param = define_params();

% Get the static tire weights
weights_no_accel = [(-0.5 * param.front_percent * param.W) (-0.5 * param.front_percent * param.W) ...
                (-0.5 * param.rear_percent * param.W) (-0.5 * param.rear_percent * param.W)];

% Define magic formula symbolic equations ---------------------------------

% Load magic coefficients
coeffs = load('magic_coefficients.mat');
P1 = coeffs.magic_coefficients.FR_coeff;
P2 = coeffs.magic_coefficients.FY_coeff;
P3 = coeffs.magic_coefficients.MZ_coeff;

% Increment for looping ax
x_increment = 10;

accel_x = [];
accel_y = [];

% Loop through all velocity ranges (currently just 25 mph (440 ips)) ------
for v = 600


    % ACCELERATION LOOP
    for delta = linspace(0, param.steering_angle, 10)
        fprintf("%0.2d\n", delta/param.steering_angle)
        
%         fprintf("\n\nBegining new steering angle:\n")
        % Calculate lateral acceleration
        r = param.track(1) / sind(delta);
        ay = (v .^ 2) ./ r;

        % DO THIS BETTER
            ack_ang = 0.5;

        
    
        ax = 0;
        ax_inc = 300;

%         fprintf("\nLooping Longitudinal Acceleration:\n")
        while true
    
            [F, ~, alpha, solved] = get_forces_accel(v, [(ax + ax_inc) ay], delta, param);

            ax_valid = solved && tire_forces_valid(F(:,1), alpha(1)) && ...
                tire_forces_valid(F(:,2), alpha(2)) && tire_forces_valid(F(:,3), alpha(3)) && tire_forces_valid(F(:,4), alpha(4));

            if ax_valid
                ax = ax + ax_inc;
            else
                if ax_inc <= 1
                    break;
                else
                    ax_inc = ax_inc / 2;
                end
            end

        end

        if abs(ax) > 0.1
            accel_x = [accel_x ax];
            accel_y = [accel_y ay];
        else
            break;
        end

    end

%     fprintf("\n\n\n\nStarting Braking Loop\n\n\n")

    % BRAKING LOOP
    for delta = linspace(0, param.steering_angle, 10)
%     for delta = 4
%         fprintf("\n\nBegining new steering angle:\n")
        fprintf("%0.2d\n", 1 + delta/param.steering_angle)

        % Calculate lateral acceleration
        r = param.track(1) / sind(delta);
        ay = (v .^ 2) ./ r;

        % DO THIS BETTER
            ack_ang = 0.5;

%         fprintf("\nLooping Longitudinal Acceleration:\n")

        ax = 0;
        ax_inc = 300;

        while true
    
            [F, ~, alpha, solved] = get_forces_brake(v, [(ax - ax_inc) ay], delta, param);

            ax_valid = solved && tire_forces_valid(F(:,1), alpha(1)) ...
                && tire_forces_valid(F(:,2), alpha(2)) && tire_forces_valid(F(:,3), alpha(3)) && tire_forces_valid(F(:,4), alpha(4));

            if ax_valid
                ax = ax - ax_inc;
            else
                if ax_inc <= 1
                    break;
                else
                    ax_inc = ax_inc / 2;
                end
            end

        end

        if abs(ax) > 0.1
            accel_x = [accel_x ax];
            accel_y = [accel_y ay];
   
        end

        if ax == 0
            break;
        end
     

    end
    
end

accel_x = accel_x / param.g;
accel_y = accel_y / param.g;

accel_x = [accel_x flip(accel_x)];
accel_y = [accel_y -flip(accel_y)];

valid_accel_x_mask = abs(accel_x) > 0.1;

accel_x = accel_x(valid_accel_x_mask);
accel_y = accel_y(valid_accel_x_mask);

figure()

scatter(accel_y, accel_x, '.')

xlabel("Lateral Acceleration (g)")
ylabel("Longitudinal Acceleration (g)")




