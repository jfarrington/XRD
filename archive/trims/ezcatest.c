#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void main(){

int y[384];
int res, j;
int NCH = 384;


res=ezcaGet("det1.S2",3,NCH,y);
for(j=0;j<NCH;j++){
     printf("%x ", y[j]);
     }
}
