function out = model
import com.comsol.model.*
import com.comsol.model.util.*
model = ModelUtil.create(['Mod' ...
    'el']);

% Parametri
R_cyl = 3e-2;
H_cyl = 2e-2;

R_sph = .3e-2;

% posizione del centro del cerchio alla base
C_cyl = [0, 0, 0];
% posizione del centro della sfera
C_sph = [0, R_cyl / 2, H_cyl / 2 ; 0, - R_cyl / 2, H_cyl / 2  ; 0, R_cyl / 4, H_cyl / 2  ; 0, - R_cyl / 4, H_cyl / 2];

N_sph = size(C_sph, 1);

model.modelPath('C:\Users\ACER\Desktop\MSSF\COMSOL+MATLAB');

model.component.create('comp1', true);
model.component('comp1').geom.create('geom1', 3);
model.component('comp1').mesh.create('mesh1');

% Sfera
for i = 1 : N_sph
    name = 'sph' + string(i);
    model.component('comp1').geom('geom1').create(name, 'Sphere');
    model.component('comp1').geom('geom1').feature(name).set('r', R_sph);
    model.component('comp1').geom('geom1').feature(name).set('pos', C_sph(i,:));
end

% Cilindro
model.component('comp1').geom('geom1').create('cyl1', 'Cylinder');
model.component('comp1').geom('geom1').feature('cyl1').set('pos', C_cyl);
model.component('comp1').geom('geom1').feature('cyl1').set('r', R_cyl);
model.component('comp1').geom('geom1').feature('cyl1').set('h', H_cyl);

model.view('view1').set('transparency', 'on');

% Roba che metteremo e modificheremo dopo
model.component('comp1').physics.create('tds', 'DilutedSpecies', 'geom1');

model.study.create('std1');
model.study('std1').create('time', 'Transient');

model.component('comp1').geom('geom1').run;

type = 'boundary';
tol = 1e-3 * R_sph;
y = mphselectbox(model, ...
    'geom1', [ - R_sph - tol + C_sph(1, 1) , + R_sph + tol + C_sph(1, 1) ; - R_sph - tol + C_sph(1, 2) , + R_sph + tol + C_sph(1, 2)  ; - R_sph - tol + C_sph(1, 3) , + R_sph + tol + C_sph(1, 3) ], ...
    type ...
    );

figure();
mphviewselection(model,'geom1',y(1:4),type, 'facecolorselected',[1 1 0], 'facealpha',.5)

% Salva il modello generato dal file MATLAB in un formato COMSOL-compliant
mphsave(model, "cilindro_con_sfera.mph");

% figure();
% mphgeom(model, 'geom1', 'facealpha', .5);

out = {model, y};
end

x = model()

% TO BE STUDIED
% mphgetproperties(x{1}.component('comp1').geom('geom1').feature('cyl1'))