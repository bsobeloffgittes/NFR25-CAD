%% Spring Calculations 

a = 4;   % a is the distance from the rotational point to the 
           % bottom attachment of the spring 
b = 5;     % b is distance from the rotational point for the
           % attachment of spring on the arm 
C1 = 89;   %starting angle of the pedal 

C2 = 66;   % ending angle of pedal after throttle 

% law of cosines 
c1 = sqrt(a^2 + b^2 - (2*a*b*cosd(C1))); % calculates initial x of spring  

c2 = sqrt(a^2 + b^2 - (2*a*b*cosd(C2))); % calculates finally x of spring 

springCompression = c1-c2 ;

% print length of spring 
disp(['Initial length of spring: ', num2str(c1)])
disp(['Final length of spring: ', num2str(c2)])
disp(['Spring Compression (inches) ', num2str(springCompression)])




%% MOMENT CALCULATION 
ThrottleMoment = 20; % force moment for throttle pedal, in-lbs 
LengthOfArm = b; % from rotational center to spring attachment point 
OneSpringMoment = ThrottleMoment/2;
MomentForce = OneSpringMoment/b ; 



A1 = acosd((c1^2 - a^2 - b^2)/(-2*c1*b)) ; % top angle initial 
A2 = acosd((c2^2 - a^2 - b^2)/(-2*c2*b)) ; % top angle initial 

SpringForceInitial = MomentForce / cosd(90-A1); % takes into account that the spring isnt 90 from the pedal
SpringForceFinal = MomentForce / cosd(90-A2); % takes into account that the spring isnt 90 from the pedal

averageForce = (SpringForceInitial + SpringForceFinal)/2; 

K = averageForce / springCompression; 

% disp(['Initial Spring Force Needed of spring: ', num2str(SpringForceInitial)])
% disp(['Initial Spring Force Needed of spring: ', num2str(SpringForceFinal)])

disp(['Average Spring Force Needed of spring: ', num2str(averageForce), newline]);

%% PRELOAD 
ForceAtPreload = 1; % HOW DO U CALCULATE THIS? Should be in pounds

c0_loaded = sqrt(a^2 + b^2 - (2*a*b*cosd(90))); % spring length at 90 

SpringXPreload = ForceAtPreload/K; 

SpringLength = SpringXPreload + c1;


TotalSpringCompression = SpringLength - c2;


disp('SPRING SPECS:')
disp(['Spring K Value (lbs/in): ', num2str(K)])
disp(['DeltaXTotal: ', num2str(TotalSpringCompression)]); 
