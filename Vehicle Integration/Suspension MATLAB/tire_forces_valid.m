function valid = tire_forces_valid(F, SA)
% TIRE_FORCES_VALID Checks whether the forces on the tire are valid or not
%   Inputs:
%       F: column vector of forces
%   Outputs:
%       valid: bool if forces are valid

    

    % Check if the wheel weight is negative
    weight_valid = F(3) < 0;

    if ~weight_valid
        valid = false;
%         fprintf("Tire weight invalid\n")
        return;
    end

    % Calculate max resultant grip for normal force
    FR = tire_response_fx(0, F(3));

    % Check if the lateral and longitudinal forces are valid
%     lat_valid = abs(SA) <= 12;
    lat_valid = abs(F(2)) < abs(FR);
%     if ~lat_valid
%         fprintf("Max slip angle exceeded\n")
%     end

    tire_fx = tire_response_fx(SA, F(3));
    long_valid = isreal(tire_fx) && tire_fx >= abs(F(1));
%     if ~long_valid
%         fprintf("Longitudinal force invalid\n")
%     end

    % Check if all forces are valid
    valid = weight_valid && lat_valid && long_valid;

end