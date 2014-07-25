#!bash.sh
#XRD_LOG_PVS: Acquire all XRD monitoring channels and write to a textfile (Detector-year month day-hour min). Press ctrl+c to quit program. Use sh.
#7/30/2013
#9/10/2013: Changed LOEN title to OLK on line 18
#10/2/2013: Added an extra routine to save all OLK chanels to a file
#10/3/2013: Changed proc_dly to 2sec. It seems that OLK cannot be set and read faster than this


proc_dly=2 #Delay between caput and caget commands for OLK 

printf "Enter Detector number:\n"
read DETECTOR

printf "Enter acquisition time interval in seconds:\n"
read DELAY

caput det1.SHPT 4.0us
printf "Shaping time set to 4us\n"

caput det1.GAIN H
printf "Gain set to High\nStarting...\n"

caput det1:ao3 $(bc <<<"scale=2;220/100") #Set the sensor TEC current to 2.2A
caput det1:ao5 $(bc <<<"scale=2;170/100") #Setthe ASIC TEC current to 1.7A
printf "TECs changed to start values. Waiting for temperature to stabilize for $DELAY sec\n"
sleep $DELAY

filename1=`date "+XRD$DETECTOR-Log_PVs-%y%m%d-%H%M"`
filename2=`date "+XRD$DETECTOR-Log_OLK-%y%m%d-%H%M"`

#Create filenames
printf "XRD $DETECTOR\n">$filename1.txt
printf "ITERATION OLK0 OLK159 OLK319 OLK479 OLK639 AI1(Bias_V) AI2(RTD_Sensor) AI3(RTD_HOT) AI4(RTD_ASIC) AI5(CTRL_TEMP) AI6(Bias_I) AO3(Sensor_TEC) AO5(ASIC_TEC) START END\n">>$filename1.txt

printf "XRD $DETECTOR\n">$filename2.txt
printf "ITERATION OLK0-639 START END\n">>$filename2.txt

i=0
while [ 0 -le 1 ]
	do
#Get PVs
	STARTPV=$(date)
	ITERATION=$(echo $i)
	printf "$ITERATION $STARTPV\n"

	caput det1.LOEN 0
	sleep $proc_dly
	OLK0=$(caget det1:ai0|awk '{print $2}')

	caput det1.LOEN 159
	sleep $proc_dly
	OLK159=$(caget det1:ai0|awk '{print $2}')

	caput det1.LOEN 319
	sleep $proc_dly
	OLK319=$(caget det1:ai0|awk '{print $2}')

	caput det1.LOEN 479
	sleep $proc_dly
	OLK479=$(caget det1:ai0|awk '{print $2}')

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
	printf "$ENDOLK\n\n"
	i=$(( $i +1 ))
	sleep $DELAY
done
