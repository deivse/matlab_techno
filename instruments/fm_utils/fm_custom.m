function x = fm_custom(carrier_fn, carrier_freq, amount, mod_signal, t)
    if isscalar(amount)
        x = carrier_fn(2*pi*carrier_freq*t + amount * mod_signal);
    else
        x = carrier_fn(2*pi*carrier_freq*t + amount .* mod_signal);
    end
end