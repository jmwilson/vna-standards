common_setup;

%% Load standard: 2x 100 ohm 0805 (2012 metric) chip resistors
% Width and height of 0805 are close enough to use W = sma_pin_dia/2 and
% H = pad_height
% Resistive elements are planar films
flip_x = eye(3); flip_x(1,1) = -1;
CSX = AddLumpedElement(CSX, '100R', 'x', 'Caps', 0, 'R', 100);
start = [sma_pin_dia/2 + r0805_term, -sma_pin_dia/2, base_height + pad_height];
stop = [r0805_length - r0805_term + sma_pin_dia/2, sma_pin_dia/2, base_height + pad_height];
CSX = AddBox(CSX, '100R', 4, start, stop);
CSX = AddBox(CSX, '100R', 4, start*flip_x, stop*flip_x);

% Ceramic substrate
start = [sma_pin_dia/2, -sma_pin_dia/2, base_height];
stop = [2 + sma_pin_dia/2, sma_pin_dia/2, base_height + pad_height];
CSX = AddBox(CSX, 'alumina', 3, start, stop);
CSX = AddBox(CSX, 'alumina', 3, start*flip_x, stop*flip_x);

% Manually add resistor terminations
% Sides
start = [sma_pin_dia/2, -sma_pin_dia/2, base_height];
stop = start + [0, sma_pin_dia, pad_height];
CSX = AddBox(CSX, 'gold', 4, start, stop);
CSX = AddBox(CSX, 'gold', 4, start*flip_x, stop*flip_x);

start = start + [r0805_length, 0, 0];
stop = stop + [r0805_length, 0, 0];
CSX = AddBox(CSX, 'gold', 4, start, stop);
CSX = AddBox(CSX, 'gold', 4, start*flip_x, stop*flip_x);

% Top and bottom
pad_start = [sma_pin_dia/2, -sma_pin_dia/2, base_height];
pad_stop = pad_start + [r0805_term, sma_pin_dia, 0];
start = pad_start;
stop = pad_stop;
CSX = AddBox(CSX, 'gold', 4, start, stop);
CSX = AddBox(CSX, 'gold', 4, start*flip_x, stop*flip_x);

start = pad_start + [0, 0, pad_height];
stop = pad_stop + [0, 0, pad_height];
CSX = AddBox(CSX, 'gold', 4, start, stop);
CSX = AddBox(CSX, 'gold', 4, start*flip_x, stop*flip_x);

start = pad_start + [r0805_length - r0805_term, 0, 0];
stop = pad_stop + [r0805_length - r0805_term, 0, 0];
CSX = AddBox(CSX, 'gold', 4, start, stop);
CSX = AddBox(CSX, 'gold', 4, start*flip_x, stop*flip_x);

start = pad_start + [r0805_length - r0805_term, 0, pad_height];
stop = pad_stop + [r0805_length - r0805_term, 0, pad_height];
CSX = AddBox(CSX, 'gold', 4, start, stop);
CSX = AddBox(CSX, 'gold', 4, start*flip_x, stop*flip_x);

% Add a box to solidly connect the center pin to the resistor terminations
start = [-sma_pin_dia/2, -sma_pin_dia/4, base_height];
stop =  [sma_pin_dia/2, sma_pin_dia/4, base_height + pad_height];
CSX = AddBox(CSX, 'gold', 4, start, stop);

%% Define meshing
coarse_resolution = lambda/20;
fine_resolution = sma_pin_dia/20;
resolution_z = sma_pin_dia/5;
fine_features_x = [sma_pin_dia/2, connector_inner_dia/2, connector_outer_dia/2, ...
  sma_pin_dia/2 + r0805_term,...
  sma_pin_dia/2 + r0805_length - r0805_term,...
  sma_pin_dia/2 + r0805_length];
fine_features_y = [sma_pin_dia/2, connector_inner_dia/2, connector_outer_dia/2];
features_z = [-max_lambda/4, 0, ...
  base_height, base_height + pad_height, ...
  housing_end];
fine_mesh_x = SmoothMeshLines2([fine_features_x, -fine_features_x], fine_resolution, 1.3);
fine_mesh_y = SmoothMeshLines2([fine_features_y, -fine_features_y], fine_resolution, 1.3);
coarse_features_x = [base_side/2];
coarse_features_y = coarse_features_x;
mesh.x = SmoothMeshLines([coarse_features_x, -coarse_features_x, fine_mesh_x], coarse_resolution, 1.3);
mesh.y = SmoothMeshLines([coarse_features_y, -coarse_features_y, fine_mesh_y], coarse_resolution, 1.3);
mesh.z = SmoothMeshLines2(features_z, resolution_z, 1.3);

run_simulation;

status = copyfile([Sim_Path '/' 'parameters.s1p'], 'load.s1p', 'f');
