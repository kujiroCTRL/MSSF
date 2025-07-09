function [f, gain, phase] = time2frequency(output_signal, fs)
    output_signal = output_signal(:);
    
    N = length(output_signal);
    
    window = hanning(N);
    output_windowed = output_signal .* window;
    
    output_fft = fft(output_windowed);
    
    H = output_fft;
    
    if mod(N, 2) == 0
        H = H(1:N/2+1);
    else
        H = H(1:(N+1)/2);
    end
    
    f = (0 : (length(H)-1))' * (fs / N);
    
    gain = abs(H);
    phase = angle(H);
end