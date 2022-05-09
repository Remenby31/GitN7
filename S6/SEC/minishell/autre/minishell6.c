# include <stdio.h>
# include <unistd.h>
# include <stdlib.h>
# include <sys/wait.h>
# include <string.h>
# include <limits.h>
# include <stdbool.h>

# include "readcmd.h"

/* Constantes */
# define MAX_LENGTH_COMMAND 20
# define NB_fils 1


char cwd[PATH_MAX];
int codeTerm;
int nb_fils_termine;
struct cmdline * cmd; // commande à lire

/* Etat des Processus (actif ou suspendu)*/
enum Etat {ACTIF, SUSPENDU};
typedef enum Etat Etat;

/* Définition de listeProc contenant la liste des Processus en cours d'éxecution */
typedef struct listeProc *listeProc;
struct listeProc {
  int pid;
  int numero;
  Etat etat;
  char cmd[MAX_LENGTH_COMMAND];
  listeProc suivant;
};

/* Initialisation de la liste des processus */
listeProc liste = NULL;

/* PID fils */
pid_t pidFils;



/* ajoute un processus à la liste */
void ajouterListeProc(int pid, Etat etat, char *cmd, listeProc *liste) {
  listeProc new_liste = malloc(sizeof(struct listeProc));
  // Numero
  if ((*liste) == NULL) {
    new_liste -> numero = 1;
  } else {
    new_liste -> numero = ((*liste) -> numero) + 1;
  }
  // Etat
  new_liste -> etat = etat;
  // PID
  new_liste -> pid = pid;
  // commande
  strncpy(new_liste -> cmd, cmd, MAX_LENGTH_COMMAND);
  // suivant
  new_liste -> suivant = (*liste);
  (*liste) = new_liste;
}

/* Retourne treu si le Processus est présent dans la liste */
bool estPresentListeProc(int pid, listeProc liste) {
  bool present = false;
  if (liste != NULL) {
    present = (liste -> pid == pid) ? true : estPresentListeProc(pid, liste -> suivant);
  }
  return present;
}

/* Supprime un processus de la liste */
void supprimerListeProc(int pid, listeProc *liste) {
  if (estPresentListeProc(pid, *liste)) {
    // Si le PID est présent au début
    (*liste) =  ((*liste) -> pid == pid) ? (*liste) -> suivant : (*liste);

    // sinon on parcours le reste de la liste
    while ((*liste) -> suivant != NULL && (*liste) -> suivant -> pid != pid) {
      (*liste) = (*liste) -> suivant; // passage au suivant
      }

    //On sort du while quand le PID est détecté au suivant (cas 2) ou à la fin (cas 1)
    (*liste) -> suivant = ((*liste) -> suivant -> suivant == NULL) ? NULL :  (*liste) -> suivant -> suivant;
    }
}

/* Affichage En tete Liste Processus */
void afficheEnTeteListeProc() {
  printf("IND     PID      ETAT         CMD\n");
}

/* Affichage Liste Processus */
void afficherListeProc(listeProc liste) {
  if (liste == NULL) {
    printf("------------------------------------\n");
  }
  else {
    char *etat = (liste -> etat == ACTIF) ? "Actif   " : "Suspendu";
    printf("  %d  %d      %s     %3s\n", liste -> numero, liste -> pid, etat, liste -> cmd);
    afficherListeProc(liste -> suivant);
  }
}

/* Changer l'état d'un processus */
void NouvEtatProc(int pid, Etat etat, listeProc *liste) {
  if (estPresentListeProc(pid, *liste)) {
    if ((*liste) -> pid == pid) { // C'est celui la
      (*liste) -> etat = etat;
    } else {
      NouvEtatProc(pid, etat, &((*liste) -> suivant));
    }
  }
}

/* Retourne le pid d'un processus de la liste */
int getPid(int id, listeProc liste) {
  int pid = -1;
  while (liste -> numero != id && liste -> suivant != NULL) {
    liste = liste -> suivant;
  }
  if (liste != NULL) {
    pid = liste -> pid;
  }
  return pid;
}

/* Reprendre un processus */
void reprendreProc(int id, listeProc (*liste)) {
  int pid = getPid(id, *liste);
  if (pid > 0) {
    kill(pid, SIGCONT);
  }
  else {
    perror("PID non trouvé");
  }
}

/* Arrêt d'un processus */
void arreterProc(int id, listeProc (*liste)) {
  int pid = getPid(id, *liste);
  if (pid > 0) {
    kill(pid, SIGSTOP);
  }
  else {
    perror("PID non trouvé");
  }
}

/* Signal SIGCHLD */
void handler_chld(int signal_num) {

  int fils_termine, wstatus;
  nb_fils_termine++;

  if (signal_num == SIGCHLD) {
    while ((fils_termine = (int) waitpid(-1, &wstatus, WNOHANG | WUNTRACED | WCONTINUED)) > 0) {

      /* Terminé naturellement */
      if (WIFEXITED(wstatus)) {
        nb_fils_termine++;
        supprimerListeProc(fils_termine, &liste);

      /* Terminé par un signal */
      } else if (WIFSIGNALED(wstatus)) {
        nb_fils_termine++;
        supprimerListeProc(fils_termine, &liste);

      /* Réception SIGCONT */
      } else if (WIFCONTINUED(wstatus)) {
        NouvEtatProc(fils_termine, ACTIF, &liste);

      /* Réception SIGSTOP */
    } else if (WIFSTOPPED(wstatus)) {
        NouvEtatProc(fils_termine, SUSPENDU, &liste);
      }
    }
  }
}

/* Affiche l'invite de commande */
void afficherEntree() {
  getcwd(cwd, sizeof(cwd));
  printf("bcruvell@minishell:~%s$ ", cwd);
  fflush(stdout);
}

int main() {

  signal(SIGCHLD, handler_chld); //sigaction

  while (1) {

    /* Affichage de l'invite de commande */
    afficherEntree();

    /* Lecture de la commande */
    cmd = readcmd();

    if (cmd != NULL) {
      if ((cmd->seq)[0] != NULL) {

        /* Commande exit */
        if (!strcmp((cmd->seq)[0][0], "exit") && !(cmd->backgrounded)) {
          exit(0);

        /* Commande cd */
        } else if (!strcmp((cmd->seq)[0][0], "cd") && !(cmd->backgrounded)) {
          chdir((cmd->seq)[0][1]);

        /* Commande lj : Affiche la liste des processus en cours */
        } else if (!strcmp((cmd->seq)[0][0], "lj") && !(cmd->backgrounded)) {
          afficheEnTeteListeProc();
          afficherListeProc(liste);

        /* Commande sj : Suspend un processus */
        } else if (!strcmp((cmd->seq)[0][0], "sj") && !(cmd->backgrounded)) {
          arreterProc(atoi(cmd->seq[0][1]), &liste);

        /* Commande bg : Reprend un processus suspendu en arrière plan */
        } else if (!strcmp((cmd->seq)[0][0], "bg") && !(cmd->backgrounded)) {
          if (liste == NULL) {
            printf("Pas de processus en cours\n");
          } else if ((cmd->seq)[0][1] == NULL) {
            printf("Pas assez d'argument\n");
          } else {
            reprendreProc(atoi(cmd->seq[0][1]), &liste);
          }

        /* Commande fg  : Reprend un processus suspendu au premier plan */
        } else if (!strcmp((cmd->seq)[0][0], "fg") && !(cmd->backgrounded)) {
          if (liste == NULL) {
            printf("Pas de processus en cours\n");
          } else if ((cmd->seq)[0][1] == NULL) {
            printf("Pas assez d'argument\n");
          } else {
            int pid = getPid(atoi(cmd->seq[0][1]), liste);
            if (pid != -1) {
              kill(pid, SIGCONT);
              supprimerListeProc(pid, &liste);
              waitpid(pid, NULL, WUNTRACED);
            }
          }

        } else {


        pidFils = fork();

        if (pidFils < 0) { //erreur
          exit(1);
        }

        if (pidFils == 0) {

          int ret;
          if ((cmd->seq)[0][0] != NULL) {
            ret = execvp((cmd->seq)[0][0], (cmd->seq)[0]);
          }

          if (ret == -1) {
            perror("Erreur");
            exit(0);
          }

          exit(1);

        } else {
          if ((cmd->backgrounded) == NULL) {
            pid_t idFils = wait(&codeTerm);
            if (idFils == -1) { //erreur
              perror("wait...");
              exit(2);
            }
          } else {
            ajouterListeProc(pidFils, ACTIF, cmd->seq[0][0], &liste);
          }
        }
        }
      }
    }
  }
  return EXIT_SUCCESS;
}
