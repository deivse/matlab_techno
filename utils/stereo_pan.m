function out=stereo_pan(signal, pan_pos)
    % Equal power panning
    % pan_pos in range -1 .. 1

    assert(pan_pos >= -1 && pan_pos <= 1);
    
    if (size(signal, 1) == 1)
        out = repmat(signal, 2, 1);
    else
        out = signal;
    end
    
    out(1, :) = out(1, :) .* sqrt(0.5 * (1 - pan_pos));
    out(2, :) = out(2, :) .* sqrt(0.5 * (1 + pan_pos));
end