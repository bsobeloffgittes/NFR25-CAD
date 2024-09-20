clear;
close all;

% [filename pathname]= uigetfile('*.dat','Enter TIRF Test File','C:\Documents and Settings\zzvyb6\My Documents\FSAE\' )

% Using round 8 testing data
filenane = 'A2356run72.dat';

path = 'C:\Users\bsobe\OneDrive - Northwestern University\Northwestern Formula Racing\NFR24\suspension-simulation-nfr24\Tire Data\Round 9 Testing Data\RunData_DriveBrake_ASCII_USCS_Round9\';

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

% for ii = 15:19
%     
%     % Get the filename of the current run to evaluate
%     eval(['curr_file = ''A2356run' num2str(ii) '.dat'';']);
% 
%     t = importdata([path curr_file]);
% 
%     names = t.textdata{2};
%     nchans = size(t.data,2);
%     
%     % Remove warmup data
%     t.data(1:1500,:)=[];
%     
%     
%     for n=1:nchans
%         [name,names]=strtok(names);
%         
%         if(strcmp(name, 'ET')) 
%             eval([upper(name) '= [' upper(name) '; t.data(:,' num2str(n) ') + last_time];']);
%             last_time = ET(end);
%         else
%             eval([upper(name) '= [' upper(name) '; t.data(:,' num2str(n) ')];']);
%         end
%     end
%         
% 
% end


% Extract 70 kPa subset, remove the data with the weird SA stuff, remove
% large slip angles

% cleaning_mask = P > 9.75 & P < 10.5 & ~(ET < 1000 | (ET > 4500 & ET < 5500)) ...
%     & abs(SA) < 11;
cleaning_mask = P > 9.5 & P < 10.5;

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


% P = P(cleaning_mask);
% 
% figure();
% plot(ET, P);
% xlabel('Time (s)')
% ylabel('P (mph)')


V = V(cleaning_mask);
figure();
plot(ET, V);

xlabel('Time (s)')
ylabel('V (mph)')

% MZ = MZ(cleaning_mask);
% figure();
% plot(ET, MZ);
% 
% xlabel('Time (s)')
% ylabel('MZ (ft-lb)')

SL = SL(cleaning_mask);

% Normalized longitudinal force

no_ia_no_sa = IA > -0.1 & IA < 0.1 & SA > -0.1 & SA < 0.1;

fz1 = FZ > -170 & FZ < - 130 & no_ia_no_sa;
fz2 = FZ > -220 & FZ < - 175 & no_ia_no_sa;
fz3 = FZ > -270 & FZ < - 225 & no_ia_no_sa;

figure();
% scatter3(SL(no_ia_no_sa), FX(no_ia_no_sa), FZ(no_ia_no_sa), '.');
scatter3(SL(fz1), FX(fz1), FZ(fz1), '.');

hold on

scatter3(SL(fz2), FX(fz2), FZ(fz2), '.');
scatter3(SL(fz3), FX(fz3), FZ(fz3), '.');



% scatter(SL(no_ia_no_sa & FZ > -270 & FZ < - 230), FX(no_ia_no_sa & FZ > -270 & FZ < - 230), '.');
% scatter(SL(no_ia_no_sa & FZ > -170 & FZ < -130), FX(no_ia_no_sa & FZ > -170 & FZ < -130), '.');

xlabel("Slip Ratio")
ylabel("FX");
zlabel("FZ")

NFX = FX ./ FZ;

figure();
% scatter3(SL(no_ia_no_sa), FX(no_ia_no_sa), FZ(no_ia_no_sa), '.');
scatter(SL(fz1), NFX(fz1), '.');

hold on

scatter(SL(fz2), NFX(fz2), '.');
scatter(SL(fz3), NFX(fz3), '.');


% scatter(SL(no_ia_no_sa & FZ > -270 & FZ < - 230), FX(no_ia_no_sa & FZ > -270 & FZ < - 230), '.');
% scatter(SL(no_ia_no_sa & FZ > -170 & FZ < -130), FX(no_ia_no_sa & FZ > -170 & FZ < -130), '.');

xlabel("Slip Ratio")
ylabel("NFX");
zlabel("FZ")


% Look at NFX vs IA

no_sa = SA > -0.1 & SA < 0.1;

fz1 = FZ > -170 & FZ < - 130 & no_sa;
fz2 = FZ > -220 & FZ < - 175 & no_sa;
fz3 = FZ > -270 & FZ < - 225 & no_sa;


% Fit a curve to the data
X = [SL(fz1 | fz2 | fz3) IA(fz1 | fz2 | fz3)];

Y = NFX(fz1 | fz2 | fz3);

% Initial guess for least squares
P0 = [1 1 1 1];


options = optimoptions('lsqcurvefit','MaxFunctionEvaluations',10e9,'StepTolerance',1e-10);

% Solve for parameters with nonlinear least-squares
NFX4 = lsqcurvefit('Pacejka4_sr_ia_fx',P0,X,Y,[],[],options);


figure();

scatter3(SL(fz1), IA(fz1), NFX(fz1), '.');

hold on

scatter3(SL(fz2), IA(fz2), NFX(fz2), '.');
scatter3(SL(fz3), IA(fz3), NFX(fz3), '.');




% %graph surface for magic formula using the least squares parameters
% 
% sr = linspace(-0.2,0.2,100)';
% ia = linspace(0,4,100)';
% 
% % Preallocate mz
% fx = zeros(length(sr),length(ia));
% 
% for i=1:length(sr) %For each value of sr
%     fx(i,:) = Pacejka4_lateral(NFX4,[sr ia(i)*ones(length(ia),1)]);
% end
% 
% 
% surf(sr, ia, fx);
% 
% hold off
% 



xlabel("Slip Ratio")
ylabel("IA (degrees)")
zlabel("NFX")






