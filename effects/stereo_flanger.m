function out=stereo_flanger(signal, fs, delay_mix, max_delay, mod_freq_l, mod_freq_r)
    % 
    % Simply running the flanger twice with different mod frequencies
    % provides a very interesting effect.
    % 
    assert(size(signal, 1) == 1)
    out = zeros(2, length(signal));
    out(1, :) = mono_flanger(signal, fs, delay_mix, max_delay, mod_freq_l);
    out(2, :) = mono_flanger(signal, fs, delay_mix, max_delay, mod_freq_r);
end