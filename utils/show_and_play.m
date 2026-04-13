function show_and_play(fs, t, signal)
    subplot(3, 1, 1)
    
    plot(t, signal)
    axis tight
    xlabel('Time [s]')
    ylabel('Amplitude')

    title("Amplitude plot")

    subplot(3, 1, 2)
    
    spectrogram(signal, 150, 100,1000, "yaxis")
    title("Spectrogram")

    subplot(3, 1, 3)
    
    analyze(signal, fs)
    xlabel('Frequency');
    ylabel('Frequency contribution');

    title("Overall frequency composition")

    soundsc(signal, fs);
end 