//This is an auto generated macro//P.Tribedy/03_31_20_20_51_40
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
void read_tof_ref(const char * histname, const char * inputfile){ 
  char * tag = new char[100]; 
  sprintf(tag,"%s",inputfile); 
  TFile * f = new TFile(tag); 
  sprintf(tag,"%s",histname); 
  TH2D * myHist = (TH2D *)f->Get(tag); 
  myHist->RebinX(1);
  myHist->RebinY(1);
  TH1D * HISTX = myHist->ProjectionX();
  TH1D * HISTY = myHist->ProjectionY();
  fprintf(stdout,"## %s %s \n",HISTX->GetXaxis()->GetTitle(),HISTY->GetXaxis()->GetTitle());
  fprintf(stdout,"# %g %g %g %g %g %g %g \n",1.*(HISTX->GetXaxis()->GetXmin())/1,1.*(HISTX->GetXaxis()->GetXmax())/1,1.*(HISTY->GetXaxis()->GetXmin())/1,1.*(HISTY->GetXaxis()->GetXmax()/1),myHist->GetEntries(),myHist->GetMean(1)/1,myHist->GetMean(2)/1);
  for(int i=1;i<HISTX->GetNbinsX();i++){
    for(int j=1;j<HISTY->GetNbinsX();j++){
      fprintf(stdout,"%g %g %g %g \n",HISTX->GetBinCenter(i)/1,HISTY->GetBinCenter(j)/1,myHist->GetBinContent(myHist->GetBin(i,j)),myHist->GetBinError(myHist->GetBin(i,j)));
    }
    fprintf(stdout,"\n");
  }
  TCanvas * c = new TCanvas(); 
  c->cd(); 
  c->SetLogz(); 
  myHist->Draw("colz"); 
  sprintf(tag,"%s.C",histname); 
  c->SaveAs(tag); 
  f->Close(); 
} 
  
  
int main (int inpc, char * inpv[]) 
{ 
  string inputfile__; 
  string histname__; 
  for(int i=0; i<inpc; i++) 
    { 
      if(!strcmp(inpv[i],"-h")) histname__=(inpv[i+1]); 
      if(!strcmp(inpv[i],"-f")) inputfile__=(inpv[i+1]); 
    } 
  const char * inputfile_=inputfile__.c_str(); 
  const char * histname_=histname__.c_str(); 
  read_tof_ref(histname_, inputfile_); 
  return 0; 
} 
