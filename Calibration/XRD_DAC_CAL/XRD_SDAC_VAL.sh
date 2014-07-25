#!bash.sh
#XRD_SDAC_VAL: Validates SDAC calibrations yield the right readings
#9/9/2013
#####################################################################

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

	if [ "$1" != "" ]; then
		filename="$1_val"
		bash $1.sh
	else
		printf "Enter output filename: "
		read filename
	fi
	
	#set datalogger to single channel read
	echo "Setting up datalogger..."
	echo -e "ROUT:SCAN (@106)"|nc -C 192.168.11.122 7000

	#Buffer current threshold voltage settings
	bufVL0=$(caget det1.VL0|awk '{print $2}')
	bufVL1=$(caget det1.VL1|awk '{print $2}')
	bufVH1=$(caget det1.VH1|awk '{print $2}')
	bufVL2=$(caget det1.VL2|awk '{print $2}')
	bufVH2=$(caget det1.VH2|awk '{print $2}')
	
	printf "XRD $DETECTOR DAC CALIBRATION, $(date)\n">$filename.csv
	printf "DAC, ASIC, V1, V2\n">>$filename.csv
	i=0
	# Cycle through five DAC channels (0 to 4)
	while [ $i -le 4 ]
	do
		# Set first DAC output
		caput det1.SDA ${DAC[$i]}
		sleep 1
		ASIC=0
		# Cycle throught twenty ASICs (0 to 19)
		while [ $ASIC -le 19 ]
		do
			# Set first ASIC
			caput det1.MDAC $ASIC
			sleep 2
			Vset=1
			while [ $Vset -le 2 ]
			do
				caput det1.${DAC[$i]} $Vset
				sleep 2
				
				#if [ "$1" = "-a" ]; then
					if [ $Vset = 1 ]; then
						# All readings going through analog out has a gain of 2 and must be corrected when read automatically
						V1p="$(echo -e "READ?"|nc -C -q 1 192.168.11.122 7000|sed 's:\r::g'|sed 's:+::g')"
						V1=$(echo "scale=6; $V1p/$GAIN"|bc -q)
					else
						V2p="$(echo -e "READ?"|nc -C -q 1 192.168.11.122 7000|sed 's:\r::g'|sed 's:+::g')"
						V2=$(echo "scale=6; $V2p/$GAIN"|bc -q)
					fi
				# else
					# echo "Enter Voltage: "
					# if [ $Vset = 1 ]; then
						# read V1p
						# V1=$(echo "scale=6; $V1p/$GAIN"|bc -q)
					# else
						# read V2p
						# V2=$(echo "scale=6; $V2p/$GAIN"|bc -q)
					# fi
				# fi
				Vset=$(( $Vset + 1))
			done

			printf  "${DAC[$i]}, $ASIC, $V1, $V2\n">>$filename.csv
			ASIC=$(( $ASIC + 1 ))
		done
	i=$(( $i + 1))
	done
	
	echo "Reseting Analog Output & DAC"
	caput det1.MDAC 0
	caput det1.SDA None
	caput det1.VL0 $bufVL0
	caput det1.VL1 $bufVL1
	caput det1.VH1 $bufVH1
	caput det1.VL2 $bufVL2
	caput det1.VH2 $bufVH2
else
	echo "ERROR: Cannot communicate with detector, check 'caget' is functional and try again"
fi
