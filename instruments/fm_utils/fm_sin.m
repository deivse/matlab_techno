function x = fm_sin(carrier_freq, amount, mod_freq, t)
    x = fm_custom(@(s) sin(s), carrier_freq, amount, sin_hz(mod_freq, t), t);
end
