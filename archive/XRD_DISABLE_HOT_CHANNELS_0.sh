#!bash.sh
#XRD_DISABLE_HOT_CHANNELS.sh
#9/17/2013
#Descriptiom
#  usage -t thershold
# all channels above the value t will be disabled (CHEN=1)
# 
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

printf "Enter XRD number: "
read DETECTOR
filename=`date "+XRD$DETECTOR-Pix_Config-%y%m%d-%H%M"`

declare -a S1
declare -a CHEN

#Enable all pixels
printf "\nEnabling all pixels\n\n"

h=0
k=639
while [ $h -le 639 ] 
do
   printf "${CHEN[$k]}"
   CHEN[$k]=0
   h=$(( $h + 1))
   k=$(($k - 1)) #Start from 639 and end on 0
done

PixEnableAll="caput -n -a det1.CHEN 640 ${CHEN[*]}"

#Execute 
$PixEnableAll 
printf "\nAll pixels Enabled\n\n"

printf "Enter maximum count cut-off threshold: "
read threshold

#if [[ $2 = -t && $3 -ge 0 ]]; then
#   threshold=$3
#else
#   threshold=1000
#fi   

printf "Using Threshold:$threshold\n" #Use medm readout to determine cutoff

# assume detector is setup with test pulses coming in
# Read S1
#s1=$(caget det1.S1)

S1=($(caget det1.S1)) # Read S1 and turn output into array. S1 format is "det1.S1 640 pix0 pix2 ...pix639"
#echo ${S1[@]}

# Start reading on 3rd element
i=2  
# The order of the pixels on lines 59 and 60 needs to be reversed so that the right pixels are turned off
j=639 

# Go up to last pixel: S1[641] (staring at 0)
while [ $i -le 641 ] 
do
   if [ ${S1[$i]} -gt $threshold ]; then
      CHEN[$j]=1
   else
      CHEN[$j]=0
   fi  
   i=$(( $i + 1))
   j=$(( $j - 1)) #Start from 639 and end on 0
done

PixConfig="caput -n -a det1.CHEN 640 ${CHEN[*]}"

#Execute 
$PixConfig 

#Save to file and create executable
printf "$PixConfig" > $filename.sh
#chmod +x $filename

printf "\nPixel configuration executed and saved to file\n"

