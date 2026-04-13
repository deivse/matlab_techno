function sound=bass_pluck(freq, t) 
    noise = randn(1,length(t));
    bass   = sin(2*pi*freq*t);
    clipped = min(bass * 5, 1);
    am = clipped .* cos(2*pi*freq*2*t);
    
    duration = t(length(t));
    envelope   = interp1([0 0.025 0.4 0.25 1] .* duration, [0 1 0.25 0.2 0], t);
    sound = mix (am, am.*noise, 0.001).*envelope;
end