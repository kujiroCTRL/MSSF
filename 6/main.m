% Regolazione glicemica
% Il sangue è costituito da una componente corpuscolare (globuli,
% piastrine, etc) e una componente liquida (soluzione di ioni e proteine)

% Il valore di riferimento 80-90 mg/dL a condizioni di digiuno

% Omeostasi: la quantità di glucosio è ad un valore fissato e costante
% Stimoli attivi quando il glucosio è in rialzo
% Nel pancreas le cellule beta rilasciano insulina che
% 1. dirige le cellule a consumare il glucosio
% 2. invio del glucosio nel fegato (dove viene immagazzinato come glicogeno
% )
% Stimoli attivi quando il glucosio è in ribasso
% Pancreas (cellule alpha) rilasciano glucagone che, giunto al pancreas
% porta al rilascio del glucosio immagazzinato

% Diabeti:
% Diabete di tipo I: le cellule beta non producono insulina
% Diabete di tipo II:L'insulina viene prodotta ma non è sufficiente ad
% attivare il consumo o l'immagazzinamento del glucosio

% Modello minimo del glucosio:
% E' un modello con il numero minimo di parametri che permetta di descrivere
% la glucose effectiveness, cioè l'influenza del solo glucosio nel portare
% il sistema ad omeostasi e la insuline effectiveness, cioè l'influenza
% della sola insulina nel portare il sitema ad omeostasi

% Questi parametri si stimano tramite il IVGTT o Intra-Venous Glucose
% Tolerance Test che consiste nell'osservare la reazione del soggetto sotto
% somministrazione di grandi quantitò di glucosio

% G è la concentrazione plasmatica di glucosio
% I è la concentrazione plasmatica di insulina
% X è la concentrazione efficace di insulina
% X è descritta da Bergman-Cobelli come la concentrazione presente in un
% compartimento non misurabile
%
% $$
% \dot G = S_g(G_b-G)-XG\\
% \dot X = k(S_i(I-I_b)-X)\\
% G(0) = G_0\\
% X(0) = X_0
% $$
%%

data = load("experimental_data.mat");
t_data = data.tgi(:, 1)';
G_data = data.tgi(:, 2)';
I_data = data.tgi(:, 3)';

figure();
subplot(1, 2, 1);
scatter(t_data, G_data, "Marker", "diamond", "MarkerEdgeColor", "r");
xlabel("t [min]");
ylabel("Glucosio [mg / dL]");
grid on;

subplot(1, 2, 2);
scatter(t_data, I_data, "Marker", "diamond", "MarkerEdgeColor", "b");
xlabel("t [min]");
ylabel("Insulina [\muU / dL]");
grid on;
%% Interpolazione (test)
figure();
dt = .01;

I_interp = interp1(t_data, I_data, min(t_data) : dt : max(t_data));

scatter(min(t_data) : dt : max(t_data), I_interp, "Marker", "."); hold on;
scatter(t_data, I_data, "Marker", "diamond"); hold off;

legend(["Interpolated I (dt = " + num2str(dt) + ")", "Real I"]);
xlabel("t [min]");
ylabel("Insulina [uU/dL]");

%% Predizione tramite ode45
Gb = 83;
Ib = 11;
Sg = 2.6e-2;
k = .025;
Si = 5e-4;

parms = [Sg, Gb, k, Si, Ib];

G0 = 279;
X0 = 0;
GX0 = [G0, X0];

% NOTA: time_array non può essere arbitrario perché c'è la dipendenza dai
% valori delle misure di I, che è campionato (interpolato) su (tra) gli
% istanti di tempo delle misure 
% Quindi possiamo cambiare dt ma non gli istanti di tempo iniziale e finale
time_array = (min(t_data) : dt : max(t_data))';
[ode_time_array, measures_array] = ode45(@(t, x) glucose_minimal_model(t, x, t_data, I_data, parms), time_array, GX0);

figure();
subplot(1, 2, 1);
scatter(ode_time_array, measures_array(:, 1), "Marker", ".", "MarkerEdgeColor", "g"); hold on;
scatter(t_data, G_data, "Marker", "diamond", "MarkerEdgeColor", "r");
legend(["Glucosio simulato", "Glucosio misurato"]);
xlabel("t [min]");
ylabel("Glucosio [mg / dL]");
grid on;
hold off;

subplot(1, 2, 2);
scatter(ode_time_array, measures_array(:, 2), "Marker", ".", "MarkerEdgeColor", "b");
legend("Insulina efficace simulata");
xlabel("t [min]");
ylabel("Insulina [\muU / dL]");
grid on;

if(size(time_array) ~= size(ode_time_array) | any(time_array ~= ode_time_array))
    warning("Il vettore dei tempi dato a ode45 non coincide con quello ritornato da lui");
end

%%