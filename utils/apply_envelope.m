function out=apply_envelope(sound, env)
    % Applies an envelope to `sound`. The sound may be longer than the
    % envelope.
    out = zeros(size(sound));
    if (size(env, 2) < size(sound, 2))
        out(:, 1 : size(env, 2)) = sound(:, 1 : size(env, 2)) .* env;
    else
        out = sound .* env(:, 1 : size(sound, 2));
    end
end