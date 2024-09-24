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
x_increment = 5;

lltd = [];
accel_y = [];
SI = [];

ii = 1;

for stiffness = linspace(-1e+05, 3e+05, 100)

    fprintf("Starting stiffness iteration %i\n", ii);
    ii = ii + 1;

    param.k_arb_r = stiffness;

    [param.k_wheel_center_f, param.k_wheel_center_r, param.K_f, param.K_r, param.K_s_f, param.K_s_r, param.R_roll] = get_stiffnesses(param);
    
    
    
    % BRAKING LOOP
    v = 0;
    v_inc = 300;

    while true

        ay = ((v + v_inc) .^ 2) ./ param.steering_radius;
        
        delta = asind(param.track(1) / param.steering_radius);
    
        [F, ~, alpha, solved] = get_forces_brake(v, [0 ay], delta, param);

%             fprintf("Solved: %i\n", solved);

        ay_valid = solved && tire_forces_valid(F(:,1), alpha(1)) && tire_forces_valid(F(:,2), alpha(2)) && tire_forces_valid(F(:,3), alpha(3)) && tire_forces_valid(F(:,4), alpha(4));
        
%             fprintf("Ay Valid: %i\n", ay_valid)


        [~, ~, ~, ~, lltd_curr] = get_load_transfer([0, ay], param);

        if ay_valid
            
            v = v + v_inc;
   
        else

            if v_inc <= 0.25
                break;
            else
                v_inc = v_inc / 2;
            end

        end
         
    
    end

        % Evaluate instantaneous cornering stiffnesses
        C_f = get_cornering_stiffness(F(3,1), alpha(1)) ... 
                + get_cornering_stiffness(F(3,2), alpha(2));
        C_r = get_cornering_stiffness(F(3,3), alpha(3)) ...
                + get_cornering_stiffness(F(3,4), alpha(4));

        % Evaluate stability index
        SI_curr = (param.a * C_f - param.b * C_r) / ((C_f + C_r) * param.track(1));


        
        lltd = [lltd lltd_curr];
        accel_y = [accel_y ay];
        SI = [SI SI_curr];
        
end

accel_y = accel_y / param.g;


% Create acceleration plot
figure();

title("Lateral Acceleration and Stability Index vs LLTD");

yyaxis left;
plot((lltd ./ (1 + lltd)), accel_y);

hold on;

xlabel("Lateral Load Transfer Distribution (% front)")
ylabel("Maximum Lateral Acceleration (g)")

% Create stability plot
yyaxis right;
plot(lltd ./ (1 + lltd), SI);

hold on;

% Find and mark x-intercept
lltd_stable = interp1(SI, (lltd ./ ( 1 + lltd)), 0, 'spline');
plot(lltd_stable, 0, 'o');

xlabel("Lateral Load Transfer Distribution (% front)")
ylabel("Stability Index (SI) at Max Lateral Acceleration")

xlim([-inf inf])


% Save to file

lltd_eval.accel_y = accel_y;
lltd_eval.lltd = lltd;
