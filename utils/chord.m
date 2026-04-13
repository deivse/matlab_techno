function out = chord(base_note, offsets, synth_fn, t)
% Creates a chord by combining output of synth_fn for multiple notes given
% by base_note and offsets. 
% - base_note - a MIDI note number
% - offsets - array of offsets from base (first note is always base)
%             e.g. if offsets has length 2 then the chord has 3 notes.
% - synth_fn: out=synth_fn(freq, t)
% - t - time vector for synth_fn
    out = synth_fn(base_note, t);
    for offset = offsets
       out = out + synth_fn(midi2freq(base_note + offset), t);
    end
    out = out / (1 + length(offsets));
end

