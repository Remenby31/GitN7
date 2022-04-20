/** Squelette du programme **/
/*********************************************************************
 *  Auteur  :
 *  Version :
 *  Objectif : Conversion pouces/centimètres
 ********************************************************************/

#include <stdio.h>
#include <stdlib.h>

#define UN_POUCE 2.54;

float val;
char unite;
float lg_cm;
float lg_p;

int main()
{

    /* Saisir la longueur */
    scanf("%f %c", &val, &unite);
    /* Calculer la longueur en pouces et en centimètres */
    switch (unite) {
        case 'p'|'P':
        lg_p = val;
        lg_cm = lg_p * UN_POUCE;
        break;

        case 'c'|'C':
        lg_cm = val;
        lg_p = lg_cm / UN_POUCE;
        break;

        case 'm'|'M':
        lg_cm = val / 100;
        lg_p = lg_cm / UN_POUCE;
        break;

        default:
        lg_p = 0;
        lg_cm = 0;
        break;
    }
    /* Afficher la longueur en pouces et en centimètres */
    printf("%f p = %f cm\n",lg_p,lg_cm);
    return EXIT_SUCCESS;
}
