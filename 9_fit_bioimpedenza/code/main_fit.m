clc
clear
close all

lw = 2;
fnt_sz =12;

addpath('data/')

model = 3;
switch model
    case 1
        load('Fricke_large')

        R1 = 10e3; % (Ohm)
        R2 = 10e3; % (Ohm)
        C = 100e-9; % (F) (in serie with R1)
        V = 0.5; % V

        alpha = 0;

        study_freq_idx = freq<3e5;

    case 2
        load('Fricke_small')

        R1 = 100; % (Ohm)
        R2 = 100; % (Ohm)
        C = 100e-9; % (F) (in serie with R1)
        V = 0.01; % V
    
        alpha = 0;

        % study_freq_idx = freq>0;
        study_freq_idx = freq<2e5;

    case 3
        load('Banana')

        % Dati ottenuti dal plot
            Rinf = -0.352931e3;
            R0 = 182.735e3;

            % tau = 1/\omega^\ast; 
            tau = 1/(2*pi)*1/1747.53;
            r = R0 - Rinf;
            m = 50.0968e3;
            alpha = 1-2/pi*acos((-4*m^2+r^2)/(4*m^2+r^2));
        
        % Formule per il modello elettrico
            % Rinf = R2*R1/(R2+R1);
            % R0 = R2;
            % tau = (R2+R1)*C;

        % Invertite abbiamo
            R1 = R0 * Rinf / (R0 - Rinf);
            R2 = R0;
            C = tau / (R2 + R1);
        
        V = 1; % dato non fornito. assumiamo per ora = 1

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
    true_params = [Rinf, R0, tau, alpha];
else
    true_params = [Rinf, R0, tau];
end

I = -V_meas/(G*R);
Z = -G*R*V_app./V_meas;

study_freq = freq(study_freq_idx);
study_Z = Z(study_freq_idx);

Re_study_Z = real(study_Z);
Im_study_Z = imag(study_Z);

y = [Re_study_Z, Im_study_Z];

init_params = true_params + rand(size(true_params)) .* true_params * 1e-1;

opts = optimset('TolFun', 1e-10, 'TolX', 1e-13, 'MaxIter', 1e5, 'MaxFunEvals', 1e5, ...
    'PlotFcns', 'optimplotfval' ...
    );
[fitted_params, obj_fun_val, exitflag, output]=fminsearch(@obj_fun, init_params, opts, y, study_freq, Z_HF2);

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

figure()
    hold on, box on, grid on
   
    plot(study_freq, real(study_Z)*1e-3, 'm', 'LineWidth', lw);
    plot(study_freq, -imag(study_Z)*1e-3, 'y', 'LineWidth', lw);
    
    plot(freq, real(Z)*1e-3, 'm', 'LineWidth', lw, 'LineStyle', ':');
    plot(freq, -imag(Z)*1e-3, 'y', 'LineWidth', lw, 'LineStyle', ':');
    
    plot(study_freq, real(fitted_Z)*1e-3, 'g', 'LineWidth', lw, 'LineStyle', '--');
    plot(study_freq, -imag(fitted_Z)*1e-3, 'c', 'LineWidth', lw, 'LineStyle', '--');
    
    plot(freq, real(theoric_Z)*1e-3, 'g', 'LineWidth', lw, 'LineStyle', ':');
    plot(freq, -imag(theoric_Z)*1e-3, 'c', 'LineWidth', lw, 'LineStyle', ':');
 
    set(gca, 'XScale', 'log')
    xlabel('Frequency (Hz)')
    ylabel('Impedance (kOhm)')
    legend('Re true fitted', '-Im true fitted', 'Re true', '-Im true', 'Re predict', '-Im predict', 'Re theoric', '-Im theoric')

figure()
    hold on, box on, grid on
    
    plot(study_freq, real(study_Z-fitted_Z)*1e-3, 'w', 'LineWidth', lw);
    plot(study_freq, -(imag(study_Z-fitted_Z)*1e-3), 'w', 'LineWidth', lw, 'LineStyle', ':');
    
    xlabel('Frequency (Hz)')
    ylabel('Impedance (kOhm)')
    legend('Re true - predict', '-Im true - predict');

    set(gca, 'XScale', 'log')

figure()
    hold on, box on, grid on
    
    plot(real(study_Z)*1e-3, -imag(study_Z)*1e-3, 'm', 'LineWidth', lw)
    plot(real(Z)*1e-3, -imag(Z)*1e-3, 'm', 'LineWidth', lw, 'LineStyle', ':')
    plot(real(fitted_Z)*1e-3, -imag(fitted_Z)*1e-3, 'g', 'LineWidth', lw, 'LineStyle', '--')
    
    xlabel('Re(Z) (kOhm)')
    ylabel('-Im(Z) (kOhm)')
    title('Cole-Cole Diagram')
    legend('true fitted', 'true', 'predict')
    axis equal;