#!bash.sh
#XRD_NOISE: Measure RMS noise on OAN  on discrete channels
#9/17/2013
# USes external data logger. Set channel 106 to AC, 100mv scale
#####################################################################
# Evaluate the slope and offset of the DAC based on voltage feedback.

function check_det()
{
	tmp=$(caget det1)
	err=$?
	# err = 0 when det comm is okay, 1 otherwise
    echo $err
}

# Enter list of channels to scan
CHANS=( 0 1 320 638 639 )

if [ $(check_det) != 0 ]; then
   echo "ERROR: Cannot communicate with detector, check 'caget' is functional and try again"
   exit 1
fi

printf "Enter Detector number: "
read DETECTOR

filename=`date "+XRD_"$DETECTOR"_NOISE-%y%m%d-%H%M"`
printf "Writing to file $filename\n"

#if [ "$1" = "-a" ]; then
   #set datalogger to single channel read
   echo "Setting up datalogger..."
   echo -e "CONF:VOLT:AC 0.1,1E-5, (@106)"|nc -C 192.168.11.122 7000
   echo -e "ROUT:SCAN (@106)"|nc -C 192.168.11.122 7000
#fi
	
printf "XRD $DETECTOR NOISE SCAN, $(date)\n">$filename.csv
TEC1=$(caget det1:ao3|awk '{print $2}')
BIAS=$(caget det1:ao4|awk '{print $2}')
TEC2=$(caget det1:ao5|awk '{print $2}')

printf "TEC1, TEC2, BIAS,$TEC1,$TEC2,$BIAS\n">>$filename.csv
printf "Channel, Noise1, Noise2, Noise3\n">>$filename.csv
printf "Channel, Noise1, Noise2, Noise3\n"

#Set output to Analog output
caput det1.SDA 0
	
i=0
# Cycle through all channels 
while [ $i -lt ${#CHANS[@]} ]
do
   # Set channel on OAN
   caput det1.AOEN ${CHANS[$i]}
	sleep 1

   printf  "Channel ${CHANS[$i]}:"
   printf  "${CHANS[$i]}">>$filename.csv
   CYCLE=0
   # Cycle throught twenty ASICs (0 to 19)
   while [ $CYCLE -le 2 ]
   do
      # Wait **2 seconds** for response. Slower on AC mode.
      noise="$(echo -e "READ?"|nc -C -q 3 192.168.11.122 7000|sed 's:\r::g'|sed 's:+::g')"
      printf ",$noise">>$filename.csv
      printf ",$noise"
      CYCLE=$(( $CYCLE + 1 ))
   done
   printf "\n">>$filename.csv
   printf "\n"
	i=$(( $i + 1))

done
	
