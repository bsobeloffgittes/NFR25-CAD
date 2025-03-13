function param = define_params()
%DEFINE_PARAMS Defines all parameters in the car that are relevant for
%analysis
%   Outputs all parameters in "param" struct

    % Gravitational Constants
    param.g = 386.1; 
    
    % Weight with driver
    param.W = 690; % lbs

    param.front_percent = 0.46;
    param.rear_percent = 0.54;

    % mass in blobs :) (12 slugs)
    param.m = param.W / param.g;



    % Turning radius
    param.steering_radius = 350;
    % Steering angle needed to achieve radius
    param.steering_angle = asind(60 / param.steering_radius);

    % Ackermann percent
    param.ackermann_percent = 1;

    % Tires:
    param.tire_d = 16;
    param.k_t = 700; % tire spring rate [lbf/in]

    % Define track size [length, width]
    param.track = [60.25 49];

    % Define center of gravity
    param.cg = [param.track(1) * (-0.5 + param.front_percent); 0; 11];

    % Braking bias
    param.front_bias = 0.7;

    % Define tire contact patch (tcp) positions
    fr.tcp = [param.track(1)/2; -param.track(2)/2; 0];
    rr.tcp = [-param.track(1)/2; -param.track(2)/2; 0];

    fl.tcp = mirror_rl(fr.tcp);
    rl.tcp = mirror_rl(rr.tcp);

    param.fr = fr;
    param.fl = fl;
    param.rr = rr;
    param.rl = rl;

    % Vectors from CG to TCPs
    param.r1 = param.fl.tcp - param.cg;
    param.r2 = param.fr.tcp - param.cg;
    param.r3 = param.rl.tcp - param.cg;
    param.r4 = param.rr.tcp - param.cg;

    % Front and Rear Roll Centers
    param.frc = [fr.tcp(1); 0; 1.614];
    param.rrc = [rr.tcp(1); 0; 2.087];

    % Aero stuff ----------------------------------------------------------
    
    % Density of air (lb/in^3)
%     const.rho = 4.349726e-5;
    param.rho = 1.1266e-07;

    param.C_d = 1.1;
    param.C_l = 2.5;

    % 1.23 m^2 (from Marina)
    param.frontal_area = 1910;

    param.wing_area = 1910;

    param.cp = [-0.75; 0; 10];
    warning('Placeholder value used');

    % Spring/Damper Values ------------------------------------------------

    % Relevant geometry for lateral load transfer
    
    NRA = param.rrc - param.frc;
    t = (param.cg(1) - param.frc(1)) / NRA(1);
    param.H = param.cg(3) - (param.frc(3) + NRA(3) * t);

    a = abs(param.fr.tcp(1) - param.cg(1));
    b = abs(param.rr.tcp(1) - param.cg(1));

    param.a = a;
    param.b = b;

    % Unsprung mass vector
    param.m_u = (20 ./ param.g) * ones(1,4);
    % Sprung mass
    param.m_s = param.m - sum(param.m_u);

    % Front and rear sprung masses
    param.m_sf = param.m_s * param.front_percent;
    param.m_sr = param.m_s * param.rear_percent;

    % LLTD target (stability) 1.1607 (53.72% front)

    % Wheel rate stiffnesses
    param.k_wf = 200;
    param.k_wr = 180;

    % ARB stiffnesses (lb-in/rad)
    param.k_arb_f = 0.90e+05; % 0.36e+05
%     param.k_arb_r = 0.50e+05; % 0.10e+05
    param.k_arb_r = 0;

    [param.k_wheel_center_f, param.k_wheel_center_r, param.K_f, param.K_r, param.K_s_f, param.K_s_r, param.R_roll] = get_stiffnesses(param);

    % Anti Geometry Percentages
    param.anti_pitch = 0.20;
    param.anti_squat = 0.25;

    % ARB Geometry ------------------------------------
    % ARB motion ratios (roll angle phi / arb twist angle theta)
    param.mr_arb_f = 1;
    param.mr_arb_r = 1;

    % Spring rate calculations
    param.front_mr = 1.02;
    param.rear_mr = 1.02;

    

    
    

end