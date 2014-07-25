#!bash.sh
#XRD_RESET_ASIC_TRIMS: 
#9/10/2013
#####################################################################


function check_det()
{
	tmp=$(caget det1)
	err=$?
	# err = 0 when det comm is okay, 1 otherwise
    echo $err
}

DAC=( TR1 TR2 TR3 TR4 )
#printf "Enter Detector number: "
#read DETECTOR

if [ $(check_det) != 0 ]; then
   echo "ERROR: Cannot communicate with detector, check 'caget' is functional and try again"
   exit 1
fi


printf "Enter reset value (Default = 32): "
read tRVAL
if [ $tRVAL -ge 0 ]; then
   RVAL=$tRVAL
else
   RVAL=32   
fi

for i in {1..640}
do
   m_array[$i]=$RVAL
done	
	
	
i=0
# Cycle through five DAC channels (0 to 4)
while [ $i -le 3 ]
do
   # Set DAC slope and offset to default
   caput -a det1.${DAC[$i]} 640 ${m_array[*]}
   
   sleep 1
   i=$(( $i + 1))
done
	
