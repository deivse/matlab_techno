function output = overdrive(input, gain, level)
    %   input: The input audio signal
    %   gain: The gain applied to the input signal
    %   level: The output level control
    
    processed = gain .* input;
    output = tanh(processed);
    output = level .* output;
end