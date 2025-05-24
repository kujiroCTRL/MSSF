% TODO: merge dis w the other CwM file
out   = model();
data  = out{2};
coord = out{3};

figure();
hold on;
for i = 1 : size(data, 1)
    plot(coord, data(i, :), 'Color', [0, 0, 0, .25]);
end

lbl1 = plot(coord, data(end, :), 'Color', [0, 0, 1, 1]);
lbl2 = plot(coord, data(1, :), 'Color', [1, 0, 0, 1]);

legend([ ...
    lbl1, ...
    lbl2 ...
    ], ...
    [ ...
    "t = "+string(T), ...
    "t = "+string(t) ...
    ]);

function out = model()
%
% eh.m
%
% Model exported on Apr 2 2025, 16:15 by COMSOL 5.5.0.359.

% variables & stuff
% diffusion params
VALdiff = 1e-2;

% coordinates of line segment
VALcoord1 = 0;
VALcoord2 = 1;

% concentrations
VALconc0 = 3;
VALconc1 = 5;

% time window
VALtrange = 0 : 1 : 100;

% COMSOL talk
import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\ACER\Documents');

model.component.create('comp1', true);
model.component('comp1').geom.create('geom1', 1);
model.component('comp1').mesh.create('mesh1');
model.component('comp1').geom('geom1').run;
model.component('comp1').mesh('mesh1').run;
model.component('comp1').geom('geom1').create('i1', 'Interval');
model.component('comp1').geom('geom1').runPre('fin');
model.component('comp1').physics.create('tds', 'DilutedSpecies', {'c'});
model.component('comp1').geom('geom1').run;

model.component('comp1').physics('tds').create('conc1', 'Concentration', 0);
model.component('comp1').physics('tds').feature('conc1').setIndex('species', true, 0);
model.component('comp1').physics('tds').feature('conc1').setIndex('c0', VALconc0, 0);
model.component('comp1').physics('tds').feature('conc1').selection.set([1]);

model.component('comp1').physics('tds').feature.duplicate('conc2', 'conc1');
model.component('comp1').physics('tds').feature('conc2').selection.set([2]);
model.component('comp1').physics('tds').feature('conc2').setIndex('c0', VALconc1, 0);

model.component('comp1').mesh('mesh1').autoMeshSize(1);
model.component('comp1').mesh('mesh1').run;

% Note : you can also just write the vars' name without stringifying it and it will automatically assume it's m^2/s
model.component('comp1').physics('tds').feature('cdm1').set('D_c', VALdiff);

model.component('comp1').mesh('mesh1').run;

% study
model.study.create('std1');
model.study('std1').create('time', 'Transient');
model.study('std1').feature('time').activate('tds', true);
model.study('std1').feature('time').set('tlist', VALtrange);

model.sol.create('sol1');
model.sol('sol1').study('std1');

model.study('std1').feature('time').set('notlistsolnum', 1);
model.study('std1').feature('time').set('notsolnum', '1');
model.study('std1').feature('time').set('listsolnum', 1);
model.study('std1').feature('time').set('solnum', '1');

model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'time');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').feature('v1').set('control', 'time');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').set('tlist', VALtrange);
model.sol('sol1').feature('t1').set('plot', 'off');
model.sol('sol1').feature('t1').set('plotgroup', 'Default');
model.sol('sol1').feature('t1').set('plotfreq', 'tout');
model.sol('sol1').feature('t1').set('probesel', 'all');
model.sol('sol1').feature('t1').set('probes', {});
model.sol('sol1').feature('t1').set('probefreq', 'tsteps');
model.sol('sol1').feature('t1').set('rtol', 0.005);
model.sol('sol1').feature('t1').set('atolglobalvaluemethod', 'factor');
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('damp', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', 8);
model.sol('sol1').feature('t1').feature('fc1').set('stabacc', 'aacc');
model.sol('sol1').feature('t1').feature('fc1').set('aaccdim', 5);
model.sol('sol1').feature('t1').feature('fc1').set('aaccmix', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('aaccdelay', 1);
model.sol('sol1').feature('t1').create('d1', 'Direct');
% WOW what is dis
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('d1').set('pivotperturb', 1.0E-13);
%
model.sol('sol1').feature('t1').feature('fc1').set('linsolver', 'd1');
model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
model.sol('sol1').feature('t1').feature('fc1').set('damp', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('maxiter', 8);
model.sol('sol1').feature('t1').feature('fc1').set('stabacc', 'aacc');
model.sol('sol1').feature('t1').feature('fc1').set('aaccdim', 5);
model.sol('sol1').feature('t1').feature('fc1').set('aaccmix', 0.9);
model.sol('sol1').feature('t1').feature('fc1').set('aaccdelay', 1);
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').attach('std1');
% useless? i think this one just prepares and does the plotting (yurp,
% confirmed! :D)
%{
model.result.create('pg1', 'PlotGroup1D');
model.result('pg1').set('data', 'dset1');
model.result('pg1').label('Concentration (tds)');
model.result('pg1').set('titletype', 'custom');
model.result('pg1').set('prefixintitle', '');
model.result('pg1').set('expressionintitle', false);
model.result('pg1').set('typeintitle', false);
model.result('pg1').create('lngr1', 'LineGraph');
model.result('pg1').feature('lngr1').set('xdata', 'expr');
model.result('pg1').feature('lngr1').set('xdataexpr', 'x');
model.result('pg1').feature('lngr1').selection.all;
model.result('pg1').feature('lngr1').set('expr', {'c'});
%}
%\end useless?
model.sol('sol1').runAll;
%{
model.result('pg1').run;
%}
% added during lecture: save a file from MATLAB's DE to a file compatible w COMSOL
mphsave(model, "diff_membrana");

% added during lecture: extract datas from study results
model.result.numerical().create('eval', 'Eval');
model.result.numerical('eval').set('expr', 'c');

data = squeeze(model.result().numerical('eval').getData());
coord = squeeze(model.result().numerical('eval').getCoordinates());
out = { model , data , coord };
end
