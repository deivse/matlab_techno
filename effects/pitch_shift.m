function out = pitch_shift(input, pitch_shift_st)
    vocoder = PhaseVocoder(@gausswin, 4096);
    % vocoder.window_shift = 2048/32;

    % Compute the shift ratio
   
    N1 = round(vocoder.window_shift); % Original window shift
    N2 = round(2^(pitch_shift_st / 12) * N1); % New window shift after semitone shift 
    R = N2 / N1;                      % Ratio for resampling

    out = zeros(size(input));

    num_ch = size(input, 1);
    for ch = 1:num_ch
        X = squeeze(vocoder.analyze(input(ch, :)));
        Xmag = interp1q((0:size(X, 2)-1)', abs(X'), (0:1/R:size(X, 2)-2)');  % Interpolate magnitudes for pitch-shifting
        new_grid = floor(0:1/R:size(X, 2)-2) + 1;  % Map new grid points to the original
        D = diff(angle(X'))';  % Compute phase differences between consecutive frames
        D_new = D(:, new_grid);  % Map the phase differences to the new time grid
        phaseX = cumsum(D_new');  % Integrate phase differences to reconstruct phase
        
        Y = (Xmag .* exp(1i * phaseX))';
        Y = reshape(Y, [size(Y, 1), 1, size(Y, 2)]);
        signal = vocoder.synthesize(Y);
        resampled = resample(signal, N1, N2);  % Adjust the pitch using resampling
        out(ch, 1:size(resampled, 2)) = resampled;
    end
end

