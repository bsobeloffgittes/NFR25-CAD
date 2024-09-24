function posn = define_posns()
% OBSOLETE
%DEFINE_POSNS
%   Returns struct containing position vectors of each critical location
%   Locations are in the form of column vectors 
%   Origin is center of the car at ground level
%   Axes are:
%       Positive X: forward
%       Positive Y: left
%       Positive Z: up

    % Define center of gravity
    posn.cg = [0; 0; 18];
    warning('Placeholder value used');
    
%     % Sprung center of gravity
%     posn.cg_s = 
%     warning('Placeholder value used');
%     % Unsprung front and rear centers of gravity
%     posn.cg_u_f =
%     warning('Placeholder value used');
%     posn.cg_u_r =
%     warning('Placeholder value used');

    % Define track size [length, width]
    posn.track = [60 48];
    warning('Placeholder value used');

    % Define ceenter of pressure
    posn.cp = [0; 0.1; 0];
    warning('Placeholder value used');

    

    % Define tire contact patch (tcp) positions
    fr.tcp = [30; 24; 0];
    warning('Placeholder value used');
    rr.tcp = [-30; -24; 0];
    warning('Placeholder value used');

    fl.tcp = mirror_rl(fr.tcp);
    rl.tcp = mirror_rl(rr.tcp);

    posn.fr = fr;
    posn.fl = fl;
    posn.rr = rr;
    posn.rl = rl;

    % Front and Rear Roll Centers
    posn.frc = [24; 0; 10];
    warning('Placeholder value used');
    posn.rrc = [-24; 0; 10];
    warning('Placeholder value used');


end