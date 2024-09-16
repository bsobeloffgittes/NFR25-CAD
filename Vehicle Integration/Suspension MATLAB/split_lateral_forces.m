function fy = split_lateral_forces(fy_total, fz, param)
% OBSOLETE

    % Use lateral moment equilibrium to split lateral forces between front
    % and rear track
    fy_f = fy_total * (param.track(1) / 2 - param.cg(1)) / param.track(1);
    fy_r = fy_total - fy_f;

    % Get the distribution of forces in front and rear tracks
    fz_norm_f = fz(1:2) ./ sum(fz(1:2));
    fz_norm_r = fz(3:4) ./ sum(fz(3:4));

    fy = [fy_f * fz_norm_f, fy_r * fz_norm_r];


end