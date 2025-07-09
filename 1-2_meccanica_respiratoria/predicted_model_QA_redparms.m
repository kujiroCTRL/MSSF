function predicted_QA = predicted_model_QA_redparms(theta, PaO, t)
    % Estrarre i parametri dal vettore theta
    a2 = theta(1); a1 = theta(2); a0 = theta(3);
    
    % Definire la tf predetta
    s = tf('s');
    
    W = [a2 a1 a0] * [s^2; s; 1];
    W_PaO_QA  = minreal(s / W);
    
    % predict output
    predicted_QA = lsim(W_PaO_QA, PaO, t);
end