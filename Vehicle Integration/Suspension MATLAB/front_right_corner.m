function [tire, hub, fixed_arm, float_arm, push_rod, tie_rod, coilover, rocker] = front_right_corner()
%FRONT_RIGHT_CORNER Defines all geometry of the front right corner 
%   Correspondence to SW coordinate system
%   SW X - Y
%   SW Y - Z
%   SW Z - X

    % TIRE ----------------------------------------------------

    tire.tcp = [30.125; -24.5; 0];

    % HUB -----------------------------------------------------

    % Inner and outer hub bearing points PLACEHOLDER
    hub.obp = [30.125; -23.445; 8];
    hub.ibp = [30.125; -22.028; 8];

    % Point of braking calipers PLACEHOLDER
    warning("Placeholder Brake Caliper Location")
    hub.bc = [26.976; -24.095; 8];

    % FIXED ARM -----------------------------------------------

    % Point of ball joint on a-arm that contains push/pull rod
    fixed_arm.obj = [29.653; -22.362; 11.102];
    % Rear inboard ball joint
    fixed_arm.rbj = [25.569; -10.5; 9.449];
    % Front inboard ball joint
    fixed_arm.fbj = [35.834; -10.5; 10.433];

    % FLOAT ARM -----------------------------------------------

    % Point of ball joint on other a-arm
    float_arm.objf = [30.361; -23.051; 4.693];
    % objf and objr are the same in non-multilink
    float_arm.objr = [30.361; -23.051; 4.693]; 
    float_arm.ibjr = [25.204; -9.055; 4.744];
    float_arm.ibjf = [35.637; -9.055; 4.488];

    % PUSH/PULL ROD -------------------------------------------

    % Outer pull/push rod point
    push_rod.op = [29.436; -21.730; 10.630];
    % Inner
    push_rod.ip = [30.150; -12.913; 3.182];

    % TIE ROD -------------------------------------------------

    % Outer tie-rod point
    tie_rod.op = [32.723; -23.622; 6.299];
    % Inner
    tie_rod.ip = [32.094; -8.661; 5.846];

    % ROCKER --------------------------------------------------

    % ARB mounting point
%     rocker.arb_point = [30.578; -6.256; 3.054];
    % Fixed bearing point
    rocker.fbp = [30.135; -7.992; 3.339];

    % COILOVER ------------------------------------------------

    % Coilover upper point
    coilover.up = [29.209; -11.220; 12.992];

    % Coilover lower point
    coilover.lp = [29.825; -13.214; 6.571];




end