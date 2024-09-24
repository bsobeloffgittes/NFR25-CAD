function [k_wheel_center_f, k_wheel_center_r, K_f, K_r, K_s_f, K_s_r, R_roll] = get_stiffnesses(const)
%GET_STIFFNESSES Calculates roll stiffness, wheel center rates, etc based
% on car parameters

    % Wheel Center Rates (wheel rate without tire rate)
    k_wheel_center_f = 1 ./ ((1 ./ const.k_wf) - (1 ./ const.k_t));
    k_wheel_center_r = 1 ./ ((1 ./ const.k_wr) - (1 ./ const.k_t));

    % Front and Rear roll stiffnesses
    K_f = (((const.k_wf * const.track(2) .^ 2) ./ 2) - const.m_sf * const.H) + const.k_arb_f; % lb-in/rad
    K_r = (((const.k_wr * const.track(2) .^ 2) ./ 2)  - const.m_sr * const.H) + const.k_arb_r; % lb-in/rad

    % Spring roll stiffnesses
    K_s_f = K_f - const.k_arb_f;
    K_s_r = K_r - const.k_arb_r;

    R_roll = const.m_s * const.g * const.H / (K_f + K_r); % roll rate in radians

end