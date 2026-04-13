function x = fm_hihat(f, t, fs)
    % Use white noise with a relatively high factor as a modulator
    amount = 5* adsr_generic([0 1 0.5 0.3 0], [0 1e-10 1e-5 0.8 1], t);

    x = fm_custom(@(s) sin(s), f, amount, randn(1, length(t)), t);

    % Short envelope
    x = x .* exp(-t./0.1) .* adsr_generic([0 1, 0.9, 0.1, 0], [0 1e-10, 0.2, 0.6, 1], t);
    x = clip(x*1.2, -1, 1); % Saturate
    x = highpass(x, 3000, fs); % Filter out lows
    x = x / max(x) * 0.7;
end