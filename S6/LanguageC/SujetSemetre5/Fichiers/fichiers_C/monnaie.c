/** Squelette du programme **/
/*********************************************************************
 *  Auteur  : Cruvellier Baptiste
 *  Version : 1.0
 *  Objectif : Défnir la monnaie
 ********************************************************************/

#include <stdio.h>
#include <stdlib.h>

struct monnaie {
    float Valeur;
    char Devise;
};
monnaie initialiser(float Valeur, char Devise) {
    monnaie m1;
    m1.Valeur = Valeur;
    m1.Devise = Devise;
    return m1;
}

bool ajouter(monnaie * m1, monnaie * m2) {
    if (m1->Devise == m2->Devise) {
        m2->Devise = m1->Devise;
        m2->Valeur += m1->Valeur;
        return true;
    }
    else {
        return false;
    }
}

void test_monnaie () {

}

int main() {
test_monnaie();
return true;
}
