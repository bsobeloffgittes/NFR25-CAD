function fx = tire_response_fx(alpha, fz)
    % Note: tire data gives moments in ft-lb, however this function
    % converts to in-lb
    % Note 2: the TTC states that actual response values are about 2/3 of
    % testing values due to high-grip environment.

    fz(fz > 0) = 0;
    
    if fz >= 0
        fx = 0;
    else
        correction_coeff = 2/3;
    
        % Load coefficient file
        coeffs = load('magic_coefficients.mat');
        
        % Get coefficients from loaded file
        P1 = coeffs.magic_coefficients.FR_coeff;
%         P2 = coeffs.magic_coefficients.FY_coeff;
        
        % Get maximum total frictional force
%         fr = P1(1) * fz + P1(2);
        fr = (P1(1) + P1(2)/1000*fz).*fz;
    
        % Use Pacejka4 magic formula to get lateral force
%         D = (P2(1) + P2(2) / 1000 * fz) .* fz;
%         fy = D .* sin(P2(4) * atan(P2(3) .* sa));
        fy = tire_response_fy(alpha, fz);
    
        % Subtract lateral component from resultant to get longitudinal force
        fx = sqrt(fr .^ 2 - fy .^ 2);
    
        % Correct to real-world values
        fx = fx * correction_coeff;
    end

end