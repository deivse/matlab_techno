function x = fm_kick(f, t)
    % High modulation factor at the beginning to get the transient.
    amount = 6* adsr_generic([0 1 0.6 0.8 0], [0 1e-10 0.3 0.8 1], t);
    % Slightly vary mod frequency for some juice
    mod_freq= 1.95 * f * adsr_generic([0, 3, 1, 0.5, 1], [0, 1e-10, 0.1, 0.8, 1], t);
    x = fm_sin(f, amount, mod_freq, t);
    x = x .* exp(-t./0.2) .* adsr_generic([0, 1, 0.9, 0.1, 0], [0, 1e-10, 0.2, 0.6, 1], t);
    x = clip(x*1.88, -1, 1);
    x = x / max(x);
end