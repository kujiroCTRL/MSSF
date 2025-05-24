function out = model
%
% cilindro_con_sfera_2.m
%
% Model exported on Apr 16 2025, 16:30 by COMSOL 5.5.0.359.
import com.comsol.model.*
import com.comsol.model.util.*

% Coefficienti di diffusione rispettivamente delle sferette e del cilindro
D_sph = 2e-6;
D_cyl = 1e-6;

% Concentrazioni iniziali rispettivamente delle sferette e del cilindro
C_sph = 3;
C_cyl  = 0;

model = ModelUtil.create('Model');
model.modelPath('C:\Users\ACER\Desktop\MSSF\COMSOL+MATLAB');
model.label('cilindro_con_sfera.mph');

model.component.create('comp1', true);
model.component('comp1').geom.create('geom1', 3);
model.component('comp1').mesh.create('mesh1');

% Stesso instruction flow dell'altro file (sferette + cilindro)
model.component('comp1').geom('geom1').create('sph1', 'Sphere');
model.component('comp1').geom('geom1').feature('sph1').set('pos', [0 0.015 0.01]);
model.component('comp1').geom('geom1').feature('sph1').set('r', 0.003);
model.component('comp1').geom('geom1').create('sph2', 'Sphere');
model.component('comp1').geom('geom1').feature('sph2').set('pos', [0 -0.015 0.01]);
model.component('comp1').geom('geom1').feature('sph2').set('r', 0.003);
model.component('comp1').geom('geom1').create('sph3', 'Sphere');
model.component('comp1').geom('geom1').feature('sph3').set('pos', [0 0.0075 0.01]);
model.component('comp1').geom('geom1').feature('sph3').set('r', 0.003);
model.component('comp1').geom('geom1').create('sph4', 'Sphere');
model.component('comp1').geom('geom1').feature('sph4').set('pos', [0 -0.0075 0.01]);
model.component('comp1').geom('geom1').feature('sph4').set('r', 0.003);
model.component('comp1').geom('geom1').create('cyl1', 'Cylinder');
model.component('comp1').geom('geom1').feature('cyl1').set('pos', [0 0 0]);
model.component('comp1').geom('geom1').feature('cyl1').set('r', 0.03);
model.component('comp1').geom('geom1').feature('cyl1').set('h', 0.02);
model.component('comp1').geom('geom1').run;
model.component('comp1').geom('geom1').run('fin');

% Nuove istruzioni per la creazione e definizione della fisica
% NOTA e TODO: cmd1 è la distribuzione delle sferette, cmd2 del cilindro
% mentre init1 è la concentrazione iniziale del cilindro e init2 delle sferette 
model.component('comp1').physics.create('tds', 'DilutedSpecies', 'geom1');
model.component('comp1').physics('tds').create('init2', 'init', C_sph);
%                                                                       numeri
%                                                                       dei
%                                                                       domini
%                                                                       delle
%                                                                       sferette
model.component('comp1').physics('tds').feature('init2').selection.set([2 3 4 5]);
model.component('comp1').physics('tds').create('cdm2', 'ConvectionDiffusionMigration', 3);
%                                                                      numero
%                                                                      del
%                                                                      dominio
%                                                                      del
%                                                                      cilindro
model.component('comp1').physics('tds').feature('cdm2').selection.set([1]);

model.component('comp1').view('view1').set('transparency', true);

%                                                                    coefficienti
%                                                                    di
%                                                                    diffusione
%                                                                    per le
%                                                                    sferette
%                                                                    (nota
%                                                                    il
%                                                                    'cmd1')
model.component('comp1').physics('tds').feature('cdm1').set('D_c', D_sph);
model.component('comp1').physics('tds').feature('cdm1').label('Transport Properties (sferette)');
model.component('comp1').physics('tds').feature('init2').set('initc', C_sph);
model.component('comp1').physics('tds').feature('init2').label('Initial Values 1 (sferette)');


%                                                                    coefficienti
%                                                                    di
%                                                                    diffusione
%                                                                    per il
%                                                                    cilindro
%                                                                    (nota
%                                                                    il
%                                                                    'cmd2')
model.component('comp1').physics('tds').feature('cdm2').set('D_c', D_cyl);
model.component('comp1').physics('tds').feature('cdm2').label('Transport Properties 1 (cilindro)');
model.component('comp1').physics('tds').feature('init1').set('initc', C_cyl);
model.component('comp1').physics('tds').feature('init1').label('Initial Values 1 (cilindro)');

model.study.create('std1');
model.study('std1').create('time', 'Transient');

% Salva il modello
mphsave(model, "cilindro_con_sfera_2.mph");

out = model;
