#!bash.sh
#XRD_OLK_TEST: Record Leakage as a function of temperature. Write to a textfile (Detector_LEAK-year month day-hour min). Use bash.
#9/10/2013
#10/4/2013: Added measurement of OLK for all 640 pixels

proc_dly=2 #Delay between caput and caget commands for OLK 
TEC_SENS_I=0 #Initial Sensor TEC current=TEC_SENS_I/100 (i.e 150=1.5A)
TEC_STEP_I=25 #Sensor TEC current increment=TEC_STEP_I/100 (i.e 150=1.5A)
#Leave TECs at the values below before endindg the script 
TEC_SENS_FINAL=220 
TEC_ASIC_FINAL=170

printf "Enter Detector number:\n"
read DETECTOR

printf "Enter acquisition time interval in seconds:\n"
read DELAY

caput det1.SHPT 4.0us
printf "Shaping time set to 4us\n"

caput det1.GAIN H
printf "Gain set to High\nStarting...\n"

caput det1:ao3 $(bc <<<"scale=2;0/100") #Set the sensor TEC current to 0A
caput det1:ao5 $(bc <<<"scale=2;100/100") #Setthe ASIC TEC current to 1.A
printf "TECs changed to start values. Waiting for temperature to stabilize for $DELAY sec\n"

filename1=`date "+XRD$DETECTOR-OLK_TEST_PVs-%y%m%d-%H%M"`
filename2=`date "+XRD$DETECTOR-OLK_TEST_OLK-%y%m%d-%H%M"`

#Create filenames
printf "XRD $DETECTOR\n">$filename1.txt
printf "ITERATION OLK0 OLK159 OLK319 OLK479 OLK639 AI1(Bias_V) AI2(RTD_Sensor) AI3(RTD_HOT) AI4(RTD_ASIC) AI5(CTRL_TEMP) AI6(Bias_I) AO3(Sensor_TEC) AO5(ASIC_TEC) START END\n">>$filename1.txt

printf "XRD $DETECTOR\n">$filename2.txt
printf "ITERATION OLK0-639 START END\n">>$filename2.txt

i=0
#Start measurement
while [ $TEC_SENS_I -le 250 ];
	do
	caput det1:ao3 $(bc <<<"scale=2;$TEC_SENS_I/100")
	sleep $DELAY

	STARTPV=$(date)
	ITERATION=$(echo $i)

	printf "\n$ITERATION $STARTPV\n"

	caput det1.LOEN 0
	sleep $proc_dly
	OLK0=$(caget det1:ai0|awk '{print $2}')

	caput det1.LOEN 159
	sleep $proc_dly
	OLK159=$(caget det1:ai0|awk '{print $2}')

	caput det1.LOEN 319
	sleep $proc_dly
	OLK319=$(caget det1:ai0|awk '{print $2}')

	caput det1.LOEN 639
	sleep $proc_dly
	OLK639=$(caget det1:ai0|awk '{print $2}')

	AI1=$(caget det1:ai1|awk '{print $2}')
	AI2=$(caget det1:ai2|awk '{print $2}')
	AI3=$(caget det1:ai3|awk '{print $2}')
	AI4=$(caget det1:ai4|awk '{print $2}')
	AI5=$(caget det1:ai5|awk '{print $2}')
	AI6=$(caget det1:ai6|awk '{print $2}')
	AO3=$(caget det1:ao3|awk '{print $2}')
	AO5=$(caget det1:ao5|awk '{print $2}')

	ENDPV=$(date)
	printf  "$ITERATION $OLK0 $OLK159 $OLK319 $OLK479 $OLK639 $AI1 $AI2 $AI3 $AI4 $AI5 $AI6 $AO3 $AO5 $STARTPV $ENDPV \n">>$filename1.txt
	
#Get OLK	
	printf "$i " >>$filename2.txt
	printf "\nOLK 0-639\n"
	CHAN=0
	STARTOLK=$(date)
	while [ $CHAN -le 639 ]
		do
		caput det1.LOEN $CHAN
		sleep $proc_dly
		OLK=$(caget det1:ai0|awk '{print $2}')
		printf "$OLK " >> $filename2.txt
		CHAN=$(( $CHAN +1 ))
	done
     	ENDOLK=$(date)
        printf "$STARTOLK $ENDOLK\n" >> $filename2.txt
#Wait until next point

	i=$(( $i +1 ))
	TEC_SENS_I=$(($TEC_SENS_I+$TEC_STEP_I))
 
        printf "$ENDOLK\n"	
	
done
caput det1:ao3 $(bc <<<"scale=2;$TEC_SENS_FINAL/100") #Final sensor TEC current
caput det1:ao5 $(bc <<<"scale=2;$TEC_ASIC_FINAL/100") #Final ASIC TEC current
printf "TECs changed to final values. Waiting for temperature to stabilize for $DELAY sec\n"
sleep $DELAY
printf "END\n"
