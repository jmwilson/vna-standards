%% Define mesh in CSX
mesh = AddPML(mesh, [0 0 0 0 8 0]);
CSX = DefineRectGrid(CSX, unit, mesh);

%% show min/max cell-size
fprintf('smallest/largest cell-size in x-dir: %f, %f\n', min(diff(mesh.x)), ...
  max(diff(mesh.x)));
fprintf('smallest/largest cell-size in y-dir: %f, %f\n', min(diff(mesh.y)), ...
  max(diff(mesh.y)));
fprintf('smallest/largest cell-size in z-dir: %f, %f\n', min(diff(mesh.z)), ...
  max(diff(mesh.z)));

%% Coaxial Port
start = [0, 0, mesh.z(1)];
stop = [0, 0, base_height];
[CSX,port{1}] = AddCoaxialPort(CSX, 4, 1, 'gold', 'teflon', ...
    start, stop, 'z', ...
    sma_pin_dia/2 , connector_inner_dia/2, connector_outer_dia/2, ...
    'ExciteAmp', 1, ...
    'FeedShift', 10*diff(mesh.z)(1), ... % some reasonable distance from the PML
    'MeasPlaneShift', -connector_barrel_length - mesh.z(1));

%% Dump boxes
CSX = AddDump(CSX, 'Et');
CSX = AddDump(CSX, 'Ht', 'DumpType', 1);
start = [mesh.x(1), mesh.y(1), mesh.z(1)];
stop  = [mesh.x(end), mesh.y(end), mesh.z(end)];
CSX = AddBox(CSX, 'Et', 0, start, stop);
CSX = AddBox(CSX, 'Ht', 0, start, stop);

%% Simulation files and options
Sim_Path = 'run';
Sim_CSX = 'standard.xml';

status = rmdir(Sim_Path, 's');
status = mkdir(Sim_Path);

openEMS_opts = '';
% openEMS_opts = '--disable-dumps';
% openEMS_opts = '--debug-PEC --no-simulation';
WriteOpenEMS([Sim_Path '/' Sim_CSX], FDTD, CSX);
CSXGeomPlot([Sim_Path '/' Sim_CSX]);
RunOpenEMS(Sim_Path, Sim_CSX, openEMS_opts);

%% Post-processing
f = linspace(f0-fc, f0+fc, 2001);
port = calcPort(port, Sim_Path, f, 'RefImpedance', 50);
s11 = port{1}.uf.ref ./ port{1}.uf.inc;
vswr = (1 + abs(s11))./(1 - abs(s11));

fd = fopen([Sim_Path '/' 'parameters.s1p'], 'w+');
fprintf(fd, "# Hz S RI R 50\n");
fdata = [f; real(s11); imag(s11)];
fprintf(fd, "%.0f %g %g\n", fdata);
fclose(fd);
