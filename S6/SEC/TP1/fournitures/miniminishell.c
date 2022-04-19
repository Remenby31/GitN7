
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <string.h>

int main(int argc, char *argv[]) {

  int child_term;
  pid_t pidFils, idFils;

  while (1) {
      pidFils = fork();
      /* bonne pratique : tester systématiquement le retour des appels système */
      if (pidFils == -1) {
        printf("Erreur fork\n");
        exit(1);
        /* par convention, renvoyer une valeur > 0 en cas d'erreur,
         * différente pour chaque cause d'erreur
         */
      }
      if (pidFils == 0) {  /* fils */
        char buf[30];  /* contient la commande saisie au clavier */
        int ret ; /* valeur de retour de scanf */
        char commande[35] = "/bin/";
        printf("Entrer le nom de la commande (sans paramètre) de moins de 30 caractères à éxecuter :\n");
        ret = scanf("\%s", buf); /* lit et range dans buf la chaine entrée au clavier */

        if (ret) {  /* Si le scanf a fonctionné corrctement */
            strcat(commande, buf);
            execl(commande, "", NULL);

            /* on se retrouve ici si exec échoue, on affiche l'erreur*/
            //perror("ECHEC : Erreur d'exécutionnnnn ");
        } else {
            printf("!ret\n");
            exit(-1);
        }

        exit(1);
      }
      else {   /* père */
        idFils = wait(&child_term);
        if (idFils == -1) {
          perror("wait ");
          exit(2);
        }
        if (child_term == 0) {
          printf("SUCCES : La commande a été bien exécutée !\n");
        } else {
          printf("ECHEC : La commande n'a pas été bien exécutée !\n");
        }
      }
  }
  printf("Salut\n");
}
