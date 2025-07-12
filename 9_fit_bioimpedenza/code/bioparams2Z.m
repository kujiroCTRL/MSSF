function Z = bioparams2Z(Rinf, R0, tau, alpha, freq)
    Z = Rinf + (R0 - Rinf) ./ (1 + (1i * 2 * pi * freq * tau) .^ (1 - alpha));
end