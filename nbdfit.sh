#!/bin/bash
###This script will do the fitting and plotting for the refMult distribution on one tofmatch slice. Y. Hu, 2023.04.18

orig_file=mbin_$1_$2.txt

right=$3 ### mode+(skew+1)*sigma*${right}
left=$4  ### mode-sigma*${left}

###color base suggested by ChatGPT
myblue='#1f77b4'
myorange='#ff7f0e'
mygreen='#2ca02c'
myred='#d62728'
mypurple='#9467bd'
mypink='#e377c2'
mygray='#7f7f7f'
myyellow='#bcbd22'
myteal='#17becf'
mybrown='#8c564b'

###check the existing of the data file
if [ ! -f $orig_file ]; then
    echo "Date file not exist, will exit"
    exit
fi


##load the max point, half width as the initial fitting parameters
initial_mean=`awk 'BEGIN{peak=0} {if($2>peak){peak=$2; x=$1}} END{print(x)}' ${orig_file}`  ### the peak location 
half_max=`awk 'BEGIN{peak=0} {if($2>peak){peak=$2}} END{print(peak/2.)}' ${orig_file}` ### half height of the peak
min_xfwhm=`awk '{if($2>'${half_max}'){print($0)}}' ${orig_file} | awk 'NR==1{print($1)}'` ### min bin when it cross the half height of the peak
max_xfwhm=`awk '{if($2>'${half_max}'){print($0)}}' ${orig_file} | awk 'END{print($1)}'` ### max bin when it cross the half height of the peak
initial_sigma=$(echo "(${max_xfwhm}-${min_xfwhm})/2.355" | bc -l) ### sigma~FWHM/2.355


### prepare the data file for fitting
awk '{if($2>'${half_max}'/200.){print($0)}}' ${orig_file} > temp_sig  ###peak/400 as the signal trigger
awk '{if($2<'${half_max}'/275. && $2>1e-6){print($0)}}' ${orig_file} > temp_bg ### peak/550 as the background trigger
awk '{if($2>1e-6){print($0)}}' ${orig_file} > temp_all ### everything above 1e-6 saved for sig+back fit


gnuplot <<EOF	
set term png size 1600,1200 font "Helvetica, 20" fontscale 2.0
set output 'nbdfit_$1_$2.png'

set key fixed right bottom vertical Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid

unset key
set title "double-NBD fit for refMult ($1-$2)" 
set xlabel "RefMult" 
set ylabel "P(N)" 

set xrange [ -1.00000 : * ] noreverse nowriteback
set yrange [ 1e-6 : ${half_max}*10 ] noreverse nowriteback

set logscale y
set format y "10^{%L}"

##################### fitting part
#initial parameter setup
### based on the peak and sigma
p1=${initial_mean}/(${initial_sigma}*${initial_sigma})
r1=${initial_mean}*p1/(1-p1)

### based on the background peak usually as twice larger as the signal peak
p2=${initial_mean}/(${initial_sigma}*${initial_sigma}*4)
r2=${initial_mean}*p2/(1-p2)
a1 = 0.001

# print "-------------------","Generated Parameters","----------------------"
# print "-------------------", r1, p1, r2, p2, "----------------------"

nbd1(x)=exp(lgamma(r1+x)-lgamma(r1)-lgamma(x+1)+r1*log(p1)+x*log(1.0-p1))
nbd2(x)=a1*exp(lgamma(r2+x)-lgamma(r2)-lgamma(x+1)+r2*log(p2)+x*log(1.0-p2))
nbd(x)=nbd1(x)+nbd2(x)

fit nbd1(x) "temp_sig" u 1:2 via r1,p1
fit nbd2(x) "temp_bg" u 1:2 via r2,p2,a1
fit nbd(x) "temp_all" u 1:2:3 via r1,p1,r2,p2,a1


mean=(r1*(1-p1)/p1)
skew=((2-p1)/((r1*(1-p1))**0.5))**0.33333333
sigma=(r1*(1-p1)/(p1*p1))**0.5
mode=(r1-1)*(1-p1)/p1

right_cut=(skew+1)*sigma*${right}+mode
left_cut=-sigma*${left}+mode


######################## Plotting
labelx=0.65
labely=0.65
### Mode
set arrow from mode,1e-6 to mode,(${half_max}*10) lc rgb '${myblue}' nohead linewidth 3
set label at screen labelx,labely 'Mode' textcolor rgb '${myblue}'
### Left_cut
set arrow from left_cut,1e-6 to left_cut,(${half_max}*10) lc rgb '${myorange}' nohead  linewidth 3
set label at screen labelx,labely-0.05 'Left-cut (${left}{/Symbol s})' textcolor rgb '${myorange}'
###
set arrow from right_cut,1e-6 to right_cut,(${half_max}*10) lc rgb '${mygreen}' nohead  linewidth 3
set label at screen labelx,labely-0.1 'Right-cut (${right}({/Symbol g}+1){/Symbol s})' textcolor rgb '${mygreen}'

set bar 0
set key default
set key at screen 0.85,0.8

plot "${orig_file}" u 1:2:3 w e pt 6 ps 2 lw 1 lc 8 ti 'data',\
     nbd(x) w l lw 3 lc 7 ti 'fit'     


set print "parameters_$1_$2.txt"

print $1, $2, mode, left_cut, right_cut


EOF


rm temp_sig temp_bg temp_all

exit;
