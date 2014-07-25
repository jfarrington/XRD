#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


int main(void){

FILE *fd;
int dat;
int leng = 32;
int len2;

dat=65535;
fd=fopen("junk.txt","wb");
printf("Error number: %i\n",errno);
printf("fd=%i\n",fd);
if(fd==NULL){ 
   printf("Bad file open\n");
   printf("%s\n",strerror(errno));
   }
printf("Size of Int: %li\n", sizeof(int));
len2=fwrite(&dat, sizeof(int), 1, fd);
if(len2 !=1){ 
   printf("Bad file write\n");
   printf("%s\n",strerror(errno));
   }
printf("%i\n",len2);
/*fprintf(fd,"Hello!\n");*/
fclose(fd);
}
