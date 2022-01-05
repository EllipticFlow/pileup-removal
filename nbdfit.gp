#!/bin/bash
#This script will do the production for the nbTOFMatch_refMult.


#root -l 'pileup.C("TOF_refMult","prith_qahist.root",'$1','$2')' >mbin_$1_$2 -q
if [ ! -f "mbin_$1_$2" ]; then
    echo "Date file not exist, will exit"
    exit
fi
#seperate into 2 part to prefit the peak and tail
awk 'NR>3&& $2>1e-6{print $0}' mbin_$1_$2 >"temp_data"
#awk 'NR>3{print $0}' mbin_$1_$2 >"temp_data2"
awk 'NR>3 && $2>5e-5{print $0}' mbin_$1_$2 >"temp_data2"
awk 'NR>3 && $2<1e-5{print $0}' mbin_$1_$2 >"temp_data3"

if [ -z '$4' ]; then
    right=3
else
    right=$4
fi

if [ -z '$5' ]; then
    left=3.5
else
    left=$5
fi

if [ -f "nbdfit_$1_$2.eps" ]; then
    echo "Will help you remove the old nbdfit_${1}_${2}.eps"
    rm nbdfit_$1_$2.eps
fi


gnuplot <<EOF	


set terminal postscript eps enhanced defaultplex \
   leveldefault color colortext \
   dashlength 1.0 linewidth 1.0 butt noclip \
   nobackground \
   palfuncparam 2000,0.003 \
   size 4.50in, 3.00in "Helvetica" 20  fontscale 1.0 
 set output 'nbdfit_$1_$2.eps'

set key fixed right bottom vertical Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid

unset key
set title "negative binomial fit for nBTOFMatch-refMult $1-$2" 
set xlabel "RefMult" 
set ylabel "P(N)" 

set xrange [ -1.00000 : 500 ] noreverse nowriteback
set yrange [ 1e-6 : 0.2 ] noreverse nowriteback

set logscale y
set format y "10^{%L}"
#set format y "%e"

#initial parameter setup
    p1 = ($1+$2)*0.5*0.001+0.66+$3*0.017
    r1 = p1/(1-p1)*($1+$2)*0.5
    p2 = 0.00003*($1+$2)*0.5+0.12+$3*0.001
    r2 = (($1+$2)*0.5/3+100)*p2/(1-p2)
    a1 = 0.001

    
    if (p1 > 1.){
    p1 = 0.999
    }
    if (p2 > 1.){
    p1 = 0.999
    }

    print "-------------------","Generated Parameters","----------------------"
    print "-------------------", r1, p1, r2, p2, "----------------------"

    negbin1(x)=exp(lgamma(r1+x)-lgamma(r1)-lgamma(x+1)+r1*log(p1)+x*log(1.0-p1))
    negbin2(x)=a1*exp(lgamma(r2+x)-lgamma(r2)-lgamma(x+1)+r2*log(p2)+x*log(1.0-p2))
    negbin(x)=negbin1(x)+negbin2(x)

    #Guasian fit function for cross check, disable now
    #	 gausian(x)=b0/(2.*3.14159*b1*b1)**0.5*exp(-1./2./b1/b1*(x-b2)**2)
    #	 b0=1
    #	 b1=5
    #	 b2=195


    fit negbin1(x) "temp_data2" u 1:2 via r1,p1
    fit negbin2(x) "temp_data3" u 1:2 via r2,p2,a1
    fit negbin(x) "temp_data" u 1:2:3 via r1,p1,r2,p2,a1


set bar 0
set key default

x=1
mean1=(r1*(1-p1)/p1)
skewness1=((2-p1)/((r1*(1-p1))**0.5))**0.33333333
sigma1=(r1*(1-p1)/(p1*p1))**0.5
mode1=(r1-1)*(1-p1)/p1
SG(x)=(skewness1+1)*sigma1*${right}+mode1
S_G(x)=-sigma1*${left}+mode1


print " "
print " "
print " skewness = ", skewness1
print " sigma = ", sigma1
print " mode = ", mode1
print " "
print " Cut_right = ", SG(x)
print " Cut_left = ", S_G(x)
print " "
print " "

plot "temp_data" u 1:2:3 w e pt 6 ps 1.2 lw 1 lc 8 ti 'data', "temp_data" u 1:(negbin(\$1)) with histep lw 3 lc 7 ti 'NBD-fit',"temp_data" u ((r1-1)*(1-p1)/p1):2 w l lw 2 lc 4 ti "Mode","temp_data" u (SG($1)):2 w l lw 2 lc 6 ti "${right} Sigma+skewness right", "temp_data" u (S_G($1)):2 w l lw 2 lc 3 ti "${left} Sigma left"  



set print "parameters_$1_$2.dat"

print $1,$2,r1,r1_err,p1,p1_err,r2,r2_err,p2,p2_err,a1,mode1,SG(x),S_G(x)

EOF



#mean
#6.62420663566526 0.697314464793193 0.00131492844236247 -2.14114782534114e-06
#sigma
#4.87685195469143 1.54807417296194 -0.00134709035852156 -2.74180300016013e-07
#mean                                                                                                    
#6.62420663566526+0.697314464793193*$1+0.00131492844236247*$1**2-2.14114782534114e-06*$1**3                            
#sigma                                                                                                   
#4.87685195469143+1.54807417296194*$1-0.00134709035852156*$1**2-2.74180300016013e-07*$1**3    
