# vna-standards
OpenEMS simulation of VNA calibration standards. Read about this project at https://jmw.name/projects/vna-standards/

## Setup and run directions

1. Download octave (or use Matlab) and OpenEMS. Ensure OpenEMS is on the octave/Matlab's path using `addpath`.
1. Run simulations for the standards via `octave {open,short,load}_standard.m`. The FDTD simulation will begin after the geometry preview window is closed. Generally, the simulations will not reach the end criterion of -50 dB in any reasonable amount of time. It is acceptable to terminate the simulation once the energy level has noticeably stopped decaying by running `touch run/ABORT`. The presence of this file will stop OpenEMS.
1. Generate comparison S11 charts using `python plots.py`. This script requires `numpy` and `matplotlib`.

## Repository structure

* `data_8714ES`: S11 measurements of the standards on a 3 GHz Keysight 8714ES VNA.
* `data_N5222B`: S11 measurements of the standards on a 26.5 GHz Keysight N5222B VNA. At the time, only the 6 GHz calibration kit was available, so the data only extends to 6 GHz.
* `docs`: PDF datasheets for the Rosenberger connector used. The nominal dimension values are used in `common_setup.m`.
* `Fitting.SLDPRT`/`Fitting.STL`: the Solidworks part for the fitting cap used to enclose the SMA connectors, and a STL file appropriate for 3D printing. The opening is sized to nominal connector dimensions (.250") and may require adjustments for manufacturing and fitting.
