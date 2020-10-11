#!/usr/bin/env python

import sys
import numpy as np

## We need matplotlib:
## $ apt-get install python-matplotlib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

x_Axis = []
ipc_Axis = []
mpkil2_Axis = []
mpkil1_Axis = []

for outFile in sys.argv[1:]:
	fp = open(outFile)
	line = fp.readline()
	while line:
		tokens = line.split()
		if (line.startswith("Total Instructions: ")):
			total_instructions = long(tokens[2])
		elif (line.startswith("IPC:")):
			ipc = float(tokens[1])
		elif (line.startswith("L2_prefetching")):
			l2_prf = int(tokens[3].split(')')[0])
		elif (line.startswith("L2-Total-Misses")):
			l2_total_misses = long(tokens[1])
			l2_miss_rate = float(tokens[2].split('%')[0])
			mpkil2 = l2_total_misses / (total_instructions / 1000.0)
		elif (line.startswith("L1-Total-Misses")):
			l1_total_misses = long(tokens[1])
			l1_miss_rate = float(tokens[2].split('%')[0])
			mpkil1 = l1_total_misses / (total_instructions / 1000.0)


		line = fp.readline()

	fp.close()

	prfConfigStr = '{}'.format(l2_prf)
	print prfConfigStr
	x_Axis.append(prfConfigStr)
	ipc_Axis.append(ipc)
	mpkil2_Axis.append(mpkil2)
	mpkil1_Axis.append(mpkil1)

print x_Axis
print ipc_Axis
print mpkil2_Axis
print mpkil1_Axis

fig, ax1 = plt.subplots()
ax1.grid(True)
ax1.set_xlabel("Prefetching")

xAx = np.arange(len(x_Axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=45)
ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
ax1.set_ylim(min(ipc_Axis) - 0.05 * min(ipc_Axis), max(ipc_Axis) + 0.05 * max(ipc_Axis))
ax1.set_ylabel("$IPC$")
line1 = ax1.plot(ipc_Axis, label="ipc", color="red",marker='x')

ax2 = ax1.twinx()
ax2.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax2.set_xticklabels(x_Axis, rotation=45)
ax2.set_xlim(-0.5, len(x_Axis) - 0.5)
ax2.set_ylim(min(mpkil2_Axis) - 0.05 * min(mpkil2_Axis), max(mpkil2_Axis) + 0.05 * max(mpkil2_Axis))
ax2.set_ylabel("$MPKI_L2$")
line2 = ax2.plot(mpkil2_Axis, label="L2D_mpki", color="green",marker='o')

ax3 = ax1.twinx()
ax3.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax3.set_xticklabels(x_Axis, rotation=45)
ax3.set_xlim(-0.5, len(x_Axis) - 0.5)
ax3.set_ylim(min(mpkil1_Axis) - 0.05 * min(mpkil1_Axis), max(mpkil1_Axis) + 0.05 * max(mpkil1_Axis))
ax3.set_ylabel("$MPKI_L1$")
line3 = ax3.plot(mpkil1_Axis, label="L1D_mpki", color="blue",marker='*')

lns = line1 + line2 + line3
labs = [l.get_label() for l in lns]

plt.title("Prefetching")
lgd = plt.legend(lns, labs)
lgd.draw_frame(False)
plt.savefig("PRF.png",bbox_inches="tight")
