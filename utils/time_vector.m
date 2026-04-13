function t=time_vector(fs, duration)
    sample_len_secs = 1/fs;
    t = 0:sample_len_secs:(duration - sample_len_secs);
end