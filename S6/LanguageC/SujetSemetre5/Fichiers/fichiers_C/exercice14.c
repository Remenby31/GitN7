
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>

float distance;

// Definition du type Point

struct Point{
    int x;
    float y;
};

struct Point ptA, ptB;

int main(){
    // Déclarer deux variables ptA et ptB de types Point


    // Initialiser ptA à (0,0)
    ptA.x = 0;
    ptA.y = 0.0;

    // Initialiser ptB à (10,10)
    //ptB = {10, 10.0};
    ptB.x = 10;
    ptB.y = 10;
    // Calculer la distance entre ptA et ptB.
    distance = sqrt(pow(ptA.x - ptB.x,2) + pow(ptA.y - ptB.y,2));

    assert( (int)(distance*distance) == 200);

    return EXIT_SUCCESS;
}
