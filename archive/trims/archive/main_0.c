#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

extern void FitGraceinit();
extern void ScanGraceinit();
extern int makex();
extern void count();
extern void scan_levels();
extern void fitall();
extern void fit_plot();
extern double peval();
extern double residuals();
extern int fit();
extern void Correct();
extern int ResetTrims();
extern void Restore_dacs();
extern void exit();
extern int Enable_all();
extern int Disable_outliers();


#define HIDAC1 det1:ao2
#define HIDAC2 det1:ao4
#define LODAC1 det1:ao1
#define LODAC2 det1:ao3


int NCH; /* default value. Real value got from device later. */

int NPOINTS;                                                                         
float STEP;                                                                        
int NPLT; 

double upcen=2.00, lowcen=1.00, upres=50.0, lowres=0.0;                                                                          
extern int data[4][640][64]; /*2 registers x 2 thresholds, up to 640 channels, up to 64-point scans */
extern double fits[4][640][4]; /*2 registers x 2 thresholds, up to 640 channels, 4 parameters */
extern double x[64];                                                                           
extern double p0[4];                                                                           
extern char v1_l[640], v1_h[640], v2_l[640], v2_h[640], dis[640];                              
extern float factor[4][640];                                                                   
extern double mx;                                                                          
extern double mn;                                                                          
extern float dishi;
extern float dislo;
extern float cnt_time;
extern float guess;
extern double fitdat[64],fitud;
extern char Fname[40];

extern int m, n, info, lwa, iwa[4], one;
extern double tol, fnorm, fvec[64], wa[512];

void inpurge()
{
	char c;
	while ((c = getchar()) != '\n' && c != EOF);
}




int main(void){

char cmd_string[10];
char val[32], temps[30];
float temp; 
int tempi; 
int reset_val=31;
int Not_done=1;
/*struct sigaction sa;
struct itimerval timer;*/


while(Not_done){
	
	memset(cmd_string,0,10);
	memset(val,0,32);
	memset(temps,0,30);
	
	printf("Command?\n");
	scanf("%s",cmd_string);
	
	  if(strcmp(cmd_string,"help")==0){
	     printf("help:    this list\n");
	     printf("scan:    scan upper and lower levels for fixed trim DAC settings.\n");
             printf("fit:     Fit scanned data to erf\n");
	     printf("upcen:   Set upper limit of acceptable edge position\n");
	     printf("lowcen:  Set lower limit of acceptable edge position\n");
	     printf("upres:   Set upper limit of acceptable resolution\n");
	     printf("lowres:  Set lower limit of acceptable resolution\n");
	     printf("disout:  Disable channels outside limits & plot remaining\n");
	     printf("enable:  Enable all channels\n");
	     printf("guess:   set estimated center of fitted data (volts)\n");
	     printf("step:    set threshold level increment for scanning (volts)\n");
	     printf("Nsteps:  number of steps in scan\n");
	     printf("time:    set time to count at each point\n");
	     printf("dislo:   value used to disable lower discriminator\n");
	     printf("dishi:   value used to disable upper discriminator\n");
	     printf("correct: cause trim DAcs to be set to corrected values\n");
	     printf("rstval:  set value to which trim DACs will be set on reset\n");
	     printf("reset:   cause trim DAC values to be reset to rstval\n");
	     printf("restore: read back saved DAC values\n");
	     printf("fname:   set file name for data storage\n");
	     printf("exit:    exits the program\n");
	     }
	     
	  if(strcmp(cmd_string,"show")==0){
	     printf("guess  = %g\n",guess);
	     printf("step   = %g\n",STEP);
	     printf("nstep  = %i\n",NPOINTS);
	     printf("time   = %g\n",cnt_time);
	     printf("dislo  = %g\n",dislo);
	     printf("dishi  = %g\n",dishi);
	     printf("rstval = %i\n",reset_val);
	     printf("fname  = %s\n",Fname);
	     printf("upcen  = %g\n",upcen);
	     printf("lowcen = %g\n",lowcen);
	     printf("upres  = %g\n",upres);
	     printf("lowres = %g\n",lowres);
	     }
	     	        
	  if(strcmp(cmd_string,"scan")==0){
	     scan_levels();
	     }
	  if(strcmp(cmd_string,"fit")==0){
	     fitall();
	     }
	     
	  if(strcmp(cmd_string,"guess")==0){
	     printf("Enter guess [%g]:\n",guess);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp);
	        if(temp != guess) guess=temp;
		}
	     }
	     	  
	  if(strcmp(cmd_string,"step")==0){
	     printf("Enter step [%g]:\n",STEP);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp); 
	        if(temp != STEP) STEP=temp;
		}
	     }
	     
	  if(strcmp(cmd_string,"nstep")==0){
	     printf("Enter nsteps [%i]:\n",NPOINTS);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){	     
	        sscanf(temps,"%i",&tempi); 
	        if(tempi != NPOINTS) NPOINTS=tempi;
		}
	     }
	     
	  if(strcmp(cmd_string,"time")==0){
	     printf("Enter count time [%g]:\n",cnt_time);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp); 
	        if(temp != cnt_time) cnt_time=temp;
		}
	     }
	     
	  if(strcmp(cmd_string,"dislo")==0){
	     printf("Enter dislo [%g]:\n",dislo);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp);
	        if(temp != dislo) dislo=temp;
		}
	     }
	     
	  if(strcmp(cmd_string,"dishi")==0){
	     printf("Enter dishi [%g]:\n",dishi);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp); 
	        if(temp != dishi) dishi=temp;
		}
	     }
	     
	  if(strcmp(cmd_string,"correct")==0){
	     printf("Correcting");
	     Correct();
	     }
	     
	  if(strcmp(cmd_string,"rstval")==0){
	     printf("Enter rstval [%i]:\n",reset_val);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%i",&tempi); 
	        if(tempi != reset_val) reset_val=tempi;
		}
	     }
	     
	  if(strcmp(cmd_string,"reset")==0){
	     printf("Resetting trim DACs to %i",reset_val);
	     ResetTrims(reset_val);
	     }
	     
	  if(strcmp(cmd_string,"restore")==0){
	     Restore_dacs();
	     }
	     
	  if(strcmp(cmd_string,"fname")==0){
	     printf("Enter filename [%s]:\n",Fname);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){ 
	        if(strcmp(temps, Fname)!=0) strcpy(Fname,temps);
		}
	     }
	   
	   if(strcmp(cmd_string,"disout")==0){
	     fit_plot(upres, lowres, upcen, lowcen);
	     Disable_outliers();
	     }
	   
	  if(strcmp(cmd_string,"upres")==0){
	     printf("Enter upper resolution limit [%g]:\n",dishi);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp); 
	        if(temp != upres) upres=temp;
		}
	     }

	  if(strcmp(cmd_string,"lowres")==0){
	     printf("Enter lower resolution limit [%g]:\n",dishi);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp); 
	        if(temp != lowres) lowres=temp;
		}
	     }

	  if(strcmp(cmd_string,"upcen")==0){
	     printf("Enter upper limit for centroid [%g]:\n",dishi);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp); 
	        if(temp != upcen) upcen=temp;
		}
	     }
	  if(strcmp(cmd_string,"lowcen")==0){
	     printf("Enter upper resolution limit [%g]:\n",dishi);
	     inpurge();
	     fgets(temps,sizeof(temps)-1, stdin);
	     if(strlen(temps)>1){
	        sscanf(temps,"%g",&temp); 
	        if(temp != lowcen) lowcen=temp;
		}
	     }

	   if(strcmp(cmd_string,"enable")==0){
	     Enable_all();
	     }

	     
	  if((strcmp(cmd_string,"exit")==0) || (strcmp(cmd_string,"q")==0)){
	     printf("Exit");
	     if(GraceIsOpen()) GraceClose();
	     Not_done=0;
	     }
	  }
}
	  
	  
