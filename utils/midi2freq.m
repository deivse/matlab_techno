function f = midi2freq(note)
    f = 2^((note - 69)/12)*440;
end

