%{

Esercitazione #8 per MSSF a.a. 24/25
di Lorenzo Casavecchia, m.0350001

Assumendo α=1, β=0.05, γ=1, δ=0.01, x0=20:40:100, y0=10:10:30, tf=300:
a) Calcolare il punto di equilibrio del sistema (x*,y*)
b) Calcolare e visualizzare l'andamento delle popolazioni di prede e predatori nel tempo per ogni
coppia x0, y0 (si consiglia l'utilizzo di ode45).
c) Generare orbite nello spazio delle fasi (x, y) per ogni coppia x0, y0. Se le orbite non dovessero
essere costanti, usare le opzioni di ODE "RelativeTolerance" e "AbsoluteTolerance" per ridurre
gli errori numerici fino ad un valore accettabile.
d) Calcolare il potenziale ecologico φ nel tempo per ogni orbita.
e) Calcolare la durata temporale di un ciclo per ogni orbita (usando findpeaks per trovare massimi
adiacenti).
f) Calcolare valori medi di <x>, <y> per un ciclo di ogni orbita, e confrontarli con x*,y* (si
consiglia di far funzionare ODE45 a timestep costante).
g) Facoltativamente: Per una griglia di valori iniziali x0, y0 più fitta ed estesa, generare la superficie
del potenziale ecologico φ vs x,y e disegnare le orbite sul piano delle fasi x,y come curve di
livello del potenziale.

%}

clc; clear; close all;

fn_sz = 16;
lw = 3;
ms = 7;

reltol = 1e-3;
abstol = reltol;
odefun = @ode89;

% Dinamica
    % dx = alpha * x - beta * x * y;
    % dy = - gamma * y + delta * x * y;

alpha = 1;
beta = .05;
gamma = 1;
delta = .01;
parms = [alpha,beta,gamma,delta];

tspan = [0 1000];

x0_arr = [20 : 40 : 100, 100.];
y0_arr = [10 : 10 : 30, 20.01];

figure(1); hold on; title('Andamenti nel tempo'); xlabel('t'); ylabel('Popolazione'); set(gca, 'FontSize', 15);
figure(2); hold on; title('Diagramma delle fasi'); xlabel('Numero di prede x'); ylabel('Numero di predatori y'); set(gca, 'FontSize', 15);
figure(3); hold on; title('Potenziale ecologico nel tempo'); xlabel('Tempo'); ylabel('Potenziale ecologico V(x,y)'); set(gca, 'FontSize', 15); 
figure(4); hold on; title('Distanza tra i picchi nella popolazione'); xlabel('Tempo'); ylabel('Picco di popolazione'); set(gca, 'FontSize', 15);
figure(5); hold on; title('Superifice del potenziale ecologico'); xlabel('Numero di prede x'); ylabel('Numero di predatori y'); zlabel('Potenziale ecologico V(x,y)'); set(gca, 'FontSize', 15);

% Punto d'equilibrio
x_ast = gamma / delta;
y_ast = alpha / beta;

opts = odeset('RelTol', reltol, 'AbsTol', abstol);
for i = 1 : size(x0_arr, 2)
    X0 = [x0_arr(i); y0_arr(i)];
    
    [t, Y] = odefun(@(t,y) lotka_volterra_dynamics(t,y,parms), tspan, X0, opts);
    x = Y(:,1); y = Y(:,2);

    figure(1)
    % DisplayName mi permette di impostare il testo per la legend senza
    % dover fare legend(...) con tutti i label, dopo aver fatto i plot
        p = plot(t, x, 'DisplayName', sprintf('x(t), x0=%4.2f, y0=%4.2f', X0(1), X0(2)));
        plot(t, y, 'DisplayName', sprintf('y(t), x0=%4.2f, y0=%4.2f', X0(1), X0(2)), 'LineStyle', '--', 'Color', p.Color);

    figure(2)
        p = plot(x, y, 'DisplayName', sprintf('Traiettoria, x0=%4.2f, y0=%4.2f', X0(1), X0(2)));
        scatter(X0(1), X0(2), 'DisplayName', sprintf('x0=%4.2f, y0=%4.2f', X0(1), X0(2)), 'Marker', '*', 'Color', p.Color);
        plot(1 ./ t .* cumtrapz(t, x), 1 ./ t .* cumtrapz(t, y), 'DisplayName', sprintf('Valore medio, x0=%4.2f, y0=%4.2f', X0(1), X0(2)), 'LineStyle', ':', 'Color', p.Color);

    phi = delta * x - gamma * log(x) + beta * y - alpha * log(y);
    figure(3)
        plot(t, phi, 'DisplayName', sprintf('V(t), x0=%4.2f, y0=%4.2f', X0(1), X0(2)));
    
    [pks, locs] = findpeaks(y, t);
    figure(4);
        p = plot(locs(2:end), diff(locs), 'DisplayName', sprintf('Distanza picco-picco, x0=%4.2f, y0=%4.2f', X0(1), X0(2)));
        plot(locs(2:end), mean(diff(locs)) * ones(size(locs(2:end))), 'DisplayName', sprintf('Distanza picco-picco media, x0=%4.2f, y0=%4.2f', X0(1), X0(2)), 'LineStyle', '--', 'Color', p.Color);
end

figure(1); legend;
    the_magic_instruction(fn_sz, lw, ms);
figure(2); scatter(x_ast, y_ast, 'Marker', '+', 'MarkerEdgeColor', 'k', 'DisplayName', "Punto d'equilibrio X^\ast");
    the_magic_instruction(fn_sz, lw, ms);  
figure(3);
    plot(t, (delta * x_ast - gamma * log(x_ast) + beta * y_ast - alpha * log(y_ast)) * ones(size(t)), 'DisplayName', 'V(t), x0=x0^\ast, y0=y0^\ast', 'Color', 'k');
    the_magic_instruction(fn_sz, lw, ms);

figure(4); plot(t, (2 * pi / (sqrt(alpha * gamma))) * ones(size(t)), 'Color', 'k', 'DisplayName', '2\pi / (\alpha\gamma)^{1/2}');
    the_magic_instruction(fn_sz, lw, ms);
    % Codice ottenuto abilitando "Show Code" dalla finestra del grafico (stessa cosa alla riga 112)
    legend("Position", [0.5080 0.4960 0.2479, 0.2342]);

[x_grid, y_grid] = meshgrid(15:1:105, 5:1:35);
phi_surf = delta * x_grid - gamma * log(x_grid) + beta * y_grid - alpha * log(y_grid);

figure(5)
view(3);
    surf(x_grid, y_grid, phi_surf, 'EdgeColor','none', 'DisplayName', 'V(X)');
    for i = 1 : size(x0_arr, 2)
        x0 = x0_arr(i); y0 = y0_arr(i);
        scatter3(x0, y0, delta * x0 - gamma * log(x0) + beta * y0 - alpha * log(y0), 'Marker', '*', 'LineWidth', 10, 'MarkerEdgeColor', 'magenta', 'DisplayName', sprintf('x0=%4.2f, y0=%4.2f', X0(1), X0(2)));
    end
    scatter3(x_ast, y_ast, delta * x_ast - gamma * log(x_ast) + beta * y_ast - alpha * log(y_ast), 'Marker', '*', 'LineWidth', 10, 'MarkerEdgeColor', 'k', 'DisplayName', 'X^\ast');

    the_magic_instruction(fn_sz, lw, ms);
    view([56.000 7.000])
    legend("Position", [0.6980 0.6002 0.1208, 0.1597]);

%% Visuali utili per ricreare le versioni magnificate dei grafici nella presentazione
figure(3)
    xlim([0.0000e+00, 1.0000e+02])
    ylim([-5.6010e+00, -5.6005e+00])

figure(2)
    xlim([94.26 105.05])
    ylim([19.040 20.748])