function out=mono_flanger(signal, fs, delay_mix, max_delay, mod_freq_s)
    % 
    % Original flanger implementation, like in the labs.
    % 

    original_mix = 1-delay_mix; % Weight of the original signal
    
    % Compute maximum delay in samples
    maxDelaySamples = round(max_delay * fs);
    
    out = zeros(size(signal));
    fractionalDelay = zeros(size(signal));
    
    for sampleIndex = 1:length(signal)
        % Compute fractional delay for the current sample
        fractionalDelay(sampleIndex) = maxDelaySamples * cos(2 * pi * mod_freq_s * sampleIndex / fs);
        
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
                
                % Combine original and delayed signals
                out(sampleIndex) = original_mix * signal(sampleIndex) + ...
                                             delay_mix * interpolatedSample;
            end
        end
    end
end