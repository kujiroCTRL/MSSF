%% Single layer
close all;

% geometric parameters
r_cell = 3e-6; % cell radius, m [3,9]
d_mem = 10e-9; % cell membrane thickness, m

% material parameters
% vacuum permittivity
eps0 = 8.854e-12; % F/m

% frequency values
n_f = 50; f_in = 1e5; f_fin = 1e7;
f = logspace(log10(f_in), log10(f_fin), n_f); % frequency
omega = 2 * pi * f; % circular frequency

sig_med = 1.6; % medium conductivity, S/m,
eps_med = 80*eps0; % medium permittivity

sig_mem = 0; % cell membrane conductivity, S/m [0, 1e-3, 1e10]
eps_mem = 12.8 * eps0; % cell membrane permittivity, F/m

sig_int = 0.6; % intracellular conductivity, S/m [0.6, 2.7e-3]
eps_int = 60 * eps0; % intracellular permittivity, F/m [60, 2.5]
% per parte 2: le phi sono diverse nell'omogeneizzazione
% phi_1 = .1;
% phi_2 = r_n ^ 3 / r_c ^ 3;
CC_f_CM = calculateClausiusMossotti(r_cell, d_mem, eps_med, sig_med, eps_mem, sig_mem, eps_int, sig_int, f);
plotCellParms(r_cell, d_mem, eps_med, sig_med, eps_mem, sig_mem, eps_int, sig_int, f);
%%
Type                              radius[m]   sig_mem[S/m]   sig_int[S/m]   eps_int
bead                              3e-6        1e10           2.7e-3         2.5*eps0
viable_cell                       9e-6        0              0.6            60*eps0
necrotic_cell                     9e-6        1e-3           0.6            60*eps0
apoptotic_body                    3e-6        0              0.6            60*eps0
apoptotic_body_with_perm          3e-6        1e-3           0.6            60*eps0
