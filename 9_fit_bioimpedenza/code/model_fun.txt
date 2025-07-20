function [y_pred] = model_fun(params, freq, Z_HF2)
    Rinf = params(1);
    R0 = params(2);
    tau = params(3);

    if(length(params) >= 4)
        alpha = params(4);
    else
        alpha = 0;
    end
    
    Z = bioparams2Z(Rinf, R0, tau, alpha, freq);
    % Z = Z + Z_HF2;
    y_pred = [real(Z), imag(Z)];
end