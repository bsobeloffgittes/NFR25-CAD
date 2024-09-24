function v_out = mirror_rl(v_in)
%LR_MIIROR Mirrors a vector from left to right of car

    v_out = [1; -1; 1] .* v_in;
end