clear sound;
fs = 41000;

time = TimeCalculator(fs, 140);
abandoned_building_ir = load_and_resample("abandoned_building_ir.wav", fs)';
concrete_tunnel_ir = load_and_resample("concrete_tunnel_ir.wav", fs)';

%% Wavetable Ambience

[table_ly_data, table_fs] = audioread("wavetable_light_year.wav");

wt_ly = Wavetable(table_ly_data, 256, fs);
wt_amb_low = wt_ly.pad_single_note(midi2freq(16), time.tvec(8));
wt_amb_low = stereo_flanger(wt_amb_low , fs, 1, 0.01, 0.5, 0.2);

wt_amb_high = stereo_pan(wt_ly.pad_single_note(midi2freq(64), time.tvec(16)), -0.6);
wt_amb_high = wt_amb_high + stereo_pan(wt_ly.pad_single_note(midi2freq(45), time.tvec(16)), 0.75);
wt_amb_high = convolution(wt_amb_high, concrete_tunnel_ir, 0.7);

clear sound;
sound(wt_amb_high, fs);

%% Mix Intro Ambiences

clear sound;

mix_intro_1 = wt_amb_low;
mix_intro_2 = time.tile_and_mix(wt_amb_high * 0.15, wt_amb_low);
intro_ambiences = [time.repeat_for(8, mix_intro_1) time.repeat_for(16, mix_intro_2)];
clear sound;
soundsc(mix_intro_2, fs);

%% Bass Plucks

b1 = bass_pluck(44, time.tvec(1/16));
b2 = bass_pluck(42, time.tvec(1/16));

bass = [repmat(b1, 1, 4) repmat(b2, 1, 12)];

bass = time.tile_for(intro_ambiences, bass);

overdrive_amount = adsr_generic([2 4], [0 1], time.tvec_like(bass));
overdrive_amount = overdrive_amount + 0.25 * sin(2 * pi * 0.076 * time.tvec_like(bass));
bass = overdrive(bass, overdrive_amount, 0.5);

bass_amb = intro_ambiences * 0.75 + bass;

clear sound;
soundsc(bass_amb, fs);

%% Add Kick

clear sound;
single_kick_intro = overdrive(fm_kick(10, time.tvec(1/2)), 1.8, 0.5);
single_kick_intro  = time.extend_to(1, single_kick_intro );
kick_intro = time.tile_for(bass_amb, single_kick_intro);
kick_intro_adsr = adsr_generic([0 0.8 1], [0 0.5 1], time.tvec_like(bass_amb));
kick_intro = convolution(kick_intro, abandoned_building_ir, 0.06);
bass_amb_kick = bass_amb + kick_intro_adsr .* kick_intro .* 0.75;
soundsc(bass_amb_kick, fs);

%% Hi-Hats

short_hat = @() stereo_fm_hihat(midi2freq(65), midi2freq(50), time.tvec(1/16), fs);
long_hat = stereo_fm_hihat(100, 100, time.tvec(1/2), fs);

hats = time.repeat_for(8, long_hat);
short_hats = [
    0.8 * short_hat()...
    0.6 * short_hat()...
    0.5 * short_hat()...
    0.6 * short_hat()...
    0 * short_hat()...
    0.6 * short_hat()...
    0.5 * short_hat()...
    0.6 * short_hat()...
    0 * short_hat()...
    0.6 * short_hat()...
    0.625 * short_hat()...
    0.65 * short_hat()...
    0.675 * short_hat()...
    0.7 * short_hat()...
    0.6 * short_hat()...
    0.5 * short_hat()...
];
long_hats_volume_env = adsr_generic([0 0.6], [0 1], time.tvec_like(hats));
hats = hats .* long_hats_volume_env;
hats = stereo_pan(hats, -0.1);
short_hats = stereo_pan(short_hats, -0.25);

hats = time.tile_and_mix(hats, short_hats * 0.5);
hats = convolution(hats, abandoned_building_ir, 0.1);

intro = bass_amb_kick;
intro = time.add_at_end(intro, hats * 0.5);

overdriven_hats_1_bar = hats(:, size(hats, 2) - time.duration_samples(1) : size(hats, 2));
overdriven_hats_1_bar = sum(overdriven_hats_1_bar, 1) / 2;
overdriven_hats_1_bar = stereo_flanger(overdriven_hats_1_bar, fs, 0.8, 0.01, 0.12, 0.1);
overdriven_hats_1_bar = overdrive(overdriven_hats_1_bar, 2, 0.8);

overdriven_hats_1_bar = convolution(overdriven_hats_1_bar, ...
    abandoned_building_ir, 0.1);

intro(:, size(intro, 2) - time.duration_samples(1): size(intro, 2)) = ...
    time.add_at_beginning(overdriven_hats_1_bar * 1.4, ...
          convolution(single_kick_intro, concrete_tunnel_ir, 0.4));
clear sound;
soundsc(intro(:, size(intro, 2) - size(hats, 2) + 1 : size(intro, 2)), fs);

%%

kick_drop = overdrive(fm_kick(20, time.tvec(1/4)), 3, 0.5);
kicks_drop = time.repeat_for(2, kick_drop);

extra_kick = overdrive(fm_kick(18, time.tvec(1/4)), 2, 0.5);

extra_kick_pos = time.duration_samples(3/4 + 1/16);
extra_kick_len = size(extra_kick, 2);
kicks_drop(:, extra_kick_pos + 1: extra_kick_pos + extra_kick_len) = ...
    kicks_drop(:, extra_kick_pos + 1: extra_kick_pos + extra_kick_len) ...
    + extra_kick;

kicks_drop = convolution(kicks_drop, concrete_tunnel_ir, 0.15);
clear sound;
soundsc(kicks_drop, fs);

%% Drop 1

b1 = bass_pluck(44, time.tvec(1/16));
b1 = time.add_at_beginning(b1, bass_pluck(80, time.tvec(1/32)));
b2 = bass_pluck(42, time.tvec(1/16));

bass = [repmat(b1, 1, 4) repmat(b2, 1, 12)];

bass = time.tile_for(kicks_drop, bass);

bass_flanger = stereo_flanger(bass, fs, 1, 0.0001, 0.5, 0.2);
bass_mix = overdrive(bass, 6, 0.5);
bass_mix = bass_mix + bass_flanger * 0.1;

function out = shifted_up_flanger(bass, st, fs)
    out = pitch_shift(overdrive(bass, 1, 0.5), st);
    out = stereo_flanger(out, fs, 1, 0.01, 0.1, 0.4);
end

bass_shifted_up1 = shifted_up_flanger(bass, 12, fs);
bass_shifted_up2 = shifted_up_flanger(bass, 13, fs);
bass_shifted_up3 = shifted_up_flanger(bass, 10, fs);

drop_base = kicks_drop * 1.5 + bass_mix;

bass_shifted_up_mix = 0.2;
drop_A1 = repmat(drop_base + bass_shifted_up1 * bass_shifted_up_mix, 1, 2);
drop_A21 = drop_base + bass_shifted_up2 * bass_shifted_up_mix;
drop_A22 = drop_base + bass_shifted_up3 * bass_shifted_up_mix;
drop_A = [drop_A1 drop_A21 drop_A22];

sh1 = pitch_shift(overdrive(bass, 4, 0.5), 12);
sh1 = stereo_flanger(sh1, fs, 1, 2, 0.1, 0.4);
sh2 = pitch_shift(overdrive(bass, 2, 0.5), 24);
sh2 = stereo_flanger(sh2, fs, 1, 5, 0.1, 0.4);
delayed_noise = sh1 + sh2;
delayed_noise = flip(delayed_noise, 2);
transition = [...
    repmat(delayed_noise(:, 95000: 96000), 1, 40)...
    repmat(delayed_noise(:, 70000: 72500), 1, 5)...
    repmat(delayed_noise(:, 70000: 70500), 1, 35)...
];
transition = transition(:, 50:size(transition, 2));
transition = sum(transition, 1) / 2;
transition = stereo_flanger(transition, fs, 0.5, 0.01, 0.1, 0.3);
transition = convolution(transition, concrete_tunnel_ir, 0.35);
transition = transition * 1.5;

drop_B1 = drop_A1;
drop_B21 = drop_A21;
drop_B22 = drop_A22;
drop_B = [drop_B1 drop_B21 drop_B22];

xxx = time.extend_to(1/16, repmat(delayed_noise(:, 95000: 96000), 1, 1));
xxx2 = time.extend_to(1/2, repmat(delayed_noise(:, 98000: 99000), 1, 1));
xxx2 = [zeros(2, time.duration_samples(1/2)) xxx2];
xxx = convolution(stereo_pan(sum(xxx, 1) / 2, -0.65), abandoned_building_ir, 0.1);
xxx2 = convolution(xxx2, concrete_tunnel_ir, 0.6);

drop_B = time.tile_and_mix(time.tile_and_mix(drop_B, xxx * 0.75), xxx2);

breakk = flip(intro, 2);
breakk = breakk(:, time.duration_samples(1): time.duration_samples(4));
breakk = overdrive(breakk, 4, 0.75);
breakk = convolution(breakk, abandoned_building_ir, 0.15);

drop_B_wbreak_short = [drop_B(:, 1:time.duration_samples(3)) breakk(:, 1:time.duration_samples(1))];

xxx3 = time.extend_to(1/16, repmat(delayed_noise(:, 30000: 32500), 1, 1));
xxx3 = overdrive(xxx3, 1, 0.3);
xxx3 = time.extend_to(1, [zeros(2, time.duration_samples(7/8)) xxx3]);
xxx3 = convolution(xxx3, abandoned_building_ir, 0.1) * 0.9;
xxx3 = convolution(xxx3, concrete_tunnel_ir, 0.3);

drop_B_wbreak = [...
    drop_B(:, 1:size(drop_B, 2) - time.duration_samples(1)) ...
    breakk(:, 1:time.duration_samples(1)) ...
];
drop_B_wbreak_and_thing = [...
    time.tile_and_mix(drop_B(:, 1:size(drop_B, 2) - time.duration_samples(1)), xxx3)...
    breakk(:, 1:time.duration_samples(1)) ...
];

drop = [...
    time.add_at_end(drop_A, transition) ...
    drop_B_wbreak_and_thing ...
    drop_B_wbreak breakk ...
];
clear sound;
soundsc(drop, fs);

%% Calm Between Drops

[table_roland_data, table_fs] = audioread("wavetable_roland.wav");
wt_roland = Wavetable(table_roland_data, 256, fs);

calm_bass = @(f, bar_fraction) ...
    trim_edges(convolution(overdrive(wt_roland.wavetable_synth(...
        repmat(f, 1, time.duration_samples(bar_fraction)), ...
        2 * 1 + sin_hz(time.duration(1/8), time.tvec(bar_fraction)) ...
    ), 1.1, 1), concrete_tunnel_ir, 0.6), 100);

interlude_bass = [ ...
    calm_bass(44, 4) calm_bass(47, 4)
];
interlude_bass = repmat(interlude_bass, 1, 2);

granular = GranularSynthesizer(fs);

grain_src = load_and_resample("pad2.wav", fs)';

layer_cfg.pitch_shift = 12;
layer_cfg.pitch_shift_variance = 0.01;
layer_cfg.duration = time.get_duration_secs(interlude_bass);
layer_cfg.grain_length = 0.5;
layer_cfg.offset = -0.9;
layer_cfg.offset_variance = 0.1;
layer_cfg.sample_pos = 120;
layer_cfg.sample_pos_shift_per_grain = 0.02;
layer_cfg.sample_pos_variance = 0.1;
layer_cfg.window_func = @(t) granular.gauss_win(t, length(t)/10, layer_cfg.grain_length * 0.5 * fs);

interlude_grain_layer = granular.grain_layer(grain_src, layer_cfg);
interlude_grain_layer = convolution(interlude_grain_layer, concrete_tunnel_ir, 0.2);

interlude_bg = interlude_bass + trim_edges(interlude_grain_layer, time.duration_samples(1));
%% 

kick_dnb = overdrive(fm_kick(15, time.tvec(1/4)), 2, 1);
kick_dnb = time.extend_to(1/4, kick_dnb);

snare_dnb = snare(47, 50, time.tvec(1/4));
snare_dnb = overdrive(snare_dnb, 1, 0.8);
snare_dnb = time.extend_to(1/4, snare_dnb);
snare_dnb = convolution(snare_dnb, abandoned_building_ir, 0.1);

kicks_dnb = [kick_dnb, time.silence(1/4 + 1/8, 1), kick_dnb];
kicks_dnb = time.extend_to(1, kicks_dnb);
snares_dnb = [time.silence(1/4, 2), snare_dnb, time.silence(1/4, 2), snare_dnb];
snares_dnb = time.extend_to(1, snares_dnb);

dnb_drums = kicks_dnb + snares_dnb;
dnb_drums = time.tile_for(interlude_bg, dnb_drums);
drum_env = adsr_generic([0, 0, 0.2 1], [0, 0.2, 0.7, 1], time.tvec_like(dnb_drums));
dnb_drums = convolution(dnb_drums, concrete_tunnel_ir, 0.1);

od_amount = adsr_generic([1, 3.5], [0, 1], time.tvec_like(interlude_bg));
od_amp = adsr_generic([1, 0.8], [0, 1], time.tvec_like(interlude_bg));

noise = randn(1, size(interlude_bg,2));
noise_env = adsr_generic([0, 0.5, 1], [0, 0.8, 1], time.tvec_like(noise));
noise = noise .* noise_env;
noise = convolution(noise, concrete_tunnel_ir, 1);
% noise = flip(noise, 2);

interlude = overdrive(interlude_bg, od_amount, od_amp) + dnb_drums .* drum_env;
interlude = time.add_at_end(interlude, noise * 0.07);

clear sound;
last_part_of_drop = [drop_B_wbreak_short breakk];
single_kick_intro  = time.shorten_to(1/2, single_kick_intro );
% soundsc(drums, table_fs);
soundsc(interlude, fs);
% soundsc([last_part_of_drop convolution(single_kick_intro, concrete_tunnel_ir, 0.4) interlude * 2], fs);

%% dnb buildup

clear sound;

weird_things = [repmat(pitch_shift(bass_mix, 24), 1, 3) pitch_shift(bass_mix, 25)];
weird_things = overdrive(weird_things, 20, 0.1);
weird_things = convolution(weird_things, concrete_tunnel_ir, 1);
weird_things_env = adsr_generic([0.1, 1], [0, 1], time.tvec_like(weird_things));
weird_things = weird_things .* weird_things_env;

layer_cfg2.pitch_shift = 12;
layer_cfg2.pitch_shift_variance = 0;
layer_cfg2.duration = time.get_duration_secs(interlude_bass);
layer_cfg2.grain_length = 0.25;
layer_cfg2.offset = -0.5;
layer_cfg2.offset_variance = 0;
layer_cfg2.sample_pos = 120;
layer_cfg2.sample_pos_shift_per_grain = 0.1;
layer_cfg2.sample_pos_variance = 7;
layer_cfg2.window_func = @(t) granular.gauss_win(t, length(t)/10, layer_cfg2.grain_length * 0.5 * fs);

dnb_grain_layer = granular.grain_layer(grain_src, layer_cfg2);
dnb_grain_layer = convolution(dnb_grain_layer, concrete_tunnel_ir, 0.2);
dnb_grain_layer = overdrive(dnb_grain_layer, 2, 1);


dnb_buildup = time.tile_and_mix(dnb_drums + interlude_grain_layer ...
    + dnb_grain_layer * 0.5, weird_things * 0.2);
dnb_buildup = time.tile_and_mix(dnb_buildup, overdriven_hats_1_bar);
dnb_buildup = time.add_at_end(dnb_buildup, noise * 0.08);
dnb_buildup = dnb_buildup(:, size(dnb_buildup, 2)/2:size(dnb_buildup, 2));

dnb_b_size = size(dnb_buildup, 2);
dnb_buildup(:, dnb_b_size - time.duration_samples(1) + 1: dnb_b_size) = ...
    breakk(:, 1:time.duration_samples(1)) + ...
    time.shorten_to(1, overdriven_hats_1_bar) + ...
    time.shorten_to(1, dnb_drums);

soundsc(dnb_buildup, fs);

%% Drop 2

hats = overdriven_hats_1_bar;
dnb_drums = dnb_drums(:, 1:size(drop_A, 2));
dnb_drums_nhats = time.tile_and_mix(dnb_drums, hats);

hatbreakk = time.tile_and_mix(breakk, hats);


noiseh = randn(1, size(hatbreakk,2));
noiseh_env = adsr_generic([0, 0.5, 1], [0, 0.8, 1], time.tvec_like(noiseh));
noiseh = noiseh .* noiseh_env;
noiseh = convolution(noiseh, concrete_tunnel_ir, 1);

hatbreakk = hatbreakk + noiseh * 0.5;

drop2 = [...
    time.tile_and_mix(drop_A, dnb_drums) ...
    hatbreakk...
    time.silence(1/4, 2)...
    time.tile_and_mix(drop_B_wbreak_and_thing, dnb_drums_nhats)...
    time.tile_and_mix(drop_B_wbreak_and_thing, dnb_drums_nhats)...
];

clear sound;
soundsc(drop2, fs);

%% Outro

outro_bass = calm_bass(40, 3);
outro_bass = outro_bass .* adsr_generic([1 0.6 0], [0 0.75 1], time.tvec_like(outro_bass));
outro_bass = time.extend_to(4, outro_bass);
outro_bass = overdrive(outro_bass, 5, 1);

outro_bass = convolution(outro_bass, concrete_tunnel_ir, ...
    adsr_generic([0.1 1], [0 1], time.tvec_like(outro_bass))); 

%%

mixdown = [
    intro ...
    drop ...
    convolution(time.extend_to(2, single_kick_intro), concrete_tunnel_ir, 0.4)...
    interlude...
    dnb_buildup...
    drop2...
    outro_bass
];
mixdown = mixdown ./ max(mixdown, [], "all");
clear sound;
soundsc(mixdown, fs);

audiowrite("final_mix.wav", mixdown', fs)
