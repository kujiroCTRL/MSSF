%% Fit experimental data relevant to the Fricke circuit
% (i.e., series of R1 and C, in parallel with R2)

clc
clear
close all

%% Plot settings

% line width
lw = 2;
% font size
fnt_sz =12;

%% Load data
addpath('data/')

load('Fricke_large')

% load('Fricke_small')

% load('Banana')

%% Parameters

% true (nominal) circuit parameters - Fricke Large
R1 = 10e3; % (Ohm)
R2 = 10e3; % (Ohm)
C = 100e-9; % (F) (in serie with R1)
V = 0.5; % V

% true (nominal) circuit parameters - Fricke small
% R1 = 100; % (Ohm)
% R2 = 100; % (Ohm)
% C = 100e-9; % (F) (in serie with R1)
% V = 0.01; % V

Z_HF2 = 50 + 50; % (50 Ohm impedances associated to HF2TA and HF2LI)

% HF2TA gain and resistance
G = 1;
R = 1e3;

% applied voltage
V_app = V;

% compute model parameters Rinf, R0 and tau
Rinf = R2*R1/(R2+R1);
R0 = R2;
tau = (R2+R1)*C;
% assemble parameters (to be fitted)
true_params = [Rinf, R0, tau];

%% Read data

I = -V_meas/(G*R); % current flowing through the load

% amplitude-frequency plot
figure()
hold on, box on, grid on
plot(freq, abs(I)*1e3, 'LineWidth', 2)
xlabel('Frequency (Hz)')
ylabel('Current amplitude (mA)')
set(gca, 'XScale', 'log')

% phase-frequency plot
figure(2)
hold on, box on, grid on
plot(freq, rad2deg(angle(I)), 'LineWidth', 2)
xlabel('Frequency (Hz)')
ylabel('Current phase (deg)')
set(gca, 'XScale', 'log')


%% Reconstruct impedance of load

% cf. section "12.4.3. Impedance Measurement with
% HF2IS" of the HF2 Users Manual
Z = -G*R*V_app./V_meas; 

% Re(Z) and -Im(Z) frequency plots
figure()
hold on, box on, grid on
plot(freq, real(Z)*1e-3, 'b', 'LineWidth', lw);
plot(freq, -imag(Z)*1e-3, 'r', 'LineWidth', lw);
set(gca, 'XScale', 'log')
xlabel('Frequency (Hz)')
ylabel('Impedance (kOhm)')
legend('Re', '-Im')

% Cole-Cole plot
figure()
hold on, box on, grid on
plot(real(Z)*1e-3, -imag(Z)*1e-3, 'b', 'LineWidth', lw)
xlabel('Re(Z) (kOhm)')
ylabel('-Im(Z) (kOhm)')
title('Cole-Cole Diagram')
axis equal

%% Fit data according to Fricke model (+ HF2IS and HF2TA 50 Ohm impedances)

% restrict frequency range
ind_freq = freq<5e5;
freq_fit = freq(ind_freq);
% real and imaginary part of load impedance (over restricted frequency range)
Re_Z = real(Z(ind_freq));
Im_Z = imag(Z(ind_freq));
% assemble in a unique vector real and imaginary parts of Z
y = [Re_Z, Im_Z];

% initial guess on parameters
init_params = [0.4, 0.8, 1.5].*true_params;

% optimization
[fitted_params, obj_fun_val, exitflag, output]=fminsearch(@obj_fun, init_params, [], y, freq_fit, Z_HF2);