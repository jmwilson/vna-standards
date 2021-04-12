common_setup;

%% Short standard: shorting pad
start = [-base_side/2, -base_side/2, base_height + pad_height];
stop = start + [base_side, base_side, 0];
CSX = AddBox(CSX, 'copper', 3, start, stop);

%% Define meshing
coarse_resolution = lambda/20;
fine_resolution = sma_pin_dia/20;
resolution_z = sma_pin_dia/5;
fine_features_x = [sma_pin_dia/2, connector_inner_dia/2, connector_outer_dia/2];
coarse_features_x = [base_side/2];
features_z = [-max_lambda/4, 0, ...
  base_height, base_height + pad_height, ...
  housing_end];
fine_mesh_x = SmoothMeshLines2([fine_features_x, -fine_features_x], fine_resolution, 1.3);
mesh.x = SmoothMeshLines([coarse_features_x, -coarse_features_x, fine_mesh_x], coarse_resolution, 1.3);
mesh.y = mesh.x;
mesh.z = SmoothMeshLines2(features_z, resolution_z, 1.3);

run_simulation;

% Find transmission line length from slope of S11 phase
phase_model = polyfit(2*pi*f, unwrap(arg(s11)), 1);
gd = phase_model(1);
elec_length = 1/2*C0*-gd/unit;

% Remove transmission line effects to determine S11 at the point of load
s11_0 = exp(j*2*elec_length*unit*2*pi/C0*f).*s11;
LL = 50./(j*2*pi*f) .* (1 + s11_0)./(1 - s11_0);
Lmodel = polyfit(f, real(LL), 3);

fprintf('Electrical length: %f mm\n', elec_length);
fprintf('L0 = %f pH, L1 = %f pH/GHz, L2 = %f pH/GHz^2, L3 = %f pH/GHz^3\n', ...
  1e12 * Lmodel(4), 1e21 * Lmodel(3), 1e30 * Lmodel(2), 1e39 * Lmodel(1));

status = copyfile([Sim_Path '/' 'parameters.s1p'], 'short.s1p', 'f');
