common_setup;

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
CC = 1./(j*2*pi*50*f) .* (1 - s11_0)./(1 + s11_0);
Cmodel = polyfit(f, real(CC), 3);

fprintf('Electrical length: %f mm\n', elec_length);
fprintf('C0 = %f fF, C1 = %f fF/GHz, C2 = %f fF/GHz^2, C3 = %f fF/GHz^3\n', ...
  1e15 * Cmodel(4), 1e24 * Cmodel(3), 1e33 * Cmodel(2), 1e42 * Cmodel(1));

status = copyfile([Sim_Path '/' 'parameters.s1p'], 'open.s1p', 'f');
