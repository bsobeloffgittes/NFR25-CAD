function [tire, hub, fixed_arm, float_arm, push_rod, tie_rod, coilover, rocker] = rear_right_corner()
%FRONT_RIGHT_CORNER Defines all geometry of the front right corner 
%   Correspondence to SW coordinate system
%   SW X - Y
%   SW Y - Z
%   SW Z - X

    % TIRE ----------------------------------------------------

    tire.tcp = [-30.125; -24.5; 0];

    % HUB -----------------------------------------------------

    % Inner and outer hub bearing points PLACEHOLDER
    hub.obp = [-30.125; -23.386; 8];
    hub.ibp = [-30.125; -21.961; 8];

    % Point of braking calipers PLACEHOLDER
    warning("Placeholder Brake Caliper Location")
    hub.bc = [-27.122; -24.016; 8];

    % FIXED ARM -----------------------------------------------

    % Point of ball joint on a-arm that contains push/pull rod
    fixed_arm.obj = [-30.912; -22.835; 11.417];
    % Rear inboard ball joint
    fixed_arm.rbj = [-30.125; -11.811; 8.268];
    % Front inboard ball joint
    fixed_arm.fbj = [-21.464; -13.75; 8.858];

    % FLOAT ARM -----------------------------------------------

    % Point of ball joint on other a-arm
    float_arm.objf = [-29.81; -22.756; 4.724];
    % objf and objr are the same in non-multilink
    float_arm.objr = [-30.794; -22.756; 4.724]; 
    float_arm.ibjr = [-30.125; -11.811; 4.331];
    float_arm.ibjf = [-21.464; -13.75; 4.409];

    % PUSH/PULL ROD -------------------------------------------

    % Outer pull/push rod point
    push_rod.op = [-29.928; -20.866; 10.630];
    % Inner
    push_rod.ip = [-27.913; -14.522; 3.937];

    % TIE ROD -------------------------------------------------

    % Outer tie-rod point
    tie_rod.op = [-33.275; -22.885; 7.067];
    % Inner
    tie_rod.ip = [-30.401; -11.811; 5.945];

    % ROCKER --------------------------------------------------

    % ARB mounting point
%     rocker.arb_point = [30.578; -6.256; 3.054];
    % Fixed bearing point
    rocker.fbp = [-27.175; -12.195; 4.331];

    % COILOVER ------------------------------------------------

    % Coilover upper point
    coilover.up = [-27.240; -12.402; 13.386];

    % Coilover lower point
    coilover.lp = [-28.136; -15.223; 7.317];




end