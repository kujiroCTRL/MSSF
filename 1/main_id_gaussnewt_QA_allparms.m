%{

Esercitazione #2 per MSSF a.a. 24/25
di Lorenzo Casavecchia, m.0350001

Modificare i codici Matlab relativi all'identificazione parametrica del
modello RLC della meccanica respiratoria tramite fminsearch.m, considerando
i due parametri LC ed RC anziché i tre parametri R, L e C. 

Completare il codice per l'identificazione parametrica con il metodo di
Gauss-Newton (i.e., scrivere le routines rlc_fun_two_parameters.m e
jacobian_fun.m). Comprendere i dettagli del codice.

Identificazione parametrica dei parametri Rp, Rp, Cs, CL, Cw usando
metodo di Gauss-Newton, sulla base della misura QA

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
theta_true = [Rc; Rp; Cs; CL; Cw];

% Stima iniziale
theta_init = theta_true .* [1 / 10, 1, 1, 1, 1]';

% Parametri di ottimizzazione
alpha       = 1e-1; % Parametro di rilassamento
alpha_0     = 1e-1;
delta_alpha = 1e-1;
lambda   = 0; % Parametro di regolarizzazione
tol      = 1e-4; % Tolleranza
max_iter = 100; % Numero massimo di iterazioni

% Inizializzazione
theta_est = theta_init; 
done = false;

% Abilita/disabilita plot di convergenza dei parametri
plot_flag = true;

n_theta = size(theta_init, 1);

theta_colors =  ["yellow", "magenta", "cyan", "red", "blue"];
theta_names = ["Rc", "Rp", "Cs", "CL", "Cw"];

if plot_flag
    % Plot dei parametri veri e correnti
    figure();
    
    for i = 1 : n_theta
        hold on;
        line( ...
            [0, max_iter], [theta_true(i), theta_true(i)], ...
            'Color', theta_colors(i), 'LineStyle', ':' ...
            );
    end
    xlabel('Iterazione');
end

iter = 1;
e_prev = Inf;
% Iterazioni del metodo Gauss-Newton
while (~done) && (iter <= max_iter)
    iter = iter + 1;
    
    % Output stimato con i parametri correnti
    QA_pred = predicted_model_QA_allparms(theta_est, output_data_PaO, output_data_time);
    
    % Vettore degli errori
    e = (QA_pred - output_data_QA);
    
    % Matrice Jacobiana - sensibilità rispetto ai parametri (aggiornata ad ogni iterazione)
    J = jacobian_QA_allparms(theta_est, output_data_PaO, output_data_time);
    
    % Gradiente della funzione obiettivo rispetto ai parametri
    dE_dtheta = J' * e;
    
    % Hessiana della funzione obiettivo con derivate seconde trascurate (approssimazione di Gauss-Newton)
    % Hessiana regolarizzata
    d2E_dtheta2 = J' * J + lambda * eye(n_theta);

    h = - pinv(d2E_dtheta2) * dE_dtheta;
    
    % Controllo (criterio di arresto su h)
    done = (norm(h) < tol) | (alpha < tol);

    if(norm(e) > e_prev)
        theta_est = theta_prev;
        alpha = alpha * delta_alpha;
        iter = iter - 1;
        continue;
    end

    e_prev = norm(e);
    theta_prev = theta_est;

    % Aggiornamento dei parametri (con rilassamento)
    theta_est = theta_est + alpha * h;
    alpha = alpha_0;
    
    theta_est = abs(theta_est);
    
    if plot_flag && iter <= max_iter
        % Aggiornamento del plot di convergenza dei parametri
        for i = 1 : n_theta
            yyaxis left; scatter(iter - 1, theta_est(i), theta_colors(i)); hold on;
        end
        yyaxis right; scatter(iter - 1, .5 * norm(e) ^ 2, "Marker", "+");
    end
end

for i = 1 : n_theta
    plot(0, 0, "Color", theta_colors(i));
end
legend(theta_names);

yyaxis left; ylabel("Parametri");
yyaxis right; ylabel("Errore di stima");

theta_rel_init = abs((theta_init - theta_true)) ./ (abs(theta_true));
theta_rel_est  = abs((theta_est - theta_true)) ./ (abs(theta_true));

% Output stimato pre-ottimizzazione dei parametri
Q_init  = predicted_model_Q_allparms(theta_init, output_data_PaO, output_data_time);
QA_init = predicted_model_QA_allparms(theta_init, output_data_PaO, output_data_time);

% Output stimato post-ottimizzazione dei parametri
Q_est  = predicted_model_Q_allparms(theta_est, output_data_PaO, output_data_time);
QA_est = predicted_model_QA_allparms(theta_est, output_data_PaO, output_data_time);

% Compara le misure reali e stimate
figure();
subplot(2, 1, 1);
plot(output_data_time, output_data_QA, "LineStyle", "-", "LineWidth", 2);
hold on;
plot(output_data_time, QA_init);
plot(output_data_time, QA_est);
legend(["QA vero", "QA iniziale", "QA stimato"]);
title("Stima dei parametri completi con gauss-newton su QA");

subplot(2, 1, 2);
plot(output_data_time, output_data_Q, "LineStyle", "-", "LineWidth", 2);
hold on;
plot(output_data_time, Q_init);
plot(output_data_time, Q_est);
legend(["Q vero", "Q iniziale", "Q stimato"]);

% Stampa dei risultati del fitting
fprintf("### GN su QA tutti i parametri ###\n");
fprintf("Report sul fitting dei parametri\n");
fprintf("Parametri\n   %10.10s %10.10s %10.10s %21.21s\n", ...
    "veri", "iniziali", "stimati", "errori relativi");
for i = 1 : n_theta
    fprintf("%2s %10.4g %10.4g %10.4g %10.4g %10.4g\n", ...
        theta_names(i), theta_true(i), theta_init(i), theta_est(i), ...
        theta_rel_init(i), theta_rel_est(i)...
        );
end
fprintf("No. iterazioni\n   %10d\n" + ...
    "Valore funzione obbiettivo\n   %10g\n", ...
    iter, 1 / 2 * norm(e) ^ 2 ...
);