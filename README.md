### TofMatch-vs-refMult pile-up removel pacakge
### The idea is based on the old pileup removel package( Y. Hu & P. Tribedy), but basically this version rewrote everything
### LAST EDIT ON APR 18, 2023, By Y.Hu


#### Before you run
1. First get a ROOT FILE (e.g. qahist.root) which has 2D histogram (e.g. TOF_refMult) of tofmatched vs refMult, tofMatch as x-axis, refmult as y-axis
2. Make sure you have Gnuplot installed on your machine before you run

#### How to run this code
1. Run with the following input:
   bash run_pileup.sh <Rootfile> <HistName> <BinStart> <BinEnd> <Step> <high-sig-cut> <low-sig-cut>

e.g bash run_pileup.sh qahist.root tof_refmult 10 200 5 3 3.5

In the above example, the "qahist.root" is <Rootfile>; "tof_refmult" is <Histname>; the "10" is where start to do the slicing and fitting <BinStart>;  the "200" is where stop doing the slicing and fitting <BinEnd>; the "5" the slicing step; the "3" is the cut on higher edge; the "3.5" is the cuts on lower edge


###################################
Output of this package will be:
1. nbdfit_*_*.png
   The fitting result for that bin. e.g nbdfit_40_50.png is the plot for tofmatch bin 40~50
2. mbin_*_*.txt
   The data file for that bin. e.g nbdfit_40_50.png is the data file for tofmatch bin 40~50
3. parameters*.tx
   The fitting result for that bin, the numbers from left to right are: min-tofmatch-bin, max-tofmatch-bin, mode, low-cuts, high-cuts 
4. 2DMap_[histname].png
   The 2D plot without fitting
5. 2DMap_[histname].txt
   The data for the 2D map
6. 2DMap_*_withfitt.png
   The 2D plot with fitting, the final plot you should look at
7. all_parameters.txt
   All the parameters that used for the final polynomial fit, the numbers from left to right are: min-tofmatch-bin, max-tofmatch-bin, mode, low-cuts, high-cuts  

###################################
1. To clean us the files generated from this macro, run:
   bash cleanup.sh