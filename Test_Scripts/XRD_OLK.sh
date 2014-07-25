#!bash.sh
#XRD_OLK: Record OLK for each channel
#9/17/2013
#####################################################################
# Evaluate the slope and offset of the DAC based on voltage feedback.

function check_det()
{
	tmp=$(caget det1)
	err=$?
	# err = 0 when det comm is okay, 1 otherwise
    echo $err
}

if [ $(check_det) != 0 ]; then
   echo "ERROR: Cannot communicate with detector, check 'caget' is functional and try again"
   exit 1
fi

printf "Enter Detector number: "
read DETECTOR

filename=`date "+XRD_"$DETECTOR"_OLK-%y%m%d-%H%M"`
printf "Writing to file $filename\n"
		
printf "XRD $DETECTOR OLK, $(date)\n">$filename.csv

TEC1=$(caget det1:ao3|awk '{print $2}')
BIAS=$(caget det1:ao4|awk '{print $2}')
TEC2=$(caget det1:ao5|awk '{print $2}')
printf "TEC1, TEC2, BIAS,$TEC1,$TEC2,$BIAS\n">>$filename.csv

# Column headers
printf "CHAN, OLK1, OLK2, OLK3\n">>$filename.csv
printf "CHAN, OLK1, OLK2, OLK3\n"
	
ch=0

#scan through all channels, and record OLK
while [ $ch -le 639 ]
do
   # Set OLK channel output
	caput det1.LOEN $ch
	sleep 1
   OLK1=$(caget det1:ai0|awk '{print $2}')
   OLK2=$(caget det1:ai0|awk '{print $2}')
   OLK3=$(caget det1:ai0|awk '{print $2}')
   printf "$ch,$OLK1, $OLK2, $OLK3\n">>$filename.csv
   printf "$ch,$OLK1, $OLK2, $OLK3\n"
	ch=$(( $ch + 1))
done	
