function hihat = stereo_fm_hihat(f_left, f_right, t, fs)
    hihat_L = fm_hihat(f_left, t, fs);
    hihat_R = fm_hihat(f_right, t, fs);
    hihat = make_stereo(hihat_L, hihat_R);
end

