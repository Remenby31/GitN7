
// Consigne : compléter et corriger le corps des fonctions ci-dessous (voir TODO).

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>

/**
 * \brief Calculer la somme des cubes des entiers naturels de 1 à max.
 * \param[in] max un entier naturel
 * \return la sommes des cubes de 1 à max
 * \pre max positif : max >= 0
 */
int sommes_cubes(int max)
{
    assert(max >= 0);
    int S = 0;
    for (int i = 1;i <= max;i++) {
        S = S + i*i*i;
    }
    return S;
}


////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                    NE PAS MODIFIER CE QUI SUIT...                          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


void test_sommes_cubes(void) {
    assert(1 == sommes_cubes(1));
    assert(9 == sommes_cubes(2));
    assert(36 == sommes_cubes(3));
    assert(100 == sommes_cubes(4));
    assert(225 == sommes_cubes(5));
    assert(0 == sommes_cubes(0));
    printf("%s", "sommes_cubes... ok\n");
}


int main(void) {
    test_sommes_cubes();
    printf("%s", "Bravo ! Tous les tests passent.\n");
    return EXIT_SUCCESS;
}
