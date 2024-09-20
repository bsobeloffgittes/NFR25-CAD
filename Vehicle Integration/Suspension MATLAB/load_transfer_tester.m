clear

%{

l = 9.5ft
a = 4.56ft
b = 4.94ft
h_g (cg height) = 1.583 ft
H = 1.069 ft





%}


% const.W = 3500;
% const.K_f = 67600;
% const.K_r = 36100;
% const.g = 32.2; 


const.W = 3500;
const.K_f = 67600;
const.K_r = 36100;
const.g = 32.2; 

const.track = [9.5; 5];
const.fr.tcp = [4.56; -2.5; 0];
const.rr.tcp = [-4.94; -2.5; 0];

const.frc = [4.56; 0; 0.25];
const.rrc = [-4.94; 0; 0.625];

const.cg = [0; 0; 1.5];

[d_f, d_r, d_x, phi] = get_load_transfer([10; 2 * const.g; 0], const);

A_x = 10 / const.g;
A_y = 2;

norm_d_f = d_f / A_y
norm_d_r = d_r / A_y
norm_d_x = d_x / A_x