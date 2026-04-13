function analyze(signal, fs)
% function analyze(file) plots amplitude spectrum
% of the *.wav file.
N = length(signal);               
c = fft(signal) / N;                    
A = 2 * abs(c(2 : floor(N / 2) * 2));         
f = (1 : floor(N / 2) * 2 - 1) * fs / N;        
semilogy(f, A,'r')
axis([0 fs/2 10^-4 1])