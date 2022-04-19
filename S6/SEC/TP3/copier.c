#include <stdio.h>    /* entrées sorties */
#include <unistd.h>   /* pimitives de base : fork, ...*/
#include <stdlib.h>   /* exit */
#include <sys/wait.h> /* wait */
#include <string.h>   /* opérations sur les chaines */
#include <fcntl.h>    /* opérations sur les fichiers */

#define BUFSIZE 4096

int main(int argc, char *argv[]) {

    char buffer[BUFSIZE];

    int condition,retourW;

    /* Ouverture des fichiers */
    int fichier1 = open(argv[1], O_RDONLY, 0640);
    int fichier2 = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0640);

    /* Lecture & Ecriture */
    do {
        condition = read(fichier1, buffer, BUFSIZE * sizeof(char));
        retourW = write(fichier2,buffer,condition);
    } while (condition > 0);

    /* Fermeture des fichiers */
    close(fichier1);
    close(fichier2);

    return EXIT_SUCCESS ;
}