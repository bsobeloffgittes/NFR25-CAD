clear

loading_mode = 'accel'; % accel or brake

param = define_params();

[tire, hub, fixed_arm, float_arm, push_rod, tie_rod, coilover, rocker] = front_right_corner();

% Accelerations
% Accel: [1.520 0]
% Cornering: [0 -1.421]
% Brake: [-1.649 0];


% Calculate tire forces and aligning moment
%[F_all, Mz_all] = get_forces_brake(600, [-1.85 * param.g 0], 0, param);
%[F_all, Mz_all] = get_forces_brake(600, [-0.2 * param.g -1.6 * param.g], param.steering_angle, param);
 [F_all, Mz_all] = get_forces_accel(600, [1.399 * param.g 0], 0, param);




% Reverse Z sign
F_all = [1 0 0; 0 1 0; 0 0 -1] * F_all;

% Select for current tire
F = F_all(:,2);
Mz = [0; 0; Mz_all(2)];

% UPDATE HOW THIS IS CALCULATED
phi = 0;


% HUB ---------------------------------------------------------------------

% Define symbolic variables for hub analysis
syms F_ob_x F_ob_y F_ob_z;
syms F_ib_x F_ib_z;
syms M_accel;
syms F_bc;

if strcmp(loading_mode, 'accel')
    % Force equilibrium for hub
    hub_force_eq = F + F_ob_x*[1;0;0] + F_ob_y*[0;1;0] + ...
        F_ob_z*[0;0;1] + F_ib_x*[1;0;0] + F_ib_z*[0;0;1] == 0;
    
    % Moment equilibrium for hub
    hub_moment_eq = cross(tire.tcp, F) + Mz + cross(hub.obp, F_ob_x* ...
        [1;0;0] + F_ob_y*[0;1;0] + F_ob_z*[0;0;1]) + ...
        cross(hub.ibp, F_ib_x*[1;0;0] + F_ib_z*[0;0;1]) ... 
        + M_accel*[0;1;0] == 0;
    
    hub_sol = solve([hub_force_eq hub_moment_eq], ...
        [F_ob_x F_ob_y F_ob_z F_ib_x F_ib_z M_accel]);
    
    % Forces ACTING ON hubs

    hub.F_ob = double([hub_sol.F_ob_x; hub_sol.F_ob_y; hub_sol.F_ob_z]);
    hub.F_ib = double([hub_sol.F_ib_x; 0; hub_sol.F_ib_z]);

    hub.M_accel = double(hub_sol.M_accel) * [0;1;0];

    hub.F_bc = [0;0;0];
elseif strcmp(loading_mode, 'brake')

    % Calculate the direction of braking force
    u_bc = cross([hub.bc(1); 0; hub.bc(3)]-[hub.ibp(1); 0; hub.ibp(3)], [0; 1; 0]);
    u_bc = u_bc ./ norm(u_bc);

    % Force equilibrium for hub
    hub_force_eq = F + F_ob_x*[1;0;0] + F_ob_y*[0;1;0] + ...
        F_ob_z*[0;0;1] + F_ib_x*[1;0;0] + F_ib_z*[0;0;1] ...
        + F_bc*u_bc == 0;
    
    % Moment equilibrium for hub
    hub_moment_eq = cross(tire.tcp, F) + Mz + cross(hub.obp, F_ob_x* ...
        [1;0;0] + F_ob_y*[0;1;0] + F_ob_z*[0;0;1]) + ...
        cross(hub.ibp, F_ib_x*[1;0;0] + F_ib_z*[0;0;1]) ... 
        + cross(hub.bc,F_bc*u_bc) == 0;
    
    hub_sol = solve([hub_force_eq hub_moment_eq], ...
        [F_ob_x F_ob_y F_ob_z F_ib_x F_ib_z F_bc]); % ADD F_BC to this eqn!!!!!!!!!!!!!!!!!!!!!!!
    
    % Forces ACTING ON hubs
    % - hub.m_y is braking, + hub.m_y is accel
    
    hub.F_ob = double([hub_sol.F_ob_x; hub_sol.F_ob_y; hub_sol.F_ob_z]);
    hub.F_ib = double([hub_sol.F_ib_x; 0; hub_sol.F_ib_z]);

    hub.M_accel = [0;0;0];

    hub.F_bc = double(hub_sol.F_bc*u_bc);
else
    error('Neither braking nor acceleration');
end

% Clear symbolic hub variables to free namespace for upright analysis
clear F_ob_x F_ob_y F_ob_z F_ib_x F_ib_z ...
    M_accel F_bc;


% UPRIGHT -----------------------------------------------------------------


upright.F_ob = -hub.F_ob;
upright.F_ib = -hub.F_ib;
upright.F_bc = -hub.F_bc;

% Floating A-arm link unit vectors
u_rl = (float_arm.ibjr-float_arm.objr)/norm(float_arm.ibjr-float_arm.objr);
u_fl = (float_arm.ibjf-float_arm.objf)/norm(float_arm.ibjf-float_arm.objf);

% Tie rod unit vector
u_tr = (tie_rod.ip - tie_rod.op)/norm(tie_rod.ip - tie_rod.op);

% Define symbolic variables for uprights
syms F_rl F_fl;
syms F_tr;
syms F_fobj_x F_fobj_y F_fobj_z;

% Force equilibrium for upright
upright_force_eq = (upright.F_ob + upright.F_ib + upright.F_bc) + ...
    F_rl*u_rl + F_fl*u_fl + F_tr*u_tr + F_fobj_x*[1;0;0] + F_fobj_y*[0;1;0] ...
    + F_fobj_z*[0;0;1] == 0;

% Moment equilibrium for upright
upright_moment_eq = (cross(hub.ibp,upright.F_ib) + cross(hub.obp,upright.F_ob) ...
    + cross(hub.bc,upright.F_bc)) + cross(float_arm.objr,F_rl*u_rl) + ...
    cross(float_arm.objf,F_fl*u_fl) + cross(tie_rod.op,F_tr*u_tr) + ...
    cross(fixed_arm.obj,F_fobj_x*[1;0;0] + F_fobj_y*[0;1;0] + F_fobj_z*[0;0;1]) == 0;

% Solve system
upright_sol = solve([upright_force_eq upright_moment_eq], ...
    [F_rl F_fl F_tr F_fobj_x F_fobj_y F_fobj_z]);

% Forces ACTING ON uprights
upright.F_rl = double(upright_sol.F_rl * u_rl);
upright.F_fl = double(upright_sol.F_fl * u_fl);
upright.F_tr = double(upright_sol.F_tr * u_tr);
upright.F_fobj = double([upright_sol.F_fobj_x; upright_sol.F_fobj_y; ...
    upright_sol.F_fobj_z]);

% Clear upright symbolic variables
clear F_rl F_fl F_tr F_fobj_x F_fobj_y F_fobj_z;


% FIXED A-ARM -------------------------------------------------------------

% Define orthonormal basis for easier manipulation of the a-arms
u = (fixed_arm.fbj-fixed_arm.rbj)/norm(fixed_arm.fbj-fixed_arm.rbj);
vw = null(u');
v = vw(:,1);
w = vw(:,2);


fixed_arm.F_obj = -upright.F_fobj;

% Push rod unit vector
u_pr = (push_rod.ip - push_rod.op)/norm(push_rod.ip - push_rod.op);

% Define symbolic variables for fixed a-arm
syms F_pr;
syms F_rbj_u F_rbj_v F_rbj_w;
syms F_fbj_u F_fbj_v F_fbj_w;

% Force equilibrium
fixed_arm_force_eq = (fixed_arm.F_obj) + F_pr*u_pr + F_rbj_u*u + ...
    F_rbj_v*v + F_rbj_w*w + F_fbj_u*u + F_fbj_v*v ...
    + F_fbj_w*w == 0;

fixed_arm_overconstraint_resolution = [F_rbj_u - F_fbj_u; 0; 0] == [0;0;0];

fixed_arm_moment_eq = cross(fixed_arm.obj,fixed_arm.F_obj) + ...
    cross(push_rod.op,F_pr*u_pr) + ... 
    cross(fixed_arm.rbj,F_rbj_u*u + F_rbj_v*v + F_rbj_w*w) ...
    + cross(fixed_arm.fbj,F_fbj_u*u + F_fbj_v*v + F_fbj_w*w) == 0;

fixed_arm_sol = solve([fixed_arm_force_eq fixed_arm_overconstraint_resolution ...
    fixed_arm_moment_eq], [F_pr F_rbj_u F_rbj_v F_rbj_w F_fbj_u F_fbj_v F_fbj_w]);

fixed_arm.F_pr = double(fixed_arm_sol.F_pr * u_pr);
fixed_arm.F_rbj = double([fixed_arm_sol.F_rbj_u;fixed_arm_sol.F_rbj_v;fixed_arm_sol.F_rbj_w]);
fixed_arm.F_fbj = double([fixed_arm_sol.F_fbj_u;fixed_arm_sol.F_fbj_v;fixed_arm_sol.F_fbj_w]);

clear F_pr F_rbj_u F_rbj_v F_rbj_w F_fbj_u F_fbj_v F_fbj_w;


% ROCKER ------------------------------------------------------------------

% Define orthonormal basis for rocker coordinate system
% First in-plane vector
u = (push_rod.ip - rocker.fbp) ./ norm(push_rod.ip - rocker.fbp);
% Vector in bearing axis
w = cross(u, coilover.lp - rocker.fbp);
w = w ./ norm(w);
% Second in-plane vector
v = cross(w, u) ./ norm(cross(w, u));

u_s = (coilover.up - coilover.lp) ./ norm(coilover.up - coilover.lp);

rocker.F_pr = -fixed_arm.F_pr;

syms F_fbp_u F_fbp_v F_fbp_w F_s;
syms M_fbp_u M_fbp_v;

rocker_force_eq = rocker.F_pr + F_s*u_s + F_fbp_u*u + F_fbp_v*v + ...
    F_fbp_w*w == [0;0;0];

rocker_moment_eq = cross(push_rod.ip, rocker.F_pr) + ...
    cross(rocker.fbp, F_fbp_u*u + F_fbp_v*v + F_fbp_w*w) + ...
    cross(coilover.lp, F_s*u_s) + M_fbp_u*u + M_fbp_v*v == [0;0;0];

rocker_sol = solve([rocker_force_eq rocker_moment_eq], [F_fbp_u ...
    F_fbp_v F_fbp_w F_s M_fbp_u M_fbp_v]);

rocker.F_s = double(rocker_sol.F_s * u_s);
rocker.F_fbp = double(rocker_sol.F_fbp_u*u + rocker_sol.F_fbp_v*v + ...
    rocker_sol.F_fbp_w*w);
rocker.M_fbp = double(rocker_sol.M_fbp_u*u + rocker_sol.M_fbp_v*v);

% clear F_fbp_u F_fbp_v F_fbp_w F_s M_fbp_v M_fbp_w;




