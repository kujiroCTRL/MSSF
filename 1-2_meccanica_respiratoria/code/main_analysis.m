%{

Esercitazione #1 per MSSF a.a. 24/25
di Lorenzo Casavecchia, m.0350001

Implementare in Simulink il modello della meccanica respiratoria presentato
a lezione (modello Rc,Rp,Cs,Cl,Cw) e riportato in figura. Considerare come
input di pressione PaO sia il caso sinusoidale sia il caso di un’onda
quadra (scegliendo opportunamente i loro parametri). Facoltativamente:
arricchire il modello o implementare altri input pressori prendendo
ispirazione, per esempio, dal corso di STMT. 

Simulare alcune condizioni patologiche (e.g., asma, enfisema, fibrosi,
bradipnea, tachipnea) ed analizzare le differenze con il caso fisiologico.
Considerare in particolare l’andamento del flusso QA che raggiunge gli
alveoli rispetto al flusso totale Q, ed i rispettivi volumi.
Predisporre un breve report per il confronto dei risultati.

%}

clc;
clear;
close all;

SINE = 0;
SQUARE = 1;

input_type = SINE;

% Questi parametri saranno usati in model.slx
% Parametri del modello respiratorio
Rp = .5;
Rc = 1;
Cs = .005;
CL = .2;
Cw = .2;

save("parms.mat", "Rp", "Rc", "Cs", "CL", "Cw", "-mat");

% Qui avrei voluto scrivere una NOTA sul perché debba inizializzare
% PaO_parms ad un vettore 1x7 nonostante nell'onda sinusoidale servano solo
% 4 parametri, ma sarebbe stata troppo lunga e noiosa (sono disposto a
% darla a voce; è una cosa che MATLAB mi impone perché a differenza del C,
% sa che i programmatori possono scrivere codice buggato)
PaO_parms = zeros(1, 7);

% Parametri della forma della pressione PaO (grazie ChatGPT)
if(input_type == SINE)
    % Valori adottati da Khoo
    PaO_A = 2.5;
    PaO_w = .25;
    PaO_f = 0;
    PaO_PEEP = 0;

    PaO_parms(1 : 5) = [ SINE, PaO_A , PaO_w , PaO_f , PaO_PEEP ];
elseif(input_type == SQUARE)
    % NOTA: i parametri per l'onda quadra sono quelli segnati sull'ultima
    % slide di lung_mechanics.pdf, quindi ampiezza base-picco, tau, Ti, Te,
    % PEEP e fase iniziale
    PaO_A = 1;
    PaO_tau = .5;
    PaO_tau = 0.1;
    PaO_Ti = 1.7;
    PaO_Te = 3.3;
    
    PaO_PEEP = 0;
    PaO_f = 0;

    PaO_parms(1 : 7) = [ SQUARE, PaO_A, PaO_tau, PaO_Ti, PaO_Te, PaO_PEEP, PaO_f ];
end

% Parametri del tempo di esecuzione e di sampling di Simulink
% NOTA: questi parametri non sono direttamente visibili dal modello
% Simulink se non andando su Model Settings > Solver (mi sarebbe piaciuto
% avere tutto quanto a portata d'occhio ma con Simulink non credo sia
% possibile, se non eseguendo dei set_parm su ogni parametro interno di
% Simulink...)
T  = 50.0;
dT = .01;

% Frequenza di taglio del blocco Derivative
D_freq = + eps;

% Include & esegue il modello e ne estrae i risultati esportati
% NOTA: la console potrebbe riportare la presenza di loop algebrici, nello
% specifico sul ramo Q > QA > Paw > Q che, scrivendone le equazioni si può
% notare che compare uno stesso termine, anche se con coefficienti diversi
% NOTA: la console dovrebbe anche riportare un warning sulla derivata
% anche se, nelle impostazioni del blocco Derivative ho impostato una
% frequenza di taglio così che la sua funzione di trasferimento sia
% quantomeno propria

noise_A = 1e-4;

sim("./model.slx");
output_data = load("output_data.mat").ans;

% ...di cui estraiamo le componenti nell'ordine imposto dal multiplexer
% NOTA: estrarre i dati con indicizzazione, come riportato di seguito non è
% una buona, specialmente considerato come quirky le convenzioni di
% Simulink possano essere (è probabile che sia stato disattento ma, in
% molteplici progetti svolti in passato e con conferma da parte di
% colleghi, Simulink tende a decidere autonomamente l'orientamento degli
% array i.e. per righe o per colonne)
output_data_time = output_data.Time;
output_data_PaO = output_data.Data(:, 1);
output_data_Q = output_data.Data(:, 2);
output_data_V = output_data.Data(:, 3);
output_data_QA = output_data.Data(:, 4);
output_data_VA = output_data.Data(:, 5);

figure(1);
hold on;
plot(output_data_time, output_data_PaO, 'LineStyle', '--');
plot(output_data_time, output_data_QA);
plot(output_data_time, output_data_VA);
plot(output_data_time, output_data_Q);
plot(output_data_time, output_data_V);
legend([ "PaO" , "QA", "VA" , "Q" , "V" ]);
title("Segnali reali");

% Analisi delle funzioni di trasferimento rispetto a Pao
% Costruzione esplicita delle tfs di interesse
s = tf('s');

CLw = 1 / CL + 1 / Cw;

a2 = Rc * Rp * Cs;
a1 = Rc + Rp + Rc * Cs * CLw;
a0 = CLw;

W = [a2 a1 a0] * [s^2; s; 1];
W_PaO_QA  = minreal(s / W);
W_PaO_VA  = minreal(1 / s * W_PaO_QA);

W_PaO_Paw = minreal((Rp + 1 / s * CLw) * W_PaO_QA);
W_PaO_Q   = minreal(1 / Rc * (1 - W_PaO_Paw));
W_PaO_V   = minreal(1 / s * W_PaO_Q);

figure(2);
x1 = subplot(2, 1, 1);
lsim(W_PaO_QA, output_data_PaO, output_data_time, "zoh"); hold on;
plot(output_data_time, output_data_QA, "Color", "r");
legend(["QA", "QA teorico"]);
title("Segnali reali vs lsim sulle tf teoriche");

x2 = subplot(2, 1, 2);
lsim(W_PaO_Q, output_data_PaO, output_data_time, "zoh"); hold on;
plot(output_data_time, output_data_Q, "Color", "r");
legend(["Q", "Q teorico"]);

linkaxes([x1,x2], "x");

figure(3);
hold on;
bode(W_PaO_QA);
bode(W_PaO_VA);
bode(W_PaO_Q);
bode(W_PaO_V);
legend(["QA", "VA", "Q", "V"]);
title("Diagrammi di Bode delle tf teoriche"); 

% Permette di ottenere guadagno e fase su frequenze all'infuori del range
% ammissibile dal sampling del segnale (vedi dT di sopra)
% Per fare ciò usiamo resample per estendere il dominio dei segnali con la
% nuova sampling frequency che vogliamo noi, e poi facciamo fft sulla
% resampled time-series

fs = 1 / mean(diff(output_data_time));

[f_QA, gain_QA, phase_QA] = time2frequency(output_data_QA, fs);
[f_VA, gain_VA, phase_VA] = time2frequency(output_data_VA, fs);
[f_Q, gain_Q, phase_Q] = time2frequency(output_data_Q, fs);
[f_V, gain_V, phase_V] = time2frequency(output_data_V, fs);
[f_PaO, gain_PaO, phase_PaO] = time2frequency(output_data_PaO, fs);

figure(4);
x3 = subplot(2, 1, 1);
semilogx(f_QA, 20 * log10(gain_QA ./ gain_PaO)); hold on;
semilogx(f_VA, 20 * log10(gain_VA ./ gain_PaO));
semilogx(f_Q, 20 * log10(gain_Q ./ gain_PaO));
semilogx(f_V, 20 * log10(gain_V ./ gain_PaO));
yyaxis right; semilogx(f_PaO, 20 * log10(gain_PaO), "LineStyle", "--");
legend(["QA", "VA", "Q", "V", "PaO"]);
title("Diagrammi di Bode costruiti dalle fft dei segnali reali");
hold off;

x4 = subplot(2, 1, 2);
semilogx(f_QA, unwrap(phase_QA - phase_PaO) * 180 / pi); hold on;
semilogx(f_VA, unwrap(phase_VA - phase_PaO) * 180 / pi);
semilogx(f_Q, unwrap(phase_Q - phase_PaO) * 180 / pi);
semilogx(f_V, unwrap(phase_V - phase_PaO) * 180 / pi);
yyaxis right; semilogx(f_PaO, unwrap(phase_PaO) * 180 / pi, "LineStyle", "--");
hold off; 

linkaxes([x3,x4], "x");