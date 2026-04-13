classdef Wavetable
    %WAVETABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data
        sample_length
        fs
    end
    
    methods
        function self = Wavetable(data, sample_length, fs)
            %WAVETABLE Creates a wavetable synth instance.
            % - data: the wavetable data - a contiguous array of 
            %         sample data of length num_samples*sample_length
            % - sample_length: the length of a single wavetable sample
            % - fs: the sampling frequency.
            self.data = data;
            self.sample_length = sample_length;
            self.fs = fs;
        end

        function out=pad_single_note(self, freq, t)
            len_samples = length(t);
            ampl_envelope = adsr_generic([0 1 0.2 0.2 0], [0 0.25 0.56 0.560001 1], t);
           
            index_envelope = ones(1, len_samples);
            tmp = adsr_generic([0 5 10 20 40], [0 0.25 0.56 0.8 1], t) + 1;
            index_envelope(1, 1:size(tmp, 2)) = tmp;
        
            freq = repmat(freq, [1, len_samples]);
        
            out = self.wavetable_synth(freq, index_envelope);
            out = apply_envelope(out, ampl_envelope);
        end
        
        function out=wavetable_synth(self, frequency, table_index)
            % Creates a signal using wavetable synthesis based on provided
            % per-sample frequency and table index (see get_wavetable_lerp).
            % 
            % Args:
            %   table (struct): A structure containing the wavetable data and sample length.
            %       - table.data (matrix): The wavetable data.
            %       - table.sample_length (int): The length of each sample in the wavetable.
            %   fs (int): The sampling frequency of the output signal.
            %   frequency (vector): A vector of frequencies for each sample in the output signal.
            %   table_index (vector): A vector of table indices for each sample in the output signal.
            %
            % Returns:
            %   out (vector): The synthesized output signal.
        
            out_length_samples = size(table_index, 2);
            out = zeros(1, out_length_samples);
               
            index = 0.;
            for i = 1:1:out_length_samples
                % Step size for reading the table
                delta = frequency(1, i) * self.sample_length / self.fs;
                index = mod(index + delta, self.sample_length);
        
                sample = [self.get_wavetable_lerp(table_index(i)); 0];
                sample(size(sample, 2)) = sample(1, 1);  % Wrap the table for interpolation
                
                one_ix = index + 1;
                fract = one_ix  - floor(one_ix); % Fractional part for interpolation
                A   = sample(floor(one_ix));          % First interpolation point
                B   = sample(ceil(one_ix));           % Second interpolation point
                out(i) = (1 - fract) .* A + B .* fract;
            end
        end
    end

    methods (Access=private)
        function slice=get_wavetable_lerp(self, index)
            % Get a single waveform at a given index from a 
            % contiguous array of sampled waveforms. Linear
            % interpolation is used, so index must not be integer.
            % 
            % Args:
            %  - table: Wavetable (see Wavetable_constructor)
            %  - index: float - index of the sample to get.
            index_A = floor(index);
            index_B = ceil(index);
            
            sl = self.sample_length;
            slice_A = self.data((index_A-1) * sl +1 : index_A * sl, :);
            slice_B = self.data((index_B-1) * sl + 1 : index_B * sl, :);
            
            lerp_factor = index - index_A;
            slice = slice_A * (1-lerp_factor) + slice_B * lerp_factor;
        end
        
    end

end

