function weight = tire_weight_load_transfer(a, param)
% OBSOLETE
%TIRE_WEIGHT_LOAD_TRANSFER Get the change in tire weights from acceleration
    [dW_f, dW_r, dW_x] = get_load_transfer(a, param);

    weight(1) = 0.5 * dW_x + dW_f;
    weight(2) = 0.5 * dW_x - dW_f;
    weight(3) = -0.5 * dW_x + dW_r;
    weight(4) = -0.5 * dW_x - dW_r;

end

