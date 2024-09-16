clear;
close all;

% [filename pathname]= uigetfile('*.dat','Enter TIRF Test File','C:\Documents and Settings\zzvyb6\My Documents\FSAE\' )

% Using round 8 testing data
filenane = 'A2356run2.dat';

path = 'C:\Users\bsobe\OneDrive - Northwestern University\Northwestern Formula Racing\NFR24\suspension-simulation-nfr24\Tire Data\Round 9 Testing Data\RunData_Cornering_ASCII_USCS_Round9\';

% File 14 ----------------

% Read in data from first file
t = importdata([path filenane]);

% Get the names of the data channels
names = t.textdata{2};
nchans = size(t.data,2);

% Remove the warmup data
t.data(1:1500,:)=[];

% Create the vectors to store all of the data
for n=1:nchans
    [name,names]=strtok(names);
    eval([upper(name) '= t.data(:,' num2str(n) ');']);
end

last_time = ET(end);

% Loop through the rest of the files for this specific file

for ii = 5:6
    
    % Get the filename of the current run to evaluate
    eval(['curr_file = ''A2356run' num2str(ii) '.dat'';']);

    t = importdata([path curr_file]);

    names = t.textdata{2};
    nchans = size(t.data,2);
    
    % Remove warmup data
    t.data(1:1500,:)=[];
    
    
    for n=1:nchans
        [name,names]=strtok(names);
        
        if(strcmp(name, 'ET')) 
            eval([upper(name) '= [' upper(name) '; t.data(:,' num2str(n) ') + last_time];']);
            last_time = ET(end);
        else
            eval([upper(name) '= [' upper(name) '; t.data(:,' num2str(n) ')];']);
        end
    end
        

end


% Extract 70 kPa subset, remove the data with the weird SA stuff, remove
% large slip angles

% cleaning_mask = P > 9.75 & P < 10.5 & ~(ET < 1000 | (ET > 4500 & ET < 5500)) ...
%     & abs(SA) < 11;
cleaning_mask_1 = P > 11.5 & P < 12.5 ...
    & abs(SA) < 11;
cleaning_mask_1 = ET > 850 & P > 9.5 & P < 10.5 & V > 24.5 & V < 25.5 & abs(SA) < 11;

cleaning_mask_1 = P > 7.5 & P < 8.5 & abs(SA) < 11;

cleaning_mask_1 = P > 7.5 & P < 8.5;

% Plot all of the relevant data

ET = ET(cleaning_mask_1);

SA = SA(cleaning_mask_1);

figure()
plot(ET, SA);
xlabel('Time (s)')
ylabel('Slip Angle (degrees)')


FZ = FZ(cleaning_mask_1);

figure()
plot(ET, FZ);
xlabel('Time (s)')
ylabel('FZ (lbf)')


FX = FX(cleaning_mask_1);

figure()
plot(ET, FX);
xlabel('Time (s)')
ylabel('FX (lbf)')


FY = FY(cleaning_mask_1);

figure()
plot(ET, FY);
xlabel('Time (s)')
ylabel('FY (lbf)')


IA = IA(cleaning_mask_1);

figure();
plot(ET, IA);
xlabel('Time (s)')
ylabel('IA (degrees)')


P = P(cleaning_mask_1);

figure();
plot(ET, P);
xlabel('Time (s)')
ylabel('P (psi)')


V = V(cleaning_mask_1);
figure();
plot(ET, V);

xlabel('Time (s)')
ylabel('V (mph)')

MZ = MZ(cleaning_mask_1);
figure();
plot(ET, MZ);

xlabel('Time (s)')
ylabel('MZ (ft-lb)')

figure()
hold on

SR = SR(cleaning_mask_1);
plot(SR)
plot(SA);


xlabel('Time (s)')
ylabel ('Slip Ratio (idk what units that is')

% -200 N
FZ1_mask = FZ < -40 & FZ > -60;

% -425 N
FZ2_mask = FZ < -90 & FZ > -110;

% -650 N
FZ3_mask = FZ < -140 & FZ > -160;

% -875 N
FZ4_mask = FZ < -180 & FZ > -220;

% -1100 N
FZ5_mask = FZ < -225 & FZ > -275;

all_ia = [0 2 4];


% for ia_curr = all_ia

% 0 degrees
IA1_mask = IA > -0.1 & IA < 0.1;

% 2 degrees
IA2_mask = IA > 1.9 & IA < 2.1;

% 4 degrees
IA3_mask = IA > 3.9 & IA < 4.1;



FZ1_SA = SA(FZ1_mask & IA1_mask);
FZ1_FY = FY(FZ1_mask & IA1_mask);
FZ1_MZ = MZ(FZ1_mask & IA1_mask);
FZ1_FX = FX(FZ1_mask & IA1_mask);
FZ1 = FZ(FZ1_mask & IA1_mask);

FZ2_SA = SA(FZ2_mask & IA1_mask);
FZ2_FY = FY(FZ2_mask & IA1_mask);
FZ2_MZ = MZ(FZ2_mask & IA1_mask);
FZ2_FX = FX(FZ2_mask & IA1_mask);
FZ2 = FZ(FZ2_mask & IA1_mask);

FZ3_SA = SA(FZ3_mask & IA1_mask);
FZ3_FY = FY(FZ3_mask & IA1_mask);
FZ3_MZ = MZ(FZ3_mask & IA1_mask);
FZ3_FX = FX(FZ3_mask & IA1_mask);
FZ3 = FZ(FZ3_mask & IA1_mask);

FZ4_SA = SA(FZ4_mask & IA1_mask);
FZ4_FY = FY(FZ4_mask & IA1_mask);
FZ4_MZ = MZ(FZ4_mask & IA1_mask);
FZ4_FX = FX(FZ4_mask & IA1_mask);
FZ4 = FZ(FZ4_mask & IA1_mask);

FZ5_SA = SA(FZ5_mask & IA1_mask);
FZ5_FY = FY(FZ5_mask & IA1_mask);
FZ5_MZ = MZ(FZ5_mask & IA1_mask);
FZ5_FX = FX(FZ5_mask & IA1_mask);
FZ5 = FZ(FZ5_mask & IA1_mask);

figure(20);

scatter3(FZ1_SA, FZ1, FZ1_FY, '.');

hold all;

scatter3(FZ2_SA, FZ2, FZ2_FY, '.');
scatter3(FZ3_SA, FZ3, FZ3_FY, '.');
scatter3(FZ4_SA, FZ4, FZ4_FY, '.');
scatter3(FZ5_SA, FZ5, FZ5_FY, '.');

xlabel('Slip Angle (degrees)');
ylabel('F_z (lbf)');
zlabel('F_y (lbf)');

% Fit this data to a Pacejka4 Model:

% Create array of model parameters P = [D1 D2 B C]
% Where D = (D1 + D2/1000 * FZ) * FZ
% and FY = D * sin(C * atan(B * SA))

IA_1_magic_mask = IA1_mask & (FZ1_mask | FZ2_mask | FZ3_mask | FZ4_mask | FZ5_mask);

X = [SA(IA_1_magic_mask) FZ(IA_1_magic_mask)];

Y = FY(IA_1_magic_mask);

% Initial guess for least squares
P0 = [0.1 1 1 1];


options = optimoptions('lsqcurvefit','MaxFunctionEvaluations',10e9,'StepTolerance',1e-10);

% Solve for parameters with nonlinear least-squares
FY4 = lsqcurvefit('Pacejka4_lateral',P0,X,Y,[],[],options);


% Graph surface for magic formula using the least squares parameters

fz = linspace(-25,-275,100)';
sa = linspace(-13,13,100)';

% Preallocate fy
fy = zeros(length(sa),length(fz));

for i=1:length(fz) %For each value of FZ
    fy(i,:) = Pacejka4_lateral(FY4,[sa fz(i)*ones(length(fz),1)]);
end


surf(sa, fz, fy);

% Look at MZ now --------------------------------------------------------

figure(21);

scatter3(FZ1_SA, FZ1, FZ1_MZ, '.');

hold all;

scatter3(FZ2_SA, FZ2, FZ2_MZ, '.');
scatter3(FZ3_SA, FZ3, FZ3_MZ, '.');
scatter3(FZ4_SA, FZ4, FZ4_MZ, '.');
scatter3(FZ5_SA, FZ5, FZ5_MZ, '.');


xlabel('Slip Angle');
ylabel('F_z (lbf)');
zlabel('M_z (ft-lb)');


X = [SA(IA_1_magic_mask) FZ(IA_1_magic_mask)];

Y = MZ(IA_1_magic_mask);

% Initial guess for least squares
P0 = [0.0817 -0.5734 -0.5681 -0.1447];


options = optimoptions('lsqcurvefit','MaxFunctionEvaluations',10e9,'StepTolerance',1e-10);

% Solve for parameters with nonlinear least-squares
MZ4 = lsqcurvefit('Pacejka4_lateral',P0,X,Y,[],[],options);


%graph surface for magic formula using the least squares parameters

fz = linspace(-25,-275,100)';
sa = linspace(-13,13,100)';

% Preallocate mz
mz = zeros(length(sa),length(fz));

for i=1:length(fz) %For each value of FZ
    mz(i,:) = Pacejka4_lateral(MZ4,[sa fz(i)*ones(length(fz),1)]);
end


surf(sa, fz, mz);

hold off

% Resultant forces for calculation of friction circle:

FR = sqrt(FX .^ 2 + FY .^ 2);

figure(22);

hold on;

scatter(FZ, FR, '.');

xlabel('FZ (lbf)');
ylabel('FR (lbf)');

max_FR1 = max(FR(FZ1_mask));
max_FR2 = max(FR(FZ2_mask));
max_FR3 = max(FR(FZ3_mask));
max_FR4 = max(FR(FZ4_mask));
max_FR5 = max(FR(FZ5_mask));

max_FR1_i = find(FR == max_FR1);
max_FR2_i = find(FR == max_FR2);
max_FR3_i = find(FR == max_FR3);
max_FR4_i = find(FR == max_FR4);
max_FR5_i = find(FR == max_FR5);

peak_FR = [max_FR1 max_FR2 max_FR3 max_FR4 max_FR5];
peak_FZ = [FZ(max_FR1_i) FZ(max_FR2_i) FZ(max_FR3_i) FZ(max_FR4_i) FZ(max_FR5_i)];

scatter(peak_FZ, peak_FR);

% Now we can make a fit to that data

X = peak_FZ;

Y = peak_FR;

% Initial guess for least squares
P0 = [1 1];

options = optimoptions('lsqcurvefit','MaxFunctionEvaluations',10e9,'StepTolerance',1e-10);

% Solve for parameters with nonlinear least-squares
FR_coeff = lsqcurvefit('resultant_tire_friction',P0,X,Y,[],[],options);

fz = -350:0;

fr = resultant_tire_friction(FR_coeff, fz);

plot(fz, fr);


% Save the coefficients so that they can be used later

magic_coefficients.FY_coeff = FY4;
magic_coefficients.MZ_coeff = MZ4;
magic_coefficients.FR_coeff = FR_coeff;

save('magic_coefficients.mat', 'magic_coefficients');

% end