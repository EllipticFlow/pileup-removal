/// Y. Hu, 2023.04.17, macro to generate the 2D-Map data file
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
void read_2d(const char * inputfile, const char * histname){ 
  char * filename = new char[100]; 
  sprintf(filename,"%s",inputfile); 
  TFile * f = new TFile(filename); 
  sprintf(filename,"%s",histname); 
  TH2F * myHist = (TH2F *)f->Get(filename); 
  myHist->RebinX(1);
  myHist->RebinY(1);
  TH1D * HISTX = myHist->ProjectionX();
  TH1D * HISTY = myHist->ProjectionY();

  sprintf(filename,"2DMap_%s.txt",histname); 
  FILE *out_file = fopen(filename, "w");


  for(int i=1;i<HISTX->GetNbinsX();i++){
    for(int j=1;j<HISTY->GetNbinsX();j++){
	fprintf(out_file,"%g %g %g %g \n",HISTX->GetBinCenter(i)/1,HISTY->GetBinCenter(j)/1,myHist->GetBinContent(myHist->GetBin(i,j)),myHist->GetBinError(myHist->GetBin(i,j)));
    }
    fprintf(out_file,"\n");
  }
  f->Close();
} 
