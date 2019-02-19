/* This file has been generated using the alakon compiler */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include<time.h>
int power(int a, int b){
int i, res =1;
for(i=0;i<b;i++){
res*=a;
}
return res;
}
char * fromIntToGa(int num){
int i=0;
while(num/power(4,i)!=0){
i++;}
char * res = (char*) malloc(2*i*sizeof(char));int charIndex = 0;
for(i=i-1;i>=0;i--){
int pow = power(4,i);
int div = num / pow;
num = num % pow;
switch(div){
case 0:
res[charIndex] = 'G';charIndex++;res[charIndex] = 'a';charIndex++;break;
case 1:
res[charIndex] = 'B';charIndex++;res[charIndex] = 'u';charIndex++;break;
case 2:
res[charIndex] = 'Z';charIndex++;res[charIndex] = 'o';charIndex++;break;
case 3:
res[charIndex] = 'M',charIndex++;res[charIndex] = 'e';charIndex++;break;
}}return res;}
int main(){
srand(time(NULL));
bool varBool1;
varBool1=rand() %2;
bool varBool2=true;
bool varBool3=varBool1&&varBool2;
int varInt1;
varInt1=225;
int varInt2=4;
int varInt3=varInt1*(varInt2);
printf("%s\n",varBool3?"true":"false");
printf("%s\n",fromIntToGa(varInt3));
/*
                     Hello Brice!
                        ,       ,
                       ( \     / (
                       \  '---'  /
                       /.--. .--,\   .-'''-,
                      /\_(o) (o)_/\ /\ | /  \
                  __.-.___(_c_)_.-./\ \ / / /)
                 (__(((_________)))__--''/ / /
                  |  ||  ||  ||  ||  ||   / )
                  |  ||  ||  ||  ||  ||   |/
                  |  ||  ||  ||  ||  ||   '
                  \  ||  ||  ||  ||  ||
                   \ ||  ||  ||  |.- -'''- -._
                   /\||  ||  ||  ;            :
                  |  ||  ||  || :     __       ;
                  |  ||  ||  ||:     (  (       :
                  |  ||  ||  ||;               .
                  |  ||  ||  || ,             ,
                  .,_c__.,__1db__'- -,..,- -'
*/
return EXIT_SUCCESS;
}
