#!/bin/bash

if [ -z "$1" ]
then
    printf "\e[31m ERROR: (Argument 1) No ROOT FILE supplied, will exit \n"
    printf "\e[39m "
    printf "\e[34m Try: bash run_pileup.sh FILENAME [e.g qahist.root] HISTNAME [e.g TOF_refMult] IMIN [e.g 5] IMAX [e.g 400] STEP [e.g 5]\n"
    printf "\e[39m "
    exit
else
    filename=$1
fi         


if [ -z "$2" ]
then
    printf "\e[31m ERROR: (Argument 2) No HISTNAME supplied, will exit \n"
    printf "\e[39m "
    printf "\e[34m Try: bash run_pileup.sh FILENAME [e.g qahist.root] HISTNAME [e.g TOF_refMult] IMIN [e.g 5] IMAX [e.g 400] STEP [e.g 5]\n"
    printf "\e[39m "
    exit
else
    histname=$2
fi


if [ -z "$3" ]
then
    printf "\e[31m ERROR: (Argument 3) No IMIN (low limit) supplied, will exit \n"
    printf "\e[39m "
    printf "\e[34m Try: bash run_pileup.sh FILENAME [e.g qahist.root] HISTNAME [e.g TOF_refMult] IMIN [e.g 5] IMAX [e.g 400] STEP [e.g 5]\n"
    printf "\e[39m "
    exit
else
    imin=$3    
fi         


if [ -z "$4" ]
then
    printf "\e[31m ERROR: (Argument 4) No IMAX (high limit) supplied, will exit \n"
    printf "\e[39m "
    printf "\e[34m Try: bash run_pileup.sh FILENAME [e.g qahist.root] HISTNAME [e.g TOF_refMult] IMIN [e.g 5] IMAX [e.g 400] STEP [e.g 5]\n"
    printf "\e[39m "
    exit
else
    imax=$4    
fi


if [ -z "$5" ]
then
    printf "\e[31m ERROR: (Argument 5) No STEP supplied, will exit \n"
    printf "\e[39m "
    printf "\e[34m Try: bash run_pileup.sh FILENAME [e.g qahist.root] HISTNAME [e.g TOF_refMult] IMIN [e.g 5] IMAX [e.g 400] STEP [e.g 5]\n"
    printf "\e[39m "
    exit
else
    step=$5
fi         


if [ -z "$6" ]; then
    printf "\e[35m No +N*(skewness+1)*sgima supplied, will use 3 as default \n"
    printf "\e[39m "
    right=3
else
    right=$6
fi         

if [ -z "$7" ]
then
    printf "\e[35m No -N*sgima supplied, will use 3.5 as default \n"
    printf "\e[39m "
    left=3
else
    left=$7
fi         

echo "-----------------------------------------------------------"
echo "------TOFMATCHED_VS_REFMULT PILE-UP REMOVAL PACKAGE--------"
echo "------------------ version 1 (LOCAL) ----------------------"
echo "-------------------P. Tribedy, Y. Hu ----------------------"
echo "---------------Last update on Apr 18, 2023-----------------"
echo "-----------------------------------------------------------"

##read the 2d file based on the input root file and histogram
root -l "read_2d.C("'"'"${filename}"'"'","'"'"${histname}"'"'")" -q 

##plot the 2d map without fitting
bash plot_2dmap.sh 2DMap_${histname}.txt nBTofMatch refMult 

##clean up the possible left over fitting files 
if [ -f "parameters*.txt" ]; then
  rm "parameters*.txt"
fi

##loop all the tofmatch bins
for ((lowbin=$imin; lowbin<$imax; lowbin+=step)); do
  highbin=$((lowbin+step))
  echo "$lowbin,$highbin"

  ##generate the slice of the x (lowbin, lowbin+step)
  root -l "slice_2d.C("'"'"${histname}"'"'","'"'"${filename}"'"'",$lowbin,$highbin)" -q 

  ##run the double negative binominal fit both signal
  bash nbdfit.sh $lowbin $highbin $right $left
done

##save all the fitted result into a file
cat parameters_*txt | sort -n | awk '{if($3>0 && $5>0 && $4<$3 && $3<$5){print($0)}}' > all_parameters.txt

##do the fitting and 2d plotting with a polynomial function
bash plot_2dmap_withfitting.sh 2DMap_${histname}.txt nBTofMatch refMult $right $left

exit;
