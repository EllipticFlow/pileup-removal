#!/bin/bash

lowlimit=$2
highlimit=$1

gnuplot <<EOF	

set terminal postscript eps enhanced defaultplex \
   leveldefault color colortext \
   dashlength 1.0 linewidth 1.0 butt noclip \
   nobackground \
   palfuncparam 2000,0.003 \
   size 4.00in, 3.00in "Helvetica" 20  fontscale 1.0 
set output 'nbdfit_allrange.eps'

set key fixed right bottom vertical Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid

unset key

set title "TOFMatch-RefMult by NBD fit for all range" 
set xlabel "nBTOFMatch" 
set ylabel "RefMult" 

set xrange [ -1.00000 : 550 ] noreverse nowriteback
set yrange [ -1.0 : 600 ] noreverse nowriteback

#set logscale y

set pm3d map
set colorbox origin 0.1,0.1
set palette rgbformulae 33,13,10
set logscale zcb
#set format cb "%.1e"
set format cb "10^{%T}"


set lmargin at screen 0.15 
set rmargin at screen 0.8


mode(r,p)=(r-1)*(1-p)/p
sigma(r,p)=(r*(1-p)/(p*p))**0.5
skewness(r,p)=((2-p)/((r*(1-p))**0.5))**0.33333333
SG(r,p)=(skewness(r,p)+1)*sigma(r,p)*${highlimit}+mode(r,p)
S_G(r,p)=-sigma(r,p)*${lowlimit}+mode(r,p)

set bar 0



mode1(x)=a0+a1*x+a2*x**2+a3*x**3+a4*x**4
high(x)=b0+b1*x+b2*x**2+b3*x**3+b4*x**4
low(x)=c0+c1*x+c2*x**2+c3*x**3+c4*x**4

fit mode1(x) "parameters_allrange" u ((\$1)*0.5+(\$2)*0.5):(mode((\$3),(\$5))) via a0,a1,a2,a3,a4
fit high(x) "parameters_allrange" u ((\$1)*0.5+(\$2)*0.5):(SG((\$3),(\$5))) via b0,b1,b2,b3,b4
fit low(x) "parameters_allrange" u ((\$1)*0.5+(\$2)*0.5):(S_G((\$3),(\$5))) via c0,c1,c2,c3,c4



splot "Tof_refmult.txt" u 1:2:3 w p pt 7 ps 0.08 lc rgb "#8A2BE2" notitle, "Tof_refmult.txt" u 1:2:3 w pm3d ti 'Tof-RefMult 27gev',"parameters_allrange" u ((\$1)*0.5+(\$2)*0.5):((\$3-1.)*(1.-(\$5))/(\$5)):(25000) w l lc 8 lw 4 ti 'Mode by NBD fit',"parameters_allrange" u ((\$1)*0.5+(\$2)*0.5):(SG(\$3,\$5)):(25000) w l lc 8 lw 4 ti 'Cut',"parameters_allrange" u ((\$1)*0.5+(\$2)*0.5):(S_G(\$3,\$5)):(25000) w l lc 8 lw 4 notitle,"Xaxis" u (\$1):(mode1(\$1)):(25000) w l lc 7 lw 2 notitle, "Xaxis" u (\$1):(high(\$1)):(25000) w l lc 7 lw 2 notitle, "Xaxis" u (\$1):(low(\$1)):(25000) w l lc 7 lw 2 notitle

print "---------------------------------------------------"
print "---------------------------------------------------"
print "double a0=", a0, ", a1=", a1, ", a2=", a2, ", a3=", a3, ", a4=", a4, ";"
print "double b0=", b0, ", b1=", b1, ", b2=", b2, ", b3=", b3, ", b4=", b4, ";"
print "double c0=", c0, ", c1=", c1, ", c2=", c2, ", c3=", c3, ", c4=", c4, ";"
print "---------------------------------------------------"
print "---------------------------------------------------"

save "nbdfit_allrange.gnu"


EOF

#convert -density 500 "nbdfit_allrange.eps" -quality 100 "nbdfit_allrange.jpg"                
