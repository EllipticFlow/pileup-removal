#!/bin/bash
### Y. Hu, 2023.04.17, macro to draw the 2D-Map before fitting

###check the existing of the data file
if [ ! -f all_parameters.txt ]; then
    echo "Date file not exist, will exit"
    exit
fi

orig_fitfile="all_parameters.txt"

file=$1
filerawname=${file%%.*}

xlab=$2
ylab=$3

right=$4
left=$5

#draw x and y range based on the data
xmax=`awk 'BEGIN{x=0}{if($3!=0&&$4!=0&&$1>x){x=$1}}END{print(x)}' ${file}`
ymax=`awk 'BEGIN{y=0}{if($3!=0&&$4!=0&&$2>y){y=$2}}END{print(y)}' ${file}`
awk '{if($3<'${ymax}' && $4<'${ymax}' && $5<'${ymax}'){print($0)}}' ${orig_fitfile} > all_par.txt
fitfile="all_par.txt"

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

#open symbol code
ptype1=10
ptype2=4
ptype3=8
ptype4=12
ptype5=6
ptype6=14
ptype7=16

#solid symbol code
ptypes1=11
ptypes2=5
ptypes3=9
ptypes4=13
ptypes5=7
ptypes6=15

gnuplot <<EOF	
set term png size 1600,1200 font "Helvetica, 20" fontscale 2.0
set output '${filerawname}_withfit.png'

set multiplot 

set title "double-NBD fit"


set lmargin at screen 0.18 
set rmargin at screen 0.8
set tmargin at screen 0.88
set bmargin at screen 0.18


unset key

set xlabel "${xlab}"
set ylabel "${ylab}" 

set xrange [ -1 : ${xmax} ] noreverse nowriteback
set yrange [ -1 : ${ymax} ] noreverse nowriteback

set pm3d map
set colorbox origin 0.1,0.1
set palette rgbformulae 33,13,10
set logscale zcb
set format cb "10^{%T}"


splot "${file}" u 1:2:3 w p pt 7 ps 0.08 lc rgb "#8A2BE2" notitle,\
      "${file}" u 1:2:3 w pm3d



### do the fitting
### pre-fitting
a0=1
b0=1
c0=1
a1=1
b1=1
c1=1

f(x)=a0+a1*x
g(x)=b0+b1*x
h(x)=c0+c1*x

fit f(x) "${fitfile}" u (((\$1)+(\$2))*0.5):(\$3) via a0,a1
fit g(x) "${fitfile}" u (((\$1)+(\$2))*0.5):(\$5) via b0,b1
fit h(x) "${fitfile}" u (((\$1)+(\$2))*0.5):(\$4) via c0,c1

bb2(x) = (0+10.0)/pi*(atan(x)+pi/2)-10.0
mode(x)=a0+a1*x+a2*x**2+a3*x**3+a4*x**4
high(x)=b0+b1*x+bb2(b2)*x**2+b3*x**3+b4*x**4
low(x)=c0+c1*x+c2*x**2+c3*x**3+c4*x**4
fit mode(x) "${fitfile}" u (((\$1)+(\$2))*0.5):(\$3) via a0,a1,a2,a3,a4
fit high(x) "${fitfile}" u (((\$1)+(\$2))*0.5):(\$5) via b0,b1,b2,b3,b4
fit low(x) "${fitfile}" u (((\$1)+(\$2))*0.5):(\$4) via c0,c1,c2,c3,c4

unset title

unset tics
unset xlabel
unset ylabel
set xrange [ -1 : ${xmax} ] noreverse nowriteback
set yrange [ -1 : ${ymax} ] noreverse nowriteback

set key at screen 0.78,0.32
set key font ",14"

plot "${fitfile}" u (((\$1)+(\$2))*0.5):3 w p pt ${ptype5} ps 3 lw 2 lc rgb '${myred}' notitle,\
     "${fitfile}" u (((\$1)+(\$2))*0.5):4 w p pt ${ptype2} ps 3 lw 2 lc rgb '${myorange}' notitle,\
     "${fitfile}" u (((\$1)+(\$2))*0.5):5 w p pt ${ptype3} ps 3 lw 2 lc rgb '${mygreen}' notitle,\
     mode(x) with l lw 4 lc rgb '${myred}' notitle,\
     low(x) with l lw 4 lc rgb '${myorange}' ti 'low-cut (${left}{/Symbol s})',\
     high(x) with l lw 4 lc rgb '${mygreen}' ti 'high-cut (${right}({/Symbol g}+1){/Symbol s})'



print "---------------------------------------------------"
print "---------------------------------------------------"
print "Mode: a0, a1, a2, a3, a4"
print a0, a1, a2, a3, a4
print "---------------------------------------------------"
print "---------------------------------------------------"
print "high-cut(green-color): b0, b1, b2, b3, b4"
print b0, b1, bb2(b2), b3, b4
print "---------------------------------------------------"
print "---------------------------------------------------"
print "low-cut(orange-color): c0, c1, c2, c3, c4"
print c0, c1, c2, c3, c4
print "---------------------------------------------------"
print "---------------------------------------------------"


EOF

mv ${fitfile} ${orig_fitfile}
