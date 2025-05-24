function out = model
%
% cilindro_sfera.m
%
% Model exported on Apr 9 2025, 16:27 by COMSOL 5.5.0.359.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\ACER\Desktop\MSSF\COMSOL+MATLAB');

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.component('comp1').mesh.create('mesh1');

model.component('comp1').geom('geom1').create('sph1', 'Sphere');
model.component('comp1').geom('geom1').feature('sph1').set('r', 9.3);
model.component('comp1').geom('geom1').create('cyl1', 'Cylinder');
model.component('comp1').geom('geom1').feature('cyl1').set('pos', {'.3' '.4' '.5'});
model.component('comp1').geom('geom1').feature('cyl1').set('r', 32);
model.component('comp1').geom('geom1').feature('cyl1').set('h', 13);

model.component('comp1').physics.create('tds', 'DilutedSpecies', 'geom1');

model.study.create('std1');
model.study('std1').create('time', 'Transient');

out = model;
