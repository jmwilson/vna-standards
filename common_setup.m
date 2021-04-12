close all
clear all
clc

physical_constants;
unit = 1e-3; % mm

%% Geometry
% SMA Connector geometry based on Rosenberger documents:
%   32K10A-40ML5
%   32-000-000_TD
base_height = 1.15;
base_side = 6.35;
pad_height = .5;
pad_side = 1.275;

housing_end = 10;

sma_pin_dia = 1.27;
connector_outer_dia = 5.385;
connector_inner_dia = 4.178;
connector_barrel_length = 5.92;

r0805_length = 2;
r0805_term = .4;

teflon_er = 2.1;
teflon_tand = 280e-6; % 3 GHz
teflon_kappa = teflon_tand * 2*pi * 3e9 * EPS0 * teflon_er;
alumina_er = 9.4;
alumina_tand = 200e-6; % 1 GHz
alumina_kappa = alumina_tand * 2*pi * 1e9 * EPS0 * alumina_er;

%% Excitation
f_start = 2e6;
f_stop = 3e9;
f0 = (f_start + f_stop)/2;
fc = f_stop - f0;

lambda = c0/sqrt(teflon_er)/(f0 + fc)/unit;  % shortest wavelength of interest
max_lambda = c0/sqrt(teflon_er)/f0/unit;

%% Setup FDTD and CSXCAD operators
FDTD = InitFDTD('EndCriteria', 1e-5);
FDTD = SetGaussExcite( FDTD, f0, fc );
BC   = {'PEC', 'PEC', 'PEC', 'PEC', 'PML_8', 'PEC'};
FDTD = SetBoundaryCond(FDTD, BC);

CSX = InitCSX();

%% Materials
CSX = AddMetal(CSX, 'gold');
CSX = AddMaterial(CSX, 'teflon');
CSX = AddMaterial(CSX, 'alumina');
CSX = AddConductingSheet(CSX, 'copper', 6e7, 254e-6);
CSX = SetMaterialProperty(CSX, 'teflon', 'Epsilon', teflon_er, 'Kappa', teflon_kappa);
CSX = SetMaterialProperty(CSX, 'alumina', 'Epsilon', alumina_er, 'Kappa', alumina_kappa);

% Base box and hole
start = [-base_side/2, -base_side/2, 0];
stop = [base_side/2, base_side/2, base_height];
CSX = AddBox(CSX, 'gold', 1, start, stop);

% 4x ground solder pads
rot_90 = [0, 1, 0; -1, 0, 0; 0, 0, 1];
start = [-base_side/2, -base_side/2, base_height];
stop = start + [pad_side, pad_side, pad_height];
CSX = AddBox(CSX, 'gold', 1, start, stop);
CSX = AddBox(CSX, 'gold', 1, start*rot_90, stop*rot_90);
CSX = AddBox(CSX, 'gold', 1, start*rot_90^2, stop*rot_90^2);
CSX = AddBox(CSX, 'gold', 1, start*rot_90^3, stop*rot_90^3);

% Center conductor solder pad
start = [0, 0, base_height];
stop = start + [0, 0, pad_height];
CSX = AddCylinder(CSX, 'gold', 4, start, stop, sma_pin_dia/2);
