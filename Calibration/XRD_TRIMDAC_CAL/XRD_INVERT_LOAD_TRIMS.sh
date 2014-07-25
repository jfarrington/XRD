#!bash.sh
#XRD_INVERT_LOAD_DACTRIMS.sh: Inverts dac.dat array, loads into XRD and saves configuration file.

cat dacs.dat|awk '{print $1" "}'>A
tac dacs.dat|awk '{print $2" "$3" "$4" "$5}'>B
paste -d" " A B > C

function check_det()
{
	tmp=$(caget det1)
	err=$?
	# err = 0 when det comm is okay, 1 otherwise
    echo $err
}

printf "Starting Script: $0\n"

if [ $(check_det) != 0 ]; then
   echo "ERROR: Cannot communicate with detector, check 'caget' is functional and try again"
   exit 1
fi


#
FILE="/opt/epics_dev/IOC/STRIP_DET/SYDOR_XRD_uC5282/SydorXRD_Start/Calibration/XRD_TRIMDAC_CAL/C"
#printf "Opening $FILE:\n"

printf "Enter XRD number: "
read DETECTOR
filename=`date "+XRD$DETECTOR-TrimDAC_Config-%y%m%d-%H%M"`

let aline=0

declare -a TR1
declare -a TR2
declare -a TR3
declare -a TR4

while read -a p; do 

   #echo length of p is ${#p[@]}
   TR1[$aline]=${p[1]}
   TR2[$aline]=${p[2]}
   TR3[$aline]=${p[3]}
   TR4[$aline]=${p[4]}
   
   aline=$((aline+1))
   
done < $FILE

printf "caput -a det1.TR1 640 ${TR1[*]}\n">$filename.sh
printf "caput -a det1.TR2 640 ${TR2[*]}\n">>$filename.sh
printf "caput -a det1.TR3 640 ${TR3[*]}\n">>$filename.sh
printf "caput -a det1.TR4 640 ${TR4[*]}">>$filename.sh
bash $filename.sh
rm A B C

