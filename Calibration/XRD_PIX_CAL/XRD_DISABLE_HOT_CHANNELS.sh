#!bash.sh
#XRD_DISABLE_HOT_CHANNELS.sh
#9/17/2013
#Description: 
#  All channels with intensity above a selected threshold will be 
#  disabled (CHEN=1)
#
#Changes:
#  7/18/14 JF- Fixed pixel order
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
   echo "ERROR: Cannot communicate with detector, check 'caget' is 
	functional and try again"
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
while [ $h -le 639 ] 
do
   printf "${CHEN[$h]}"
   CHEN[$h]=0
   h=$(( $h + 1))
done

PixEnableAll="caput -n -a det1.CHEN 640 ${CHEN[*]}"

#Executeenabling all pixels
$PixEnableAll 

printf "\nAll pixels Enabled\n\n"
printf "Please set 'Gain' to High and 'Shaping time' to 4us.\n\n"
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
S1=($(caget det1.S1)) # Read S1 and turn output into array. S1 format is "det1.S1 640 pix0 pix1...pix639"
echo ${S1[@]}

# 'i' is S1 array element. Start reading on 3rd element of S1 array (S1 format is "det1.S1 640 pix0 pix1...pix639)
i=2  

# 'j' is pixel number. Start writing ON/OFF from pix0
j=0

# Read pixel value and compare with threshold. Deactivate pixel if pixel is above threshold. 

while [ $i -le 641 ] 
do
   if [ ${S1[$i]} -gt $threshold ]; then
      CHEN[$j]=1
      echo "Hot"
   else
      CHEN[$j]=0
   fi  
   i=$(( $i + 1))
   j=$(( $j + 1))
done

PixConfig="caput -n -a det1.CHEN 640 ${CHEN[*]}"

#Execute 
$PixConfig 

#Save to file and create executable
printf "$PixConfig" > $filename.sh
#chmod +x $filename

printf "\nPixel configuration executed and saved to file\n"
