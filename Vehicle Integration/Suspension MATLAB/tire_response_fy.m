function fy = tire_response_fy(alpha, fz)
    % Note: tire data gives moments in ft-lb, however this function
    % converts to in-lb
    % Note 2: the TTC states that actual response values are about 2/3 of
    % testing values due to high-grip environment.

fz(fz > 0) = 0;

%     if fz >= 0
%         fy = 0;
%     else
    
        correction_coeff = 0.5;
    
        % Load coefficient file
        coeffs = load('magic_coefficients.mat');
        
        % Get coefficients from loaded file
        P2 = coeffs.magic_coefficients.FY_coeff;
    
        % Use Pacejka4 magic formula to get lateral force
        D = (P2(1) + P2(2) / 1000 * fz) .* fz;
        fy = D .* sin(P2(4) * atan(P2(3) .* alpha));
    
        % Correct to real-world values
        fy = fy * correction_coeff;

%     end

end