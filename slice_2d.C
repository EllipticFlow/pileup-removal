/// Y. Hu, 2023.04.17, macro to generate a slice of 2D-Map data file (slice on x, project to y)
#include <stdio.h> 
#include <string.h> 
#include <stdlib.h> 
  
#include "TFile.h" 
#include "TH1.h" 
#include "TH2.h" 
#include "TProfile.h" 
#include "TProfile2D.h" 
#include "TCanvas.h" 
#include "TMath.h" 
  
using namespace std; 
void slice_2d(const char * histname, const char * inputfile, int minbin=10, int maxbin=10000){ 
  char * filename = new char[100];
  sprintf(filename,"%s",inputfile); 
  TFile * f = new TFile(filename); 
  sprintf(filename,"%s",histname); 

  TH2D * myHist = (TH2D *)f->Get(filename); 
  TH1D * HISTY = myHist->ProjectionY("py",minbin,maxbin);
  HISTY->Rebin(1);

  Double_t scale=HISTY->Integral();

  sprintf(filename,"mbin_%d_%d.txt",minbin,maxbin); 
  FILE *out_file = fopen(filename, "w");
  
  for(int i=1;i<HISTY->GetNbinsX();i++){
    if(HISTY->GetBinContent(i)>0){
      fprintf(out_file,"%g %g %g \n",HISTY->GetBinCenter(i)/1,HISTY->GetBinContent(i)/scale,HISTY->GetBinError(i)/scale);
    }
  }
  f->Close(); 
} 
