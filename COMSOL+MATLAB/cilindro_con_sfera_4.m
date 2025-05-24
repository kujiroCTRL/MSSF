x = model();
x.result().numerical("int1").getReal();

function out = model()
%
% cilindro_con_sfera_4.m
%
% Model exported on Apr 16 2025, 17:07 by COMSOL 5.5.0.359.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\ACER\Desktop\MSSF\COMSOL+MATLAB');
model.label('cilindro_con_sfera_3.mph');
model.component.create('comp1', true);
model.component('comp1').geom.create('geom1', 3);
model.result.table.create('tbl1', 'Table');
model.component('comp1').mesh.create('mesh1');

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

model.component('comp1').physics.create('tds', 'DilutedSpecies', 'geom1');
model.component('comp1').physics('tds').create('init2', 'init', 3);
model.component('comp1').physics('tds').feature('init2').selection.set([2 3 4 5]);
model.component('comp1').physics('tds').create('cdm2', 'ConvectionDiffusionMigration', 3);
model.component('comp1').physics('tds').feature('cdm2').selection.set([1]);

model.component('comp1').mesh('mesh1').autoMeshSize(9);

model.result.table('tbl1').comments('Volume Integration 1');

model.component('comp1').view('view1').set('transparency', true);

model.component('comp1').physics('tds').feature('cdm1').set('D_c', [2.0E-6; 0; 0; 0; 2.0E-6; 0; 0; 0; 2.0E-6]);
model.component('comp1').physics('tds').feature('cdm1').label('Transport Properties (sferette)');
model.component('comp1').physics('tds').feature('init1').label('Initial Values 1 (cilindro)');
model.component('comp1').physics('tds').feature('init2').set('initc', 3);
model.component('comp1').physics('tds').feature('init2').label('Initial Values 1 (sferette)');
model.component('comp1').physics('tds').feature('cdm2').set('D_c', [1.0E-6; 0; 0; 0; 1.0E-6; 0; 0; 0; 1.0E-6]);
model.component('comp1').physics('tds').feature('cdm2').label('Transport Properties 1 (cilindro)');

model.study.create('std1');
model.study('std1').create('time', 'Transient');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').create('i1', 'Iterative');
model.sol('sol1').feature('t1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').create('sl1', 'SORLine');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').create('sl1', 'SORLine');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature.remove('fcDef');

model.result.numerical.create('int1', 'IntVolume');
model.result.numerical('int1').selection.set([1]);
model.result.numerical('int1').set('probetag', 'none');
% model.result.create('pg1', 'PlotGroup3D');
% model.result.create('pg2', 'PlotGroup3D');
model.result.create('pg3', 'PlotGroup1D');
% model.result('pg1').create('str1', 'Streamline');
% model.result('pg1').feature('str1').create('col', 'Color');
% model.result('pg2').create('surf1', 'Surface');
model.result('pg3').create('tblp1', 'Table');

model.study('std1').feature('time').set('tlist', [0 0.2 0.4 0.6000000000000001 0.8 1 1.2000000000000002 1.4000000000000001 1.6 1.8 2 2.2 2.4 2.5999999999999996 2.8 3 3.2 3.4 3.6 3.8 4]);

model.sol('sol1').attach('std1');
model.sol('sol1').feature('v1').set('clist', {'0, 0.2, 0.4, 0.6000000000000001, 0.8, 1, 1.2000000000000002, 1.4000000000000001, 1.6, 1.8, 2, 2.2, 2.4, 2.5999999999999996, 2.8, 3, 3.2, 3.4, 3.6, 3.8, 4' '0.004[s]'});
model.sol('sol1').feature('t1').set('control', 'user');
model.sol('sol1').feature('t1').set('tlist', [0 0.2 0.4 0.6000000000000001 0.8 1 1.2000000000000002 1.4000000000000001 1.6 1.8 2 2.2 2.4 2.5999999999999996 2.8 3 3.2 3.4 3.6 3.8 4]);
model.sol('sol1').feature('t1').set('rtol', 0.005);
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', 8);
model.sol('sol1').feature('t1').feature('fc1').set('damp', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('stabacc', 'aacc');
model.sol('sol1').feature('t1').feature('fc1').set('aaccdim', 5);
model.sol('sol1').feature('t1').feature('fc1').set('aaccmix', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('aaccdelay', 1);
model.sol('sol1').feature('t1').feature('i1').set('maxlinit', 400);
model.sol('sol1').feature('t1').feature('i1').set('rhob', 40);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature('sl1').set('linerelax', 0.2);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature('sl1').set('relax', 0.4);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('linerelax', 0.2);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('seconditer', 2);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('sl1').set('relax', 0.4);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').feature('d1').set('pivotperturb', 1.0E-13);
model.sol('sol1').runAll;

model.result.numerical('int1').set('table', 'tbl1');
model.result.numerical('int1').set('expr', {'c'});
model.result.numerical('int1').set('unit', {'mol'});
model.result.numerical('int1').set('descr', {'Concentration'});
model.result.numerical('int1').setResult;

% model.result('pg1').label('Concentration, Streamline (tds)');
% model.result('pg1').set('titletype', 'custom');
% model.result('pg1').feature('str1').set('posmethod', 'start');
% model.result('pg1').feature('str1').set('pointtype', 'arrow');
% model.result('pg1').feature('str1').set('arrowcount', 35);
% model.result('pg1').feature('str1').set('arrowlength', 'logarithmic');
% model.result('pg1').feature('str1').set('arrowscale', 607.7557414184245);
% model.result('pg1').feature('str1').set('arrowcountactive', false);
% model.result('pg1').feature('str1').set('arrowscaleactive', false);
% model.result('pg1').feature('str1').set('resolution', 'normal');
% model.result('pg1').feature('str1').feature('col').set('descr', 'Concentration');
% model.result('pg1').feature('str1').feature('col').set('titletype', 'custom');
% model.result('pg2').label('Concentration, Surface (tds)');
% model.result('pg2').set('titletype', 'custom');
% model.result('pg2').set('typeintitle', false);
% model.result('pg2').feature('surf1').set('descr', 'Concentration');
% model.result('pg2').feature('surf1').set('resolution', 'normal');
model.result('pg3').set('data', 'none');
model.result('pg3').set('xlabel', 'Time (s)');
model.result('pg3').set('ylabel', 'Concentration (mol)');
model.result('pg3').set('xlabelactive', false);
model.result('pg3').set('ylabelactive', false);

out = model;
end