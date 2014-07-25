#!bash.sh
#PIX_OFF.sh: Disables a single pixel.
#J.Farrington 9/18/13
#Changes:
#7/22/15-Corrected pixel order

printf "Turn all pixels ON?(y/n)\n"

read sel

if [ "$sel" = "y" ];then
	./PIX_ALL_ON
	printf "All Pixels ON\n"

else
	printf "Pixel configuration unchanged\n"

fi

printf "Enter Pixel to deactivate (0 to 639)\n"
read pix

printf "caput -n -a det1.CHEN 640"> pix_off

i=0
while [ $i -lt 640 ]
do
	if [ 640 -lt $pix ];then
		echo "Error: pixel out of range"
		exit

	elif [ $i -eq $pix ];then
		printf " 1">> pix_off
	
	elif [ $i -ne $pix ];then
		printf " 0">> pix_off

	else
		echo "Error"
		exit
	fi
i=$(( $i +1 ))
done

printf "\n">> pix_off
chmod +x pix_off
./pix_off
rm pix_off
