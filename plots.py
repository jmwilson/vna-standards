import matplotlib.pyplot as plt
import matplotlib
import numpy
import os

from matplotlib.ticker import EngFormatter

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
    plt.figure(figsize=(10,6))
    ax = plt.axes()
    h1, = plt.plot(freq, 20*numpy.log10(numpy.abs(s11)),
        label="model (mag.)")
    h2, = plt.plot(freq_meas, 20*numpy.log10(numpy.abs(s11_meas)),
        label="measured (mag.)", color="coral")
    plt.xscale('log')
    ax.xaxis.set_major_formatter(EngFormatter(unit='Hz'))
    plt.xlabel('Frequency')
    plt.ylabel('$|S_{11}|$ (dB)')
    plt.grid(axis='x', which='both')
    plt.twinx()
    plt.ylabel("Phase (°)")
    h3, = plt.plot(freq, numpy.angle(s11, deg=True),
        linestyle="dashed", label="model (phase)")
    h4, = plt.plot(freq_meas, numpy.angle(s11_meas, deg=True),
        linestyle="dashed", label="measured (phase)", color="coral")
    plt.legend(handles=[h1, h2, h3, h4], loc="lower left")

sim_path = ''
meas_path = 'data_8714ES'

with open(os.path.join(sim_path, 'open.s1p')) as fd:
    freq_sim, s11_sim = read_s1p_file(fd)
with open(os.path.join(meas_path, 'open.s1p')) as fd:
    freq_meas, s11_meas = read_s1p_file(fd)
mask = freq_meas <= 3e9
compare_plot(freq_sim, s11_sim, freq_meas[mask], s11_meas[mask])
plt.gcf().axes[0].set_ylim([-1, .1])
plt.title("Open standard")
plt.tight_layout()
plt.savefig("open-s11.svg", format="svg")

with open(os.path.join(sim_path, 'short.s1p')) as fd:
    freq_sim, s11_sim = read_s1p_file(fd)
with open(os.path.join(meas_path, 'short.s1p')) as fd:
    freq_meas, s11_meas = read_s1p_file(fd)
mask = freq_meas <= 3e9
compare_plot(freq_sim, s11_sim, freq_meas[mask], s11_meas[mask])
plt.gcf().axes[0].set_ylim([-1, .1])
plt.title("Short standard")
plt.tight_layout()
plt.savefig("short-s11.svg", format="svg")

with open(os.path.join(sim_path, 'load.s1p')) as fd:
    freq_sim, s11_sim = read_s1p_file(fd)
with open(os.path.join(meas_path, 'load.s1p')) as fd:
    freq_meas, s11_meas = read_s1p_file(fd)
mask = freq_meas <= 3e9
compare_plot(freq_sim, s11_sim, freq_meas[mask], s11_meas[mask])
plt.title("Load standard")
plt.tight_layout()
plt.savefig("load-s11.svg", format="svg")
