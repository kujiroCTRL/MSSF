function predicted_Q = predicted_model_Q_redparms(theta, PaO, t)
% Q: E' STRETTAMENTE NECESSARIO INTRODURRE ALTRI 2 PARAMETRI?
    % Estrarre i parametri dal vettore theta
    a2 = theta(1); a1 = theta(2); a0 = theta(3);
    b1 = theta(4);
    
    % Definire la tf predetta
    s = tf('s');
       
    W = [a2 a1 a0] * [s^2; s; 1];
    
    W_PaO_QA  = minreal(s / W);
    W_PaO_Q   = minreal((a0 + b1 * 1 / s) * W_PaO_QA);
    
    % predict output
    predicted_Q = lsim(W_PaO_Q, PaO, t);
end