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

cleaning_mask = P > 9.75 & P < 10.5 & ~(ET < 1000 | (ET > 4500 & ET < 5500)) ...
    & abs(SA) < 11;
cleaning_mask = P > 11.5 & P < 12.5 ...
    & abs(SA) < 11;
cleaning_mask = ET > 850 & P > 9.5 & P < 10.5 & V > 24.5 & V < 25.5 & abs(SA) < 11;

cleaning_mask = P > 7.5 & P < 8.5 & abs(SA) < 11;

% Plot all of the relevant data

ET = ET(cleaning_mask);

SA = SA(cleaning_mask);

figure()
plot(ET, SA);
xlabel('Time (s)')
ylabel('Slip Angle (degrees)')


FZ = FZ(cleaning_mask);

figure()
plot(ET, FZ);
xlabel('Time (s)')
ylabel('FZ (lbf)')


FX = FX(cleaning_mask);

figure()
plot(ET, FX);
xlabel('Time (s)')
ylabel('FX (lbf)')


FY = FY(cleaning_mask);

figure()
plot(ET, FY);
xlabel('Time (s)')
ylabel('FY (lbf)')


IA = IA(cleaning_mask);

figure();
plot(ET, IA);
xlabel('Time (s)')
ylabel('IA (degrees)')


P = P(cleaning_mask);

figure();
plot(ET, P);
xlabel('Time (s)')
ylabel('P (psi)')


V = V(cleaning_mask);
figure();
plot(ET, V);

xlabel('Time (s)')
ylabel('V (mph)')

MZ = MZ(cleaning_mask);
figure();
plot(ET, MZ);

xlabel('Time (s)')
ylabel('MZ (ft-lb)')

figure()
hold on

SR = SR(cleaning_mask);
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



% FZ1_SA = SA(FZ1_mask & IA1_mask);
% FZ1_FY = FY(FZ1_mask & IA1_mask);
% FZ1_MZ = MZ(FZ1_mask & IA1_mask);
% FZ1_FX = FX(FZ1_mask & IA1_mask);
% FZ1 = FZ(FZ1_mask & IA1_mask);
% 
% FZ2_SA = SA(FZ2_mask & IA1_mask);
% FZ2_FY = FY(FZ2_mask & IA1_mask);
% FZ2_MZ = MZ(FZ2_mask & IA1_mask);
% FZ2_FX = FX(FZ2_mask & IA1_mask);
% FZ2 = FZ(FZ2_mask & IA1_mask);
% 
% FZ3_SA = SA(FZ3_mask & IA1_mask);
% FZ3_FY = FY(FZ3_mask & IA1_mask);
% FZ3_MZ = MZ(FZ3_mask & IA1_mask);
% FZ3_FX = FX(FZ3_mask & IA1_mask);
% FZ3 = FZ(FZ3_mask & IA1_mask);

FZ4_SA_1 = SA(FZ4_mask & IA1_mask);
FZ4_FY_1 = FY(FZ4_mask & IA1_mask);
FZ4_MZ_1 = MZ(FZ4_mask & IA1_mask);
FZ4_FX_1 = FX(FZ4_mask & IA1_mask);
FZ4_1 = FZ(FZ4_mask & IA1_mask);



FZ4_SA_2 = SA(FZ4_mask & IA2_mask);
FZ4_FY_2 = FY(FZ4_mask & IA2_mask);
FZ4_MZ_2 = MZ(FZ4_mask & IA2_mask);
FZ4_FX_2 = FX(FZ4_mask & IA2_mask);
FZ4_2 = FZ(FZ4_mask & IA2_mask);


FZ4_SA_3 = SA(FZ4_mask & IA3_mask);
FZ4_FY_3 = FY(FZ4_mask & IA3_mask);
FZ4_MZ_3 = MZ(FZ4_mask & IA3_mask);
FZ4_FX_3 = FX(FZ4_mask & IA3_mask);
FZ4_3 = FZ(FZ4_mask & IA3_mask);

% FZ5_SA = SA(FZ5_mask & IA1_mask);
% FZ5_FY = FY(FZ5_mask & IA1_mask);
% FZ5_MZ = MZ(FZ5_mask & IA1_mask);
% FZ5_FX = FX(FZ5_mask & IA1_mask);
% FZ5 = FZ(FZ5_mask & IA1_mask);

figure(20);

scatter3(FZ4_SA_1, FZ4_1, FZ4_FY_1, '.');

hold all;

scatter3(FZ4_SA_2, FZ4_2, FZ4_FY_2, '.');
scatter3(FZ4_SA_3, FZ4_3, FZ4_FY_3, '.');

xlabel('Slip Angle (degrees)');
ylabel('F_z (lbf)');
zlabel('F_y (lbf)');

legend('IA = 0','IA = 2','IA = 4')


