function CC_f_CM = calculateClausiusMossotti(r_cell, d_mem, eps_med, sig_med, eps_mem, sig_mem, eps_int, sig_int, f)
    CC_eps_med = eps_med + sig_med ./ (1i * 2 * pi * f);
    CC_eps_mem = eps_mem + sig_mem ./ (1i * 2 * pi * f);
    CC_eps_int = eps_int + sig_int ./ (1i * 2 * pi * f);

    CC_chi       = (CC_eps_mem / d_mem) ./ (CC_eps_int / r_cell);
    CC_eps_cell  = CC_eps_int .* CC_chi ./ (1 + CC_chi);
    CC_f_CM      = (CC_eps_cell - CC_eps_med) ./ (CC_eps_cell + 2 * CC_eps_med);
end