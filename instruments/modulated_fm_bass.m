function x = modulated_fm_bass(f, t)
    ratio = 0.5;
    a = 3;
    b = 2;
    % Variable modulator frequency
    mod_freq = f* ratio * adsr_generic([0 0 a b b], [0 0.1 0.0100001 0.55 1], t);
    x = fm_sin(f, 2, mod_freq, t);

    x = x.*adsr_generic([0 1 0.6 0.8 0], [0 0.01 0.3 0.8 1], t);

    % Clip for saturation
    x = clip(x*1.6, -1, 1);
    % Normalize
    x = x / max(x);
end