function predicted_Q = predicted_model_Q_allparms(theta, PaO, t)
    % Estrarre i parametri dal vettore theta
    Rc = theta(1); Rp = theta(2); Cs = theta(3); CL = theta(4); Cw = theta(5);
    
    % Definire la tf predetta
    s = tf('s');

    CLw = 1 / CL + 1 / Cw;
    
    a2 = Rc * Rp * Cs;
    a1 = Rc + Rp + Rc * Cs * CLw;
    a0 = CLw;
    
    W = [a2 a1 a0] * [s^2; s; 1];
    W_PaO_QA  = minreal(s / W);
    W_PaO_Paw = minreal((Rp + 1 / s * CLw) * W_PaO_QA);
    W_PaO_Q   = minreal(1 / Rc * (1 - W_PaO_Paw));

    % predict output
    predicted_Q = lsim(W_PaO_Q, PaO, t);
end