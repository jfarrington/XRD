#!bash.sh
#Verify the DAC calibration
#XRD_VERIFY_DAC.sh
#9/12/2013
#Descriptiom
#  Load the csv file output from XRD_SDAC_VAL.sh 
#  For each group of 20 rows, corresponding to ASICS 0-19
#  compute the (Max-Min)/Average.
#####################################################################

#  Any value above this is an error
THRESHOLD="0.5"
#

printf "Starting Script: $0\n"
#
# Get the latest .csv file as a guess
CSV_FILE=$(ls -t *.csv | head -1)

# Query User for file to analyze
printf "Enter file name ($CSV_FILE):"
read tFILE
if [ -n "$tFILE" ]; then
    CSV_FILE=$tFILE
fi

printf "Opening $CSV_FILE:\n"
let line=0
let aline=0
let counter=0
aves=(0 0)  # V1 and V2 averages
mins=(999 999)
maxs=(-999 -999)

while read p; do 

   let line++
   if [[ $line -ge 1 && $line -le 2 ]]; then 
      continue 
   fi
      
   if [[ $aline -eq 0 ]]; then
      aves=(0 0)  
      mins=(999 999)
      maxs=(-999 -999)
   fi
   
   textarray=$(echo $p | tr "," " ")    # split commas
   arr=($textarray)                     # convert to array of values
   
   # 2nd column is V1, 3rd column is V2
   aves[0]=$(echo "scale=5; ${aves[0]}+${arr[2]}" | bc -q 2>/dev/null)
   aves[1]=$(echo "scale=5; ${aves[1]}+${arr[3]}" | bc -q 2>/dev/null)
   if [[ $(echo "scale=5; ${mins[0]} > ${arr[2]}" | bc -q 2>/dev/null) -eq 1 ]]; then
      mins[0]=${arr[2]}
   fi
   if [[ $(echo "scale=5; ${maxs[0]} < ${arr[2]}" | bc -q 2>/dev/null) -eq 1 ]]; then
      maxs[0]=${arr[2]}
   fi

   if [[ $(echo "scale=5; ${mins[1]} > ${arr[3]}" | bc -q 2>/dev/null) -eq 1 ]]; then
      mins[1]=${arr[3]}
   fi
   if [[ $(echo "scale=5; ${maxs[1]} < ${arr[3]}" | bc -q 2>/dev/null) -eq 1 ]]; then
      maxs[1]=${arr[3]}
   fi
   
   #echo $aline $p
   
   if [[ $aline -eq 19 ]]; then
      aves[0]=$(echo "scale=5; ${aves[0]}/20" | bc -q 2>/dev/null)
      aves[1]=$(echo "scale=5; ${aves[1]}/20" | bc -q 2>/dev/null)
      
      delta[0]=$(echo "scale=5; 100 * (${maxs[0]} - ${mins[0]}) / ${aves[0]}" | bc -q 2>/dev/null)
      delta[1]=$(echo "scale=5; 100 * (${maxs[1]} - ${mins[1]}) / ${aves[1]}" | bc -q 2>/dev/null)
      #echo AVE1, AVE2 =${aves[0]} ${aves[1]} MIN=${mins[0]} MAX=${maxs[0]} delta1,2=${delta[0]} ${delta[1]}
      v1record[$counter]=${delta[0]}  
      v2record[$counter]=${delta[1]} 
      let counter++
   fi
   
   
   aline=$(((aline+1) % 20))
   
done < $CSV_FILE


#
# Print all the mx-mn/ave numbers here.
error=0
printf "V1 [Max-Min]/Ave     V2[Max-Min]/Ave\n"
nlen=$(( ${#v1record[@]} -1 ))
for i in  `seq 0 $nlen`
do

   if [[ $(echo "scale=5; ${v1record[$i]} > $THRESHOLD" | bc -q 2>/dev/null) -eq 1 ]]; then
      tput setaf 1  # RED
      error=1
   else
      tput setaf 7  # normal   
   fi
   
   printf "%10f        " ${v1record[$i]} 

   if [[ $(echo "scale=5; ${v2record[$i]} > $THRESHOLD" | bc -q 2>/dev/null) -eq 1 ]]; then
      tput setaf 1  # RED
      error=1
   else
      tput setaf 7  # normal   
   fi

   printf "  %10f\n"       ${v2record[$i]} 
done

tput setaf 7  # normal  
if [[ $error -eq 1 ]]; then
   printf  "DAC calibration is out of spec.\n\n"
   exit 1
fi

   
