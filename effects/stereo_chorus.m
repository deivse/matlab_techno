function out=stereo_chorus(signal, fs, original_mix, delayed_mixes, max_delays, mod_freqs, stereo_width)
    % 
    % Compared to the lab example, this version outputs a stereo mix where
    % each voice has it's own "position in space". The degree of stereo
    % separation can be controlled with the stereo width parameter.
    % 
    
    % Initialize the output signal
    out = stereo_pan(signal, 0) .* original_mix;

    assert(stereo_width >= 0 && stereo_width <= 1);    
    % Linear panning positions scaled by stereo_width
    num_voices = length(delayed_mixes);
    panning_positions = linspace(-1, 1, num_voices) * stereo_width;

    for delayIndex = 1:length(max_delays)
        % Compute the maximum delay in samples for the current delayed copy
        maxDelaySamples = round(max_delays(delayIndex) * fs);
        
        % Initialize fractional delay for the current delayed copy
        fractionalDelay = zeros(size(signal));
        
        % Process each sample
        for sampleIndex = 1:length(signal)
            % Compute fractional delay for the current sample
            fractionalDelay(sampleIndex) = maxDelaySamples * cos(2 * pi * mod_freqs(delayIndex) * sampleIndex / fs);
            
            % Ensure the indices remain valid
            if round(sampleIndex - fractionalDelay(sampleIndex)) > 0 && ...
               round(sampleIndex - fractionalDelay(sampleIndex)) <= length(signal)
               
                % Apply fractional delay interpolation
                lowerIndex = floor(sampleIndex - fractionalDelay(sampleIndex));
                upperIndex = lowerIndex + 1;
                
                % Prevent out-of-bound errors
                if upperIndex <= length(signal) && lowerIndex > 0
                    % Linear interpolation
                    alpha = fractionalDelay(sampleIndex) - floor(fractionalDelay(sampleIndex));
                    interpolatedSample = (1 - alpha) * signal(lowerIndex) + alpha * signal(upperIndex);
                    samples = delayed_mixes(delayIndex) * interpolatedSample;
                    for i = 1:length(samples)
                        out(:, sampleIndex) = out(:, sampleIndex) + ...
                            stereo_pan(samples(i), panning_positions(i));
                    end
                end
            end
        end
    end
end