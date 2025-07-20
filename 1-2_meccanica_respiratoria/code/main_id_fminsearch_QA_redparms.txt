%{

Esercitazione #2 per MSSF a.a. 24/25
di Lorenzo Casavecchia, m.0350001

Modificare i codici Matlab relativi all’identificazione parametrica del
modello RLC della meccanica respiratoria tramite fminsearch.m, considerando
i due parametri LC ed RC anziché i tre parametri R, L e C. 

Completare il codice per l’identificazione parametrica con il metodo di
Gauss-Newton (i.e., scrivere le routines rlc_fun_two_parameters.m e
jacobian_fun.m). Comprendere i dettagli del codice.

Identificazione parametrica dei parametri ridotti usando
fminsearch, sulla base della misura QA

%}

clc;
clear;
close all;

parms = load("parms.mat", "-mat");
Rp = parms.Rp;
Rc = parms.Rc;
Cs = parms.Cs;
CL = parms.CL;
Cw = parms.Cw;

output_data = load("output_data.mat").ans;

output_data_time = output_data.Time;
output_data_PaO = output_data.Data(:, 1);
output_data_Q = output_data.Data(:, 2);
output_data_V = output_data.Data(:, 3);
output_data_QA = output_data.Data(:, 4);
output_data_VA = output_data.Data(:, 5);

% Veri parametri
CLw = 1 / CL + 1 / Cw;

a2 = Rc * Rp * Cs;
a1 = Rc + Rp + Rc * Cs * CLw;
a0 = CLw;
theta_true = [a2; a1; a0];

% Stima iniziale
theta_init = theta_true .* (1 + (rand(size(theta_true)) - .5) * .8);
max_iter = 100; % Numero massimo di iterazioni

options = optimset("MaxIter", max_iter);
% Algoritmo di ottimizzazione
[theta_est, obj_fun_val, exitflag, output] = ...
    fminsearch( ...
        'obj_fun_QA_redparms', ...
        theta_init, ...
        options, ...
        output_data_QA, ... % La stima è basata sulla sola misura di QA
        output_data_PaO, ... % e l'ingresso è PaO
        output_data_time ...
    );

theta_names = ["a2", "a1", "a0"];

theta_rel_init = abs((theta_init - theta_true)) ./ (abs(theta_true));
theta_rel_est  = abs((theta_est - theta_true)) ./ (abs(theta_true));

% Output stimato pre-ottimizzazione dei parametri
QA_init = predicted_model_QA_redparms(theta_init, output_data_PaO, output_data_time);

% Output stimato post-ottimizzazione dei parametri
QA_est = predicted_model_QA_redparms(theta_est, output_data_PaO, output_data_time);

% Compara le misure reali e stimate
figure(5);
plot(output_data_time, output_data_QA, "LineStyle", "--", "LineWidth", 2);
hold on;
plot(output_data_time, QA_init);
plot(output_data_time, QA_est);
legend(["QA vero", "QA iniziale", "QA stimato"]);
title("Stima dei parametri ridotti con fminsearch su QA");

% Stampa dei risultati del fitting
fprintf("### fminsearch su QA parametri ridotti ###\n");
fprintf("Report sul fitting dei parametri\n");
fprintf("Parametri\n   %10.10s %10.10s %10.10s %21.21s\n", ...
    "veri", "iniziali", "stimati", "errori relativi");
for i = 1 : size(theta_true, 1)
    fprintf("%2s %10.4g %10.4g %10.4g %10.4g %10.4g\n", ...
        theta_names(i), theta_true(i), theta_init(i), theta_est(i), ...
        theta_rel_init(i), theta_rel_est(i)...
        );
end
fprintf("No. iterazioni\n   %10d\n" + ...
    "Valore funzione obbiettivo\n   %10g\n", ...
    output.iterations, obj_fun_val ...
);