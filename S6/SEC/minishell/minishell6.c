# include <stdio.h>
# include <unistd.h>
# include <stdlib.h>
# include <sys/wait.h>
# include <string.h>
# include <limits.h>
# include <stdbool.h>

# include "readcmd.h"
# include "listeProc.h"


char cwd[PATH_MAX];
int codeTerm;
int nb_fils_termine;
struct cmdline * cmd; // commande à lire

/* Initialisation de la liste des processus */
listeProc liste = NULL;

/* PID fils */
pid_t pidFils;

/* Signal SIGCHLD */
void handler_chld(int signal_num) {
  int fils_termine, wstatus;
  nb_fils_termine++;

  if (signal_num == SIGCHLD) {
    while ((fils_termine = (int) waitpid(-1, &wstatus, WNOHANG | WUNTRACED | WCONTINUED)) > 0) {

      printf("wstatus %d du Child mageule\n",wstatus);

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
        printf("WIFSTOPPED du Child mageule\n");
        NouvEtatProc(fils_termine, SUSPENDU, &liste);

      /* Réception SIGINT */
      } else if (WIFSIGNALED(wstatus)) {
        printf("WIFSIGNALED du Child mageule\n");
      }
    }
  }
}

/* Signal SIGTSTP */
void handler_stp(int signal_num) { //Lord d'un ctrl Z
  printf("\nSIGTSTP Magueule\n");
}

/* Signal SIGINT */
void handler_int(int signal_num) {
  printf("\nSIGINT Magueule\n");
}

/* Affiche l'invite de commande */
void afficherEntree() {
  getcwd(cwd, sizeof(cwd));
  printf("bcruvell@minishell:~%s$ ", cwd);
  fflush(stdout);
}

int main() {

  signal(SIGCHLD, handler_chld);
  signal(SIGTSTP, handler_stp);

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
          if ((cmd->seq)[0][1] == NULL) {
            for (int i; i <= sizeof(liste)/sizeof(listeProc); i++) {
              arreterProc(liste[i].numero, &liste);
            }
          } else {
            arreterProc(atoi(cmd->seq[0][1]), &liste);
          }

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
          /* Avant plan */
          if ((cmd->backgrounded) == NULL) {
            printf("avant plan !\n");
            pid_t idFils = wait(&codeTerm);
            if (idFils == -1) { //erreur
              perror("wait...");
              exit(2);
            }
          /* Arriere plan */
          } else {
            printf("arriere plan !\n");
            ajouterListeProc(pidFils, ACTIF, cmd->seq[0][0], &liste);
          }
        }
        }
      }
    }
  }
  return EXIT_SUCCESS;
}
