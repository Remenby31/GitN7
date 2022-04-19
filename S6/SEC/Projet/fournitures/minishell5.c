
# include <stdio.h> /* printf */
# include <unistd.h> /* fork */
# include <stdlib.h> /* EXIT_SUCCESS */
# include <sys/wait.h> /* wait */
# include <stdbool.h> 
# include <string.h> 
# include "readcmd.h"

int main ( int argc , char * argv []) {
    int pid;
    bool sortie = false;
    int codeTerm;
    typedef struct cmdline cmdline;
    cmdline* entree; 
    int cd;
    do {
        printf("sh-3.2$ ");
        entree = readcmd(); 
        printf("\n");
        if (entree == NULL) {
            NULL;
        } else if (entree->err != NULL) {
            printf("Commande impossible \n");
        } else if (strcmp(entree->seq[0][0], "cd") == 0) {
            /*if (chdir(entree->seq[0][1]) == "") {
                
            } else if (chdir(entree->seq[0][1]) == "~") {

            } */
            cd = chdir(entree->seq[0][1]);
            if (cd == -1) {
                printf("Erreur dans le chemin donné en entree \n");
            }
        } else {
            if (*(entree->seq[0][0]) == EOF || strcmp(entree->seq[0][0],"exit") == 0) {
                sortie = true;
            } else  {
                pid = fork();
                if (pid == -1) {
                    printf("ECHEC \n");
                    exit(EXIT_FAILURE);
                } else if (pid == 0) {
                    execvp(entree->seq[0][0], entree->seq[0]);
                    exit(EXIT_FAILURE);
                }
                if (entree->backgrounded == NULL) {
                    int idFils = wait(&codeTerm);
                    if (idFils == -1) {
                        printf("ECHEC \n");
                        exit(EXIT_FAILURE);
                    }
                    if (WIFEXITED(codeTerm)) {
                        printf("SUCCESS \n");
                        exit(EXIT_SUCCESS);
                    } else {
                        printf("ECHEC \n");
                        exit(EXIT_FAILURE);
                    }
                }
                
            }
            
        }
        
    } while (!sortie);

}
