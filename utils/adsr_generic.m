function env=adsr_generic(values, points, t)
    % Creates an ADSR envelope.
    % - vals [S A D S R] (1x5)
    % - points: [S A D S R] (1x5) in range <0,1>

    points = points .* t(1, size(t, 2));
    env = interp1(points, values, t);
end