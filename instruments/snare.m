function out = snare(sin_freq, fm_freq, t)
    fm = fm_kick(fm_freq, t);
    tau = 0.05;
    tau_noise =0.5;
    
    sin_envelope = exp(-t./tau);
    noise_envelope = exp(-t./tau);

    out = ...
        sin_envelope .* sin_hz(sin_freq, t)...
        + fm * 0.5 + ...
        noise_envelope .* randn(1, length(t));
end

