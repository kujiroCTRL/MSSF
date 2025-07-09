function [figure1, figure2, figure3] = plotCellParms(r_cell, d_mem, eps_med, sig_med, eps_mem, sig_mem, eps_int, sig_int, f)
    CC_f_CM = calculateClausiusMossotti(r_cell, d_mem, eps_med, sig_med, eps_mem, sig_mem, eps_int, sig_int, 2 * pi * f);

    figure1 = figure();
    yyaxis left; semilogx(f, real(CC_f_CM)); ylabel("\Re(f_{CM})"); hold on;
    yyaxis right; semilogx(f, imag(CC_f_CM)); ylabel("\Im(f_{CM})");
    xlabel("Frequency (MHz)");
    
    CC_S = r_cell ^ 3 * CC_f_CM;
    figure2 = figure();
    semilogx(f, abs(CC_S) .^ (1 / 3)); ylabel("abs(S)^{1/3}");
    xlabel("Frequency (MHz)");
    
    figure3 = figure();
    semilogx(f, angle(CC_S)); ylabel("phase(S)");
    xlabel("Frequency (MHz)");
end