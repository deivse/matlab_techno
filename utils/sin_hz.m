function out = sin_hz(f, t)
    if isscalar(f)
        out = sin(2*pi*f*t);
    else
        out = sin(2*pi*f.*t);
    end
end