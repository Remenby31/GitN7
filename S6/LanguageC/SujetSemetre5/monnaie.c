/** Squelette du programme **/
/*********************************************************************
 *  Auteur  : Cruvellier Baptiste
 *  Version : 1.0
 *  Objectif : Défnir la monnaie
 ********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>

// Definition du type monnaie
struct monnaie {
    float Valeur;
    char Devise;
};

typedef struct monnaie monnaie;

#define TAILLE 2
/**
 * \brief Initialiser une monnaie
 * \param[]
 * \pre
 * // TODO
 */


void initialiser(monnaie * m1, float Valeur, char Devise){
    m1->Valeur = Valeur;
    m1->Devise = Devise;
}


/**
 * \brief Ajouter une monnaie m2 à une monnaie m1
 * \param[]
 * // TODO
 */
bool ajouter(monnaie * m1, monnaie * m2){
    if (m1->Devise == m2->Devise) {
        m2->Valeur += m1->Valeur;
        return true;
    }
    else {
        return false;
    }
}


/**
 * \brief Tester Initialiser
 * \param[]
 * // TODO
 */
void tester_initialiser(){
    monnaie m1;
    initialiser(&m1,14,'e');
    assert((m1.Valeur == 14) & (m1.Devise == 'e'));
}

/**
 * \brief Tester Ajouter
 * \param[]
 * // TODO
 */
void tester_ajouter(){
    monnaie m1, m2;

    initialiser(&m1,10,'e');
    assert((m1.Valeur == 10) & (m1.Devise == 'e'));
    initialiser(&m2,20,'e');
    assert((m2.Valeur == 20) & (m2.Devise == 'e'));

    ajouter(&m1,&m2);
    assert((m1.Valeur == 10) & (m1.Devise == 'e'));
    assert((m2.Valeur == 30) & (m2.Devise == 'e'));

}



int main(void){
    //Tests
    printf("Debut des Test...");
    tester_initialiser();
    tester_ajouter();
    printf(" OK\n\n");

    // Un tableau de 5 monnaies
    monnaie porte_monnaie[TAILLE];
    float val; char dev;

    //Initialiser les monnaies
    printf("Remplissez le porte monnaie (Valeur Devise)\n");
    for (int i = 0; i < TAILLE; i++) {
        printf("%i : ",i+1);
        scanf("%f %c",&val,&dev);

        //Mauvaise entrée

/**
        int bo = scanf("%f %c",&val,&dev);
        if (bo != 2 ) {
            printf("\n /!\\ Mauvaise entrée, Réésseyez : \n");
            i -= 1;
        }
**/

        //Afficher Total porte monnaie
        printf("val : %.2f dev : %c\n",val,dev);
        initialiser(&porte_monnaie[i],val,dev);
    }

    // Afficher la somme des toutes les monnaies qui sont dans une devise entrée par l'utilisateur.
    monnaie monnaie_totale;
    initialiser(&monnaie_totale,porte_monnaie[0].Valeur,porte_monnaie[0].Devise);
    for (int i = 1 ; i < TAILLE; i++) {
        ajouter(&porte_monnaie[i],&monnaie_totale);
    }
    printf("Le total de votre portefeuille s'éleve à %.2f %c. \n", monnaie_totale.Valeur, monnaie_totale.Devise);

    return EXIT_SUCCESS;
}
