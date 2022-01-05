//This is an auto generated macro//P.Tribedy/07_18_19_17_39_24
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
 void pileup(const char * histname, const char * inputfile, int minbin=10, int maxbin=10000){ 
	 char * tag = new char[100];
	 sprintf(tag,"%s",inputfile); 
	 TFile * f = new TFile(tag); 
	 sprintf(tag,"%s",histname); 
	 TH2D * myHist = (TH2D *)f->Get(tag); 
	 TH1D * HISTY = myHist->ProjectionY("py",minbin,maxbin);
	 HISTY->Rebin(1);
	 //HISTY->Scale(1./HISTY->Integral());

	 Double_t scale=HISTY->Integral();

	 fprintf(stdout,"## %s %s \n",HISTY->GetXaxis()->GetTitle(),HISTY->GetYaxis()->GetTitle());
	 fprintf(stdout,"# %g %g %g %g %g %g %g %f \n",1.*(HISTY->GetBinCenter(0))/1,1.*(HISTY->GetBinCenter(HISTY->FindLastBinAbove(1)))/1,1.*(HISTY->GetMinimum())/1,1.*(HISTY->GetMaximum())/1,HISTY->GetEntries(),HISTY->GetMean(1)/1,HISTY->GetIntegral(),HISTY->GetBinWidth(1));


	 for(int i=1;i<HISTY->GetNbinsX();i++){
		 if(HISTY->GetBinContent(i)>0)	fprintf(stdout,"%g %g %g \n",HISTY->GetBinCenter(i)/1,HISTY->GetBinContent(i)/scale,HISTY->GetBinError(i)/scale);
	 }

	 //	TCanvas * c = new TCanvas(); 
	 //	c->cd(); 
	 //	c->SetLogy(); 
	 //	myHist->Draw(); 
	 //	sprintf(tag,"%s.C",histname); 
	 //	c->SaveAs(tag); 
	 f->Close(); 
 } 

/*

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
   macro(histname_, inputfile_); 
   return 0; 
   } 

*/
