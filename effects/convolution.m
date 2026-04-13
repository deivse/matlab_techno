function y1 = convolution(signal, ir, mix_factor)

    % Define the custom convolution function
    conv_reverb = @(h, x) ...
        real(ifft(fft(h, 2.^nextpow2(length(x) + length(h) - 1)) .* ...
                  fft(x, 2.^nextpow2(length(x) + length(h) - 1))));

    num_ch = size(ir, 1);
    y1 = zeros(num_ch, length(conv_reverb(ir(1, :)', signal(1, :)')));
    for ch = 1:num_ch
        signal_ch = min(size(signal, 1), num_ch);
        % Perform convolution using custom and built-in functions
        y1(ch, :) = conv_reverb(ir(ch, :)', signal(signal_ch, :)'); % Convolution with custom function
        y1(ch, :) = y1(ch, :) / max(abs(y1(ch, :))); % Normalize the output
    end
    y1 = y1(:, 1:size(signal, 2));
    if (size(signal, 1) < num_ch) 
        signal = mono_to_stereo(signal);
    end
    y1= mix(signal, y1, mix_factor);
end
