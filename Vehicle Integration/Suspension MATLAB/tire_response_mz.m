
function mz = tire_response_mz(alpha, fz)
    % Note: tire data gives moments in ft-lb, however this function
    % converts to in-lb
    % Note 2: the TTC states that actual response values are about 2/3 of
    % testing values due to high-grip environment.

    fz(fz > 0) = 0;
    
%     if fz >= 0
%         mz = 0;
%     else

        correction_coeff = 0.5;
    
        % Load coefficient file
        coeffs = load('magic_coefficients.mat');
        
        % Get coefficients from loaded file
        P3 = coeffs.magic_coefficients.MZ_coeff;
        
        % use Pacejka4 to get aligning moment
        D = (P3(1) + P3(2) / 1000 * fz) .* fz;
        mz = D .* sin(P3(4) * atan(P3(3) .* alpha));
    
        % Convert mz to in-lb
        mz = mz * 12;
    
        % Correct to real-world valu
        mz = mz * correction_coeff;

%     end

end