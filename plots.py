import matplotlib.pyplot as plt
import matplotlib
import numpy
import os

# Quick and dirty Touchstone file reader for S1P
def read_s1p_file(fd):
    lines = filter(lambda s: not s.startswith('!'), fd.readlines())
    option_line, *data = lines
    if not option_line.startswith("#"):
        raise ValueError('Invalid Touchstone file')
    freq_unit, parameter, fmt, _, Z0 = option_line.lstrip(
        '#').casefold().split()
    if freq_unit == 'hz':
        freq_exp = 1
    elif freq_unit == 'khz':
        freq_exp = 1e3
    elif freq_unit == 'mhz':
        freq_exp = 1e6
    elif freq_unit == 'ghz':
        freq_exp = 1e9
    else:
        raise ValueError('Invalid frequency unit in Touchstone file')
    if not(parameter == 's' and fmt == 'ri'):
        raise ValueError('Unexpected Touchstone format, bailing...')
    mat = numpy.array([list(map(float, l.split())) for l in data])
    freq = freq_exp * mat[:,0]
    s11 = mat[:,1] + 1j * mat[:,2]
    return freq, s11

# Compare magnitude and phase of S11 on same axes
def compare_plot(freq, s11, freq_meas, s11_meas):
	plt.style.use('dark_background')
	fig, ax = plt.subplots(tight_layout=True)
	ax.set_title("OPEN STANDARD $\mathrm{S_{11}}$")
	fig.set_size_inches(12,8)
	fig.set_dpi(100)
	h1, = ax.semilogx(freq, 20*numpy.log10(numpy.abs(s11)),
        label="model (mag.)")
	h1_cal, = ax.semilogx(freq_meas, 20*numpy.log10(numpy.abs(s11_meas)),
        label="measured (mag.)", color="coral")
	ax.set_xlabel("FREQUENCY (Hz)")
	ax.set_ylabel("MAGNITUDE (dB)")
	phase_ax = ax.twinx()
	phase_ax.set_ylabel("PHASE (°)")
	h2, = phase_ax.semilogx(freq, numpy.angle(s11, deg=True),
        linestyle="dashed", label="model (phase)")
	h2_cal, = phase_ax.semilogx(freq_meas, numpy.angle(s11_meas, deg=True),
        linestyle="dashed", label="measured (phase)", color="coral")
	plt.legend(handles=[h1, h2, h1_cal, h2_cal], loc="lower left")
	return fig

sim_path = ''
meas_path = 'data_N5222B'

with open(os.path.join(sim_path, 'open.s1p')) as fd:
    freq_sim, s11_sim = read_s1p_file(fd)
with open(os.path.join(meas_path, 'open.s1p')) as fd:
    freq_meas, s11_meas = read_s1p_file(fd)
mask = freq_meas <= 3e9
fig = compare_plot(freq_sim, s11_sim, freq_meas[mask], s11_meas[mask])
ax, *_ = fig.get_axes()
ax.set_ylim([-1,.1])
fig.savefig("open-s11.svg", format="svg")

with open(os.path.join(sim_path, 'short.s1p')) as fd:
    freq_sim, s11_sim = read_s1p_file(fd)
with open(os.path.join(meas_path, 'short.s1p')) as fd:
    freq_meas, s11_meas = read_s1p_file(fd)
mask = freq_meas <= 3e9
fig = compare_plot(freq_sim, s11_sim, freq_meas[mask], s11_meas[mask])
ax, *_ = fig.get_axes()
ax.set_ylim([-1,.1])
fig.savefig("short-s11.svg", format="svg")

with open(os.path.join(sim_path, 'load.s1p')) as fd:
    freq_sim, s11_sim = read_s1p_file(fd)
with open(os.path.join(meas_path, 'load.s1p')) as fd:
    freq_meas, s11_meas = read_s1p_file(fd)
mask = freq_meas <= 3e9
fig = compare_plot(freq_sim, s11_sim, freq_meas[mask], s11_meas[mask])
fig.savefig("load-s11.svg", format="svg")
