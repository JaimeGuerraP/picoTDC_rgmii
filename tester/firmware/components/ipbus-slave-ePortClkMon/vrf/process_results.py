import csv
import numpy as np
import matplotlib.pyplot as plt

fast_clk_period = 25 / 16           # ns
num_taps = 16                       # delay line length
phase_steps = 56                    # PLL fine phase shift
x = np.linspace(0, fast_clk_period * num_taps, num_taps * phase_steps, endpoint=False)

fname = 'work/rtl-ePortClkMon/results.csv'

with open(fname) as f:
    reader = csv.reader(f, delimiter=',')
    res = list(reader)
    res = [[int(int(j)) for j in i] for i in res]
    res = np.array(res)

# plot first channel
ax1 = plt.subplot(3, 1, 1)
ax1.plot(x, res[0], "x")
ax1.set_title("First channel")
ax1.set_xlabel("Time [ns] (tick = %.02f ps)" % (fast_clk_period / phase_steps * 1000))
ax1.set_ylabel("Accumulator value")
ax1.set_xticks(np.arange(0, fast_clk_period * num_taps, fast_clk_period))
ax1.grid()

# plot each channel
ax2 = plt.subplot(3, 1, 2, sharex=ax1)
for ch in res:
    ax2.plot(x, ch, "x")
ax2.set_title("Individual channels")
ax2.set_xlabel("Time [ns] (tick = %.02f ps)" % (fast_clk_period / phase_steps * 1000))
ax2.set_ylabel("Accumulator value")
ax2.set_xticks(np.arange(0, fast_clk_period * num_taps, fast_clk_period))
ax2.grid()

ax3 = plt.subplot(3, 1, 3, sharex=ax1)
# reduce data by summing all channels
reduced = np.sum(res, axis=0)
ax3.plot(x, reduced, "x")
ax3.set_title("Sum of all channels")
ax3.set_xlabel("Time [ns] (tick = %.02f ps)" % (fast_clk_period / phase_steps * 1000))
ax3.set_ylabel("Accumulator value")
ax3.set_xticks(np.arange(0, fast_clk_period * num_taps, fast_clk_period))
ax3.grid()

plt.subplots_adjust(hspace=0.4)
plt.show()
