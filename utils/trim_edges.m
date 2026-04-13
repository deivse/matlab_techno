function out = trim_edges(input_sound, fade_samples)
    %TRIM_EDGES Applies a fast amplitude envelope at the beginning and end of a sound to avoid clicks
    %   input_sound: The input sound array [num_channels, num_samples]
    %   fade_duration: Duration of the fade-in and fade-out in seconds

    num_samples = size(input_sound, 2);    
    fade_in_envelope = linspace(0, 1, fade_samples);
    fade_out_envelope = linspace(1, 0, fade_samples);
    
    envelope = ones(1, num_samples);
    envelope(1:fade_samples) = fade_in_envelope;
    envelope(end-fade_samples+1:end) = fade_out_envelope;
    
    out = input_sound .* envelope;
end