#!bash.sh
#XRD_SDAC_CAL: Calculate ASIC DAC calibration and write to a reusable script. Press ctrl+c to quit program
# Options -a use HP datalogger to read OAN signal connected to channel 106.
#    -a -c <n>  Calibrate only ASIC n, n is 0-19. -c must be the second option
#          and <n> must be third option!
#8/27/2013
#####################################################################
# Evaluate the slope and offset of the DAC based on voltage feedback.
function slope_eval()
{
    local stat=0
    local result=0.0
    if [[ $# -gt 0 ]]; then
        result=$(echo "scale=2; 682.66/($1-$2)" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}

function offset_eval()
{
    local stat=0
	local tmp=0.0
    local result=0.0
    if [[ $# -gt 0 ]]; then
		tmp=$(echo "scale=8; (2*$2)/($1-$2)" | bc -q 2>/dev/null)
		result=$(echo "scale=2; -341.33*($tmp-1)/1" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}

function check_det()
{
	tmp=$(caget det1)
	err=$?
	# err = 0 when det comm is okay, 1 otherwise
    echo $err
}

DAC=( VL0 VL1 VH1 VL2 VH2 )
GAIN=2
Vset=1
printf "Enter Detector number: "
read DETECTOR

if [ $(check_det) = 0 ]; then
		
	printf "Enter analog output gain (Default = 2): "
	read tGAIN
	if [ $tGAIN -ge 1 ]; then
		GAIN=$tGAIN
	fi
	
	filename=`date "+XRD_"$DETECTOR"_CAL-%y%m%d-%H%M"`

	if [ "$1" = "-a" ]; then
		#set datalogger to single channel read
		echo "Setting up datalogger..."
		echo -e "ROUT:SCAN (@106)"|nc -C 192.168.11.122 7000
	fi
	
	printf "XRD $DETECTOR DAC CALIBRATION, $(date)\n">$filename.csv
	printf "DAC, ASIC, V1, V2, SLOPE, OFFSET\n">>$filename.csv
	
	#Buffer current threshold voltage settings
	bufVL0=$(caget det1.VL0|awk '{print $2}')
	bufVL1=$(caget det1.VL1|awk '{print $2}')
	bufVH1=$(caget det1.VH1|awk '{print $2}')
	bufVL2=$(caget det1.VL2|awk '{print $2}')
	bufVH2=$(caget det1.VH2|awk '{print $2}')
	
	i=0
	# Cycle through five DAC channels (0 to 4)
	while [ $i -le 4 ]
	do
		m_array=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
		b_array=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
		# Set DAC slope and offset to default
		caput -a det1.${DAC[$i]}A 20 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33 341.33
		caput -a det1.${DAC[$i]}B 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
		sleep 1
		# Set first DAC output
		caput det1.SDA ${DAC[$i]}
		sleep 1
      if [[ $2 = -c && $3 -ge 0 && $3 -le 19 ]]; then
         ASIC=$3
         loopONCE=1
      else
         ASIC=0
         loopONCE=0
      fi
      
		
		# Cycle throught twenty ASICs (0 to 19)
		while [ $ASIC -le 19 ]
		do
			# Set first ASIC
			caput det1.MDAC $ASIC
			sleep 2
			Vset=1
			while [ $Vset -le 3 ]
			do
				caput det1.${DAC[$i]} $Vset
				sleep 2
				
				if [ "$1" = "-a" ]; then
					if [ $Vset = 1 ]; then
						# All readings going through analog out has a gain of 2 and must be corrected when read automatically
						V1p="$(echo -e "READ?"|nc -C -q 1 192.168.11.122 7000|sed 's:\r::g'|sed 's:+::g')"
						V1=$(echo "scale=6; $V1p/$GAIN"|bc -q)
					else
						V2p="$(echo -e "READ?"|nc -C -q 1 192.168.11.122 7000|sed 's:\r::g'|sed 's:+::g')"
						V2=$(echo "scale=6; $V2p/$GAIN"|bc -q)
					fi
				else
					echo "Enter Voltage: "
					if [ $Vset = 1 ]; then
						read V1p
						V1=$(echo "scale=6; $V1p/$GAIN"|bc -q)
					else
						read V2p
						V2=$(echo "scale=6; $V2p/$GAIN"|bc -q)
					fi
				fi
				Vset=$(( $Vset + 2))
			done

			new_m=$(slope_eval $V2 $V1)
			new_b=$(offset_eval $V2 $V1)

			printf  "${DAC[$i]}, $ASIC, $V1, $V2, $new_m, $new_b\n">>$filename.csv
			m_array[$ASIC]=$new_m
			b_array[$ASIC]=$new_b
         
         if [ $loopONCE = 1 ]; then
            break;
         else
            ASIC=$(( $ASIC + 1 ))
         fi   
		done   # while [ $ASIC -le 19 ]
      
      printf "caput -a det1.${DAC[$i]}A 20 ${m_array[*]}\n">>$filename.sh
      printf "caput -a det1.${DAC[$i]}B 20 ${b_array[*]}\n">>$filename.sh
      i=$(( $i + 1))
   
	done
	
   if [ $loopONCE = 1 ]; then
      exit 0;
   fi
   
	echo "Apply new calibration? [y/n]"
	read res
	if [ res = "y" ]; then
		bash $filename.sh
	fi
	
	echo "Reseting Analog Output & DAC"
	caput det1.MDAC 0
	caput det1.SDA None
	caput det1.VL0 $bufVL0
	caput det1.VL1 $bufVL1
	caput det1.VH1 $bufVH1
	caput det1.VL2 $bufVL2
	caput det1.VH2 $bufVH2
	
	#Run validation script
	echo "Validate new calibration? [y/n]"
	read res
	if [ res = "y" ]; then
		bash XRD_SDAC_VAL.sh $filename
	fi
else
	echo "ERROR: Cannot communicate with detector, check 'caget' is functional and try again"
fi
