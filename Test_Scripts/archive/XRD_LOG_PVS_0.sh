#!bash.sh
#XRD_TEST: Acquire all XRD monitoring channels and write to a textfile (Detector-year month day-hour min). Press ctrl+c to quit program. Use sh.
#7/30/2013
#9/10/2013: Changed LOEN title to OLK on line 18


i=0
proc_dly=.1
printf "Enter Detector number:\n"
read DETECTOR

echo "Enter acquisition time interval in seconds:\n"
read DELAY

filename=`date "+XRD$DETECTOR-Log_PVs-%y%m%d-%H%M"`

printf "XRD $DETECTOR\n">$filename.txt
printf "ITERATION OLK0 OLK159 OLK319 OLK479 OLK639 AI1(Bias_V) AI2(RTD_Sensor) AI3(RTD_HOT) AI4(RTD_ASIC) AI5(CTRL_TEMP) AI6(Bias_I) AO3(Sensor_TEC) AO5(ASIC_TEC) DATE\n">>$filename.txt

while [ 0 -le 1 ]
do
caput det1.LOEN 0
sleep $proc_dly
LOEN0=$(caget det1:ai0|awk '{print $2}')
sleep $proc_dly

caput det1.LOEN 159
sleep $proc_dly
LOEN159=$(caget det1:ai0|awk '{print $2}')
sleep $proc_dly

caput det1.LOEN 319
sleep $proc_dly
LOEN319=$(caget det1:ai0|awk '{print $2}')
sleep $proc_dly

caput det1.LOEN 479
sleep $proc_dly
LOEN479=$(caget det1:ai0|awk '{print $2}')
sleep $proc_dly

caput det1.LOEN 639
sleep $proc_dly
LOEN639=$(caget det1:ai0|awk '{print $2}')
sleep $proc_dly

AI1=$(caget det1:ai1|awk '{print $2}')
AI2=$(caget det1:ai2|awk '{print $2}')
AI3=$(caget det1:ai3|awk '{print $2}')
AI4=$(caget det1:ai4|awk '{print $2}')
AI5=$(caget det1:ai5|awk '{print $2}')
AI6=$(caget det1:ai6|awk '{print $2}')
AO3=$(caget det1:ao3|awk '{print $2}')
AO5=$(caget det1:ao5|awk '{print $2}')
DATE=$(date)
ITERATION=$(echo $i)

echo  "$ITERATION $LOEN0 $LOEN159 $LOEN319 $LOEN479 $LOEN639 $AI1 $AI2 $AI3 $AI4 $AI5 $AI6 $AO3 $AO5 $DATE">>$filename.txt
echo "$ITERATION $DATE"
sleep $DELAY
i=$(( $i +1 ))
done
