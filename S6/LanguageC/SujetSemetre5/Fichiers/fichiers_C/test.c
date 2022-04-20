#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

int main(){
{ //debut du bloc B1
    int age = 20;
    { // debut du bloc B2
        int age = 25 ; // variable locale à B2
        printf("%d \n",age);
    } // fin du bloc B2
    // La variable nouvel_age n'existe plus.
    age = age + 1;
    printf("%d \n",age);
} //fin du bloc B1
}
