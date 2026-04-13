function out = mix(a, b, t)
    out = a .* (1 - t) + b .* t;
end