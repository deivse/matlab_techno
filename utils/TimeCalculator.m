classdef TimeCalculator
    %TIMECALCULATOR Utility class for calculating durations and time vectors
    %   Provides methods to calculate durations and time vectors for
    %   different musical note types based on the sampling frequency (fs)
    %   and beats per minute (bpm).
    
    properties
        fs  % Sampling frequency
        bpm % Beats per minute
        beatsPerBar;
    end
    
    methods
        function obj = TimeCalculator(fs, bpm)
            %TIMECALCULATOR Construct an instance of this class
            %   Initialize the sampling frequency and beats per minute
            obj.fs = fs;
            obj.bpm = bpm;
            obj.beatsPerBar = 4; % Assuming 4/4 time signature
        end
        
        function duration = duration(obj, fractionOfBar)
            %DURATION Calculate the duration of a note as a fraction of a bar
            %   fractionOfBar: Fraction of a whole bar (e.g., 1/16 for a sixteenth note)
            duration = (60 / obj.bpm) * obj.beatsPerBar * fractionOfBar;
        end

        function d_samples = duration_samples(obj, fractionOfBar)
            d_samples = round(obj.duration(fractionOfBar) * obj.fs);
        end
        
        function t = tvec(obj, fractionOfBar)
            %TVEC Generate a time vector for a given fraction of a bar
            %   fractionOfBar: Fraction of a whole bar (e.g., 1/16 for a sixteenth note)
            duration = obj.duration(fractionOfBar);
            t = time_vector(obj.fs, duration);
        end

        function t = tvec_like(obj, sound)
            t = time_vector(obj.fs, obj.get_duration_secs(sound));
        end

        function l = get_duration_secs(obj, sound)
            l = size(sound, 2) / obj.fs;
        end

        function d = get_duration_bars(obj, sound)
            d = obj.get_duration_secs(sound) / (60 / obj.bpm) * obj.beatsPerBar;
        end

        function out = repeat_for(obj, fraction_of_bar, sound)
            %REPEATFOR Repeat a sound for a given fraction of a bar
            %   sound: The input sound array
            %   fraction_of_bar: Fraction of a whole bar to repeat the sound for
            
            duration = obj.duration(fraction_of_bar);
            num_samples = round(duration * obj.fs);
            
            num_repeats = ceil(num_samples / size(sound, 2));
            repeated_sound = repmat(sound, 1, num_repeats);
           
            out = repeated_sound(:, 1:num_samples);
        end

        function out = extend_to(obj, fraction_of_bar, sound)
            duration = obj.duration(fraction_of_bar);
            num_samples = round(duration * obj.fs);
            
            out = zeros(size(sound, 1), num_samples);
            out(:, 1:size(sound, 2)) = sound;
        end

        function out = shorten_to(obj, fraction_of_bar, sound)
            duration = obj.duration(fraction_of_bar);
            num_samples = round(duration * obj.fs);
            out = sound(:, 1:num_samples);
        end

        function out = silence(obj, fraction_of_bar, ch)
            out = zeros(ch, obj.duration_samples(fraction_of_bar));
        end
    end
    methods(Static)
        function out = add_at_beginning(sound1, sound2)
            % MIX Adds sound2 to sound1 aligning at beginning of sound 1.
            assert(size(sound2, 2) <= size(sound1, 2));
            out = sound1;
            out(:, 1:size(sound2, 2)) = out(:, 1:size(sound2, 2)) + sound2;
        end

        function out = add_at_end(sound1, sound2)
            % ADD_AT_END Adds sound2 to the end of sound1.
            %   sound1: The base sound array
            %   sound2: The sound array to be added at the end of sound1
            
            % Ensure sound1 and sound2 have the same number of channels
            assert(size(sound1, 1) == size(sound2, 1), 'sound1 and sound2 must have the same number of channels');
            
            % Concatenate sound2 to the end of sound1
            out = sound1;
            start = size(sound1, 2) - size(sound2, 2);
            out(:, start + 1: size(sound1, 2)) = out(:, start + 1: size(sound1, 2)) + sound2;
        end

        function out = tile_and_mix(sound1, sound2)
            % TILE Tiles sound2 over sound1 and adds the result.
            %   sound1: The base sound array
            %   sound2: The sound array to be tiled over sound1
            %   The function repeats sound2 to match the length of sound1
           
            out = sound1 + TimeCalculator.tile_for(sound1, sound2);
        end

        function tiled_sound2 = tile_for(sound1, sound2)
            % TILE_LIKE Same as tile, but returns tiled sound2 without
            % mixin with sound1.
            
            assert(size(sound2, 2) <= size(sound1, 2), 'sound2 must be shorter than or equal to sound1');
            
            % Calculate the number of times sound2 needs to be repeated
            num_repeats = ceil(size(sound1, 2) / size(sound2, 2));
            
            % Repeat sound2 and trim to match the length of sound1
            tiled_sound2 = repmat(sound2, 1, num_repeats);
            tiled_sound2 = tiled_sound2(:, 1:size(sound1, 2));
        end
    end
end