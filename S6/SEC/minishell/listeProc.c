#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <sys/wait.h>

#include "listeProc.h"
#include "readcmd.h"


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

/* Supprime un processus de la liste */
void supprimerListeProc(int pid, listeProc *liste) {
  if (estPresentListeProc(pid, *liste)) {
    if ((*liste) -> pid == pid) {
      (*liste) = (*liste) -> suivant;
    } else {
      while ((*liste) -> suivant != NULL && (*liste) -> suivant -> pid != pid) {
        (*liste) = (*liste) -> suivant;
      }

      if ((*liste) -> suivant -> suivant != NULL) {
        (*liste) -> suivant = (*liste) -> suivant -> suivant;
      } else {
        (*liste) -> suivant = NULL;
      }
    }
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