XRD_SDAC_CAL.sh is bash script that will calculate the necessary slope and offset needed for each DAC channel for each ASIC in the detector based on two voltage readings. There are two ways to use the script, manual mode and datalogger mode. Datalogger mode is enabled by the -a parameter, otherwise it defaults to manual mode.

bash XRD_SDAC_CAL.sh [-a]

The script will check to see if it can communicate with the detector by issuing a simple "caget det1". It will exit with an error if communcation is not available. The script will then set the channel and DAC settings and pause when user input is needed for voltage readings. 

Two files are generated from the script:

1) CSV file that contains all the voltages measured and new slope and offset for each channel.
2) Bash script file that contains all the slope and offset in caput commands that can be sent to the detector at startup.

NOTE about manual measurements: (see photo)
The DAC output is routed through the analog output of the controller. This output has an adjustable DC offset and a fixed gain of ~2x. To use the analog output, the DC offset must be adjusted to 0 by turning the potentiometer counterclockwise all the way. There is no easy way to adjust the gain but the script will ask for a gain setting. The script will default to a gain of 2 if nothing is entered or the value is less than 1. Any voltage that is entered will be divided by this gain.

To be more precise, one can measure the gain of the analog output. Setup the detector to output ~1V from VL0 to analog out. Measure the voltage before the op-amp at R27 on the controller PCB. Divide the output of the analog out with the measured voltage at R27 to get a more precise gain.

Alternatively, one can take measurements directly from R27 on the controller PCB to bypass the op-amp gain stages. Use a gain of 1 in the script when bypassing the analog out op-amps.