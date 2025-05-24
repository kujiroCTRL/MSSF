%{

Esercitazione #3 per MSSF a.a. 24/25
di Lorenzo Casavecchia, m.0350001

Integrando quanto fatto in classe con quanto riportato nell’articolo
Errico_Caselli_SAB_2017, scrivere un codice Matlab che: 

Implementare il curve fitting dei dati di impedenza presenti nel file
mistery.mat, usando come template una Gaussiana bipolare e sfruttando se
possibile il parfor.

Implementare la procedura di compensazione per rimuovere il position
blurring dalla stima del diametro elettrico. Visualizzare l’istogramma del
diametro elettrico, lo scatter plot “shape parameter vs diametro
elettrico”, e lo scatter plot “velocità vs diametro elettrico” (in tutti i
casi, fare i grafici sia col diametro non corretto sia col diametro
corretto). 

Facoltativamente: Usando i comandi getline e inpolygon e lo scatter plot
“shape parameter vs diametro elettrico”, individuare i datapoints
corrispondenti a ciascuna delle tre popolazioni di beads. Riprodurre
nuovamente le figure richieste al punto b) usando stavolta colori diversi
per ciascuna popolazione (come in e Fig. 5(a) e (d) di
Errico_Caselli_SAB_2017). Fittare una Gaussiana sull’istogramma del
diametro elettrico corretto di ciascuna popolazione e riportare in una
tabella i corrispondenti valori di media, deviazione standard e
coefficiente di variazione (cf. Fig. 5(e)). 

%}

f_sample = 115.3e3;
T_sample = 1 / f_sample;

m = load("./data_to_fit.mat").mistery_data;

size = 0;

for i = 1 : length(m)
    size = size + length(m{i});
end
data = zeros(2,size);

data(2, 1 : length(m{1})) = m{1} * 1e3;
data(1, 1 : length(m{1})) = (0 : 1 : (length(m{1}) - 1)) * T_sample;
base = length(m{1});
for i = 2 : length(m)
    nmi  = length(m{i});
    data(2, (base + 1 : 1 : base + nmi)) = m{i} * 1e3;
    data(1, (base + 1 : 1 : base + nmi)) = (0 : 1 : (nmi - 1)) * T_sample;
    
    base = base + nmi;
end

scatter( ...
    data(1, :), ...
    data(2, :), ...
    'Marker', '.', ...
    'MarkerEdgeColor','k');

template = @(t, a, sigma, delta, tc) ...
    a * ( - exp(- (t - (tc + delta ./ 2)) .^ 2 ./ (2 * sigma ^ 2) ) ...
          + exp(- (t - (tc - delta ./ 2)) .^ 2 ./ (2 * sigma ^ 2) ) ...
         );

ft = fittype(@(a,b,c,d,x) template(x,a,b,c,d), 'coefficients', {'a','b','c','d'},'independent', {'x'},...
     'dependent', 'z' );

opts = fitoptions('Method','NonLinearLeastSquare');

opts.StartPoint = [1,.24,.5,.5];

mi = m{1};
[fitresults] = fit( ...
    ((0 : T_sample : (length(mi) - 1) * T_sample) * 1e3)' / max(((0 : T_sample : (length(mi) - 1) * T_sample) * 1e3)'), ...
    mi' / max(mi), ...
    ft, opts);

figure()
hold on;
plot(fitresults);
plot( ...
    ((0 : T_sample : (length(mi) - 1) * T_sample) * 1e3) / max(((0 : T_sample : (length(mi) - 1) * T_sample) * 1e3)), ...
    mi / max(mi) ...
);

N = 100;
a = zeros(1,N);

figure();
for i = 1:N
    mi = m{i};
    [fitresults] = fit( ...
    ((0 : T_sample : (length(mi) - 1) * T_sample) * 1e3)' / max(((0 : T_sample : (length(mi) - 1) * T_sample) * 1e3)'), ...
    mi' / max(mi), ...
    ft, opts);
    
    a(i) = fitresults.a * max(mi);
    
    disp(a(i));
end

hold on;
plot(1 : N, a .^ (1e0 /3))
plot(1 : N, ones(1,N) * mean(a .^ (1e0 /3)))