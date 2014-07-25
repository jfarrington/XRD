#!bash.sh
#Setup Head for TRIM DAC
#9/6/2013
#####################################################################

printf "Starting Script\n"

# J.Farrington 9/12/13
# bash ../../Scripts/XRD_2_CAL-130906-1245.sh
bash ../Scripts/XRD_DAC_CAL/example/XRD_PROTO1_CAL-130827-1523.sh

# Force values into Head
caput det1.VL0 .5
caput det1.VL1 .5
caput det1.VL2 .5
caput det1.VH1 2.0
caput det1.VH2 2.0

# Set to external calibration
caput det1.CalibIO External

#Set the Bias to 20 v
caput det1:ao4 170

#Set the TEC to cool 1.5 amp
caput det1:ao3 2.25
caput det1:ao5 1.75

#enable test pulses
# J.Farrington 9/12/13
#../../test_on
../test_on

# small non-zero wait between autocounts is good
caput det1.TP1 .01

#set default shaping time
caput det1.SHPT 0.5us

#set default gain
caput det1.GAIN L

#start grace / ASIC trim
./trim
