#!bash.sh
#XRD_LOAD_TRIMS.sh
#9/17/2013
#Descriptiom
#  Load the file dacs.dat, parse it and send
# caput commands to head to set the ASIC trims.
#####################################################################

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
FILE="/opt/epics_dev/IOC/STRIP_DET/SYDOR_XRD_uC5282/SydorXRD_Start/Calibration/XRD_TRIMDAC_CAL/dacs.dat"
printf "Opening $FILE:\n"


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

echo caput -a det1.TR1 640 ${TR1[*]}
echo caput -a det1.TR2 640 ${TR2[*]}
echo caput -a det1.TR3 640 ${TR3[*]}
echo caput -a det1.TR4 640 ${TR4[*]}


