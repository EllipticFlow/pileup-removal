#!/bin/bash
### Y. Hu, 2023.04.17, macro to draw the 2D-Map before fitting

file=$1
filerawname=${file%%.*}

xlab=$2
ylab=$3

#draw x and y range based on the data
xmax=`awk 'BEGIN{x=0}{if($3!=0&&$4!=0&&$1>x){x=$1}}END{print(x)}' ${file}`
ymax=`awk 'BEGIN{y=0}{if($3!=0&&$4!=0&&$2>y){y=$2}}END{print(y)}' ${file}`


gnuplot <<EOF	
set term png size 1600,1200 font "Helvetica, 20" fontscale 2.0
set output '${filerawname}.png'

set key fixed right bottom vertical Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid

unset key

set xlabel "${xlab}"
set ylabel "${ylab}" 

set xrange [ * : ${xmax} ] noreverse nowriteback
set yrange [ * : ${ymax} ] noreverse nowriteback


set pm3d map
set colorbox origin 0.1,0.1
set palette rgbformulae 33,13,10
set logscale zcb
#set format cb "%.1e"
set format cb "10^{%T}"


set lmargin at screen 0.18 
set rmargin at screen 0.8
set tmargin at screen 0.88
set bmargin at screen 0.18


splot "${file}" u 1:2:3 w p pt 7 ps 0.08 lc rgb "#8A2BE2" notitle,\
      "${file}" u 1:2:3 w pm3d 


EOF
