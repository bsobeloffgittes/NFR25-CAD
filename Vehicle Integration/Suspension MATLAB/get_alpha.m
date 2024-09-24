function alpha = get_alpha(fy,fz)
    % Acts as inverse to tire_response_fx, assuming fz is known

    % Create and apply correction coefficient to match with tire response
    % functions
    correction_coeff = 1;

    fy = fy / correction_coeff;
    
    % Load coefficients from .mat file
    coeffs = load('magic_coefficients.mat');
    P2 = coeffs.magic_coefficients.FY_coeff;
    
    % Use invrese Pacejka4 to get slip angle
    D = (P2(1) + (P2(2) ./ 1000) * fz) .* fz;
    alpha = tan(asin(fy ./ D) ./ P2(4)) ./ P2(3);
end