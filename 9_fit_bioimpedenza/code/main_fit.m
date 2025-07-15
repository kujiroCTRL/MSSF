clc;
clear;
close all;

lw = 3;
fnt_sz = 20;

addpath('data/');

model = 3;
switch model
    case 1
        load('Fricke_large');

        R1 = 10e3; 
        R2 = 10e3; 
        C = 100e-9; 
        V = 0.5;

        alpha = 0;

        study_freq_idx = freq<3e5;

    case 2
        load('Fricke_small');

        R1 = 100; 
        R2 = 100; 
        C = 100e-9; 
        V = 0.01;
    
        alpha = 0;

        study_freq_idx = freq<2e5;

    case 3
        load('Banana');

        % Dati ottenuti dal plot (per una descrizione più approfondita, consultare la relazione per questo progetto)
            Rinf = -0.352931e3;
            R0 = 182.735e3;

            % tau = 1/\omega^\ast; 
            tau = 1/(2*pi)*1/1747.53;
            r = R0 - Rinf;
            m = 50.0968e3;
            alpha = 1-2/pi*acos((-4*m^2+r^2)/(4*m^2+r^2));
        
        % % Formule per il modello elettrico equivalente
        %     Rinf = R2*R1/(R2+R1);
        %     R0 = R2;
        %     tau = (R2+R1)*C;

        % Relazioni inverse 
            R1 = R0 * Rinf / (R0 - Rinf);
            R2 = R0;
            C = tau / (R2 + R1);
        
        V = 1; % dato non fornito. assumiamo = 1

        study_freq_idx = freq>0;
end

V_meas = V_meas(~isnan(V_meas));
freq = freq(~isnan(V_meas));

Z_HF2 = 50 + 50;

G = 1;
R = 1e3;

V_app = V;

Rinf = R2*R1/(R2+R1);
R0 = R2;
tau = (R2+R1)*C;

fit_alpha = 0;
if fit_alpha
    veri_params = [Rinf, R0, tau, alpha];
else
    veri_params = [Rinf, R0, tau];
end

I = -V_meas/(G*R);
Z = -G*R*V_app./V_meas;

study_freq = freq(study_freq_idx);
study_Z = Z(study_freq_idx);

Re_study_Z = real(study_Z);
Im_study_Z = imag(study_Z);

y = [Re_study_Z, Im_study_Z];

init_params = veri_params + rand(size(veri_params)) .* veri_params * 1e-1;

opts = optimset('TolFun', 1e-10, 'TolX', 1e-13, 'MaxIter', 1e5, 'MaxFunEvals', 1e5);

[fitted_params, obj_fun_val, exitflag, output] = fminsearch(@obj_fun, init_params, opts, y, study_freq, Z_HF2);

fitted_Rinf = fitted_params(1);
fitted_R0 = fitted_params(2);
fitted_tau = fitted_params(3);

if fit_alpha
    fitted_alpha = fitted_params(4);
else
    fitted_alpha = 0;
end

fitted_Z = bioparams2Z(fitted_Rinf, fitted_R0, fitted_tau, fitted_alpha, study_freq);
theoric_Z = bioparams2Z(Rinf, R0, tau, alpha, freq);

figure();
hold on; box on; grid on;
set(gca, 'FontSize', fnt_sz);

plot(study_freq, real(study_Z)*1e-3, 'm', 'LineWidth', lw);
plot(study_freq, -imag(study_Z)*1e-3, 'y', 'LineWidth', lw);
plot(freq, real(Z)*1e-3, 'm:', 'LineWidth', lw);
plot(freq, -imag(Z)*1e-3, 'y:', 'LineWidth', lw);
plot(study_freq, real(fitted_Z)*1e-3, 'g--', 'LineWidth', lw);
plot(study_freq, -imag(fitted_Z)*1e-3, 'c--', 'LineWidth', lw);
plot(freq, real(theoric_Z)*1e-3, 'g:', 'LineWidth', lw);
plot(freq, -imag(theoric_Z)*1e-3, 'c:', 'LineWidth', lw);

set(gca, 'XScale', 'log');
xlabel('Frequenza \omega (Hz)');
ylabel('Impedenza (kOhm)');
legend('Re veri (usati per il fit)', '-Im veri (usati per il fit)', ...
       'Re veri', '-Im veri', ...
       'Re fitted', '-Im fitted', ...
       'Re teorici', '-Im teorici');
title('Valori delle impedenze');

figure();
hold on; box on; grid on;
set(gca, 'FontSize', fnt_sz);

plot(study_freq, real(study_Z - fitted_Z)*1e-3, 'k', 'LineWidth', lw);
plot(study_freq, -imag(study_Z - fitted_Z)*1e-3, 'k:', 'LineWidth', lw);

xlabel('Frequency (Hz)');
ylabel('Impedance (kOhm)');
title('Errore nel fitting');
legend('Re veri - fitted', '-Im veri - fitted');
set(gca, 'XScale', 'log');

figure();
hold on; box on; grid on;
set(gca, 'FontSize', fnt_sz);

plot(real(study_Z)*1e-3, -imag(study_Z)*1e-3, 'm', 'LineWidth', lw);
plot(real(Z)*1e-3, -imag(Z)*1e-3, 'm:', 'LineWidth', lw);
plot(real(fitted_Z)*1e-3, -imag(fitted_Z)*1e-3, 'g--', 'LineWidth', lw);

xlabel('Re(Z) (kOhm)');
ylabel('-Im(Z) (kOhm)');
title('Diagramma di Cole-Cole');
legend('veri (usati per il fit)', 'veri', 'fitted');
axis equal;

figure();
hold on; box on; grid on;
set(gca, 'FontSize', fnt_sz);

plot(study_freq(2:end), diff(log(abs(real(study_Z - Rinf) ./ -imag(study_Z)))), 'm', 'LineWidth', lw);
plot(freq(2:end), diff(log(abs(real(Z - Rinf) ./ -imag(Z)))), 'm:', 'LineWidth', lw);
plot(study_freq(2:end), diff(log(abs(real(fitted_Z - fitted_Rinf) ./ -imag(fitted_Z)))), 'g--', 'LineWidth', lw);

plot(freq, (alpha) * ones(size(freq)), 'Color', [.3,.4,.2], 'LineWidth', lw, 'LineStyle', ':');
plot(study_freq, (fitted_alpha) * ones(size(study_freq)), 'Color', 2*[.3,.4,.2], 'LineWidth', lw, 'LineStyle', '--');

xlabel('Frequenza \omega (Hz)');
ylabel('Pendenza di log_e(abs(Re(Z)/-Im(Z))');
set(gca, 'XScale', 'log');
legend('veri (usati per il fit)', 'veri', 'fitted', '1 - \alpha', '1 - \alpha fitted');
title('Diagramma di Cole-Cole');

fprintf('Modello no. %d\n', model);
fprintf('\n%-15s %-15s %-15s\n', 'Parametro', 'Valore predetto', 'Valore fitted');
fprintf('%-15s %-15.6e %-15.6e\n', 'Rinf', Rinf, fitted_Rinf);
fprintf('%-15s %-15.6e %-15.6e\n', 'R0', R0, fitted_R0);
fprintf('%-15s %-15.6e %-15.6e\n', 'tau', tau, fitted_tau);
fprintf('%-15s %-15.6f %-15.6f\n', 'alpha', alpha, fitted_alpha);

fitted_a = fitted_tau / 10^(floor(log10(fitted_tau)));
fitted_b = - floor(log10(fitted_tau));

fprintf('\n%-15s %-15.6s %-15.6f\n', 'a', ' ', fitted_a);
fprintf('%-15s %-15.6s %-15.6f\n', 'b', ' ', fitted_b);