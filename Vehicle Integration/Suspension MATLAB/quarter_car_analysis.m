clear
close all

% Quarter of the car, front wheel

param = define_params();

% VEHICLE PARAMEETERS

m_s = param.m_sf / 2; % blob
k_w = param.k_wheel_center_f; % lbf / in
c_w = 18; %  lbf / (in/s)
m_u = param.m_u(1); % blob

% Ride frequency and damping ratio
w_ride = 1/2/pi * (((k_w*param.k_t) / (k_w + param.k_t))/m_s)^0.5; % ride frequency in Hz
DR = c_w ./ (2 * sqrt(m_s * (k_w * param.k_t / (k_w + param.k_t)))); % Damping ratio

% Numerical Model Inputs
t_final = 1; % Seconds
dt = 0.001;
t = 0:dt:t_final;
a_s = zeros(size(t));
v_s = zeros(size(t));
y_s = zeros(size(t));
a_u = zeros(size(t));
v_u = zeros(size(t));
y_u = zeros(size(t));
F_s = zeros(size(t));
F_u = zeros(size(t));

v = 880; % in/s

x = linspace(0, t_final * v, length(t));

y_g = zeros(size(t));

bump_height = 0.375;

y_g(x <= param.tire_d / 2) = max(0, min(bump_height, sqrt((param.tire_d / 2) .^ 2 - ((param.tire_d / 2) - (x(x <= param.tire_d / 2)) .^ 2)) - (param.tire_d / 2) + bump_height));

y_g(x > param.tire_d / 2) = bump_height * ones(size(y_g(x > param.tire_d / 2)));


for ii = 1:(length(t)-1)

    a_s(ii) = (-k_w*(y_s(ii)-y_u(ii)) - c_w*(v_s(ii)-v_u(ii)) + F_s(ii))/m_s; % acceleration of sprung mass
    a_u(ii) = (-param.k_t * (y_u(ii)-y_g(ii)) + k_w*(y_s(ii)-y_u(ii)) + c_w*(v_s(ii)-v_u(ii)) + F_u(ii))/m_u; % acceleration of unsprung mass

    v_s(ii+1) = a_s(ii)*dt + v_s(ii); % Step in time
    v_u(ii+1) = a_u(ii)*dt + v_u(ii);
    y_s(ii+1) = v_s(ii)*dt + y_s(ii);
    y_u(ii+1) = v_u(ii)*dt + y_u(ii);

%     y_g(ii+1) = y_g(ii);

end


figure();
plot(t,y_s);
hold on;
plot(t, y_u);
plot(t, y_g);

plot(t, y_s - y_u);

legend('Sprung', 'Unsprung', 'Ground', 'Non-Tire Displacement');

xlabel('Time')
ylabel('Displacement (Inches)')

f_s = m_s * (a_s + param.g);

figure();
plot(t, f_s);

xlabel("Time");
ylabel("Force acting on sprung mass")

