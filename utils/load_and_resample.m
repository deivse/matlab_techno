function sound = load_and_resample(filename, fs)
    [sound, fs_sound] = audioread(filename);
    sound = resample(sound, fs, fs_sound);
end