classdef PhaseVocoder
    properties
        window_func
        window_length
        window_shift
    end
    
    methods
        function self = PhaseVocoder(window_func, window_length)
            self.window_func = window_func;
            self.window_length = window_length;
            self.window_shift = window_length / 4;
        end
        
        function X = analyze(self, signal)
            signal = signal - mean(signal);         % Remove DC offset
            signal = signal ./ max(abs(signal));    % Normalize the signal
            N = size(signal, 2);                     % Signal length in samples
            num_ch = size(signal, 1);
        
            frame_start_positions = 0 : self.window_shift : N-self.window_length;
            X = zeros(self.window_length, num_ch, size(frame_start_positions, 2));                                 % Initialize matrix for analysis
            
            k = 1;

            window = self.window_func(self.window_length)';
            for ch = 1:num_ch
                for start = frame_start_positions
                    frame = signal(:, start + 1 : start + self.window_length);
                    frame = frame .* window;
    
                    X(:, ch, k) = fft(frame(ch, :))';  % Perform FFT on the windowed frame
                    k = k + 1;
                end
            end
        end

        function out = synthesize(self, Y_all_ch)
            assert(numel(size(Y_all_ch)) == 3);
            num_ch = size(Y_all_ch, 2);
            N_new = size(Y_all_ch, 3) * self.window_shift + self.window_length;
            out = zeros(num_ch, N_new);  % Initialize output signal
            window = self.window_func(self.window_length)';
            for ch = 1: num_ch
                Y = squeeze(Y_all_ch(:, ch, :));
                k = 1;
                for start = 0:self.window_shift:(size(Y,2)-1) * self.window_shift     
                    segment = (ifft(Y(:,k), self.window_length, 'symmetric'))' .* window;  % Inverse FFT and windowing
                    out(ch, (start+1):(start+self.window_length)) = out((start+1):(start+self.window_length)) + segment;  % Overlap-add
                    k = k + 1;
                end
            end
        end
    end

end