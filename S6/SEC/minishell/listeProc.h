# define MAX_LENGTH_COMMAND 20
# include <stdbool.h>

/* Etat des Processus (actif ou suspendu)*/
enum Etat {ACTIF, SUSPENDU};
typedef enum Etat Etat;

typedef struct listeProc *listeProc;

struct listeProc {
  int pid;
  int numero;
  Etat etat;
  char cmd[MAX_LENGTH_COMMAND];
  listeProc suivant;
};


/* ajoute un processus à la liste */
void ajouterListeProc(int pid, Etat etat, char *cmd, listeProc *liste);

/* Retourne treu si le Processus est présent dans la liste */
bool estPresentListeProc(int pid, listeProc liste);

/* Affichage En tete Liste Processus */
void afficheEnTeteListeProc();

/* Affichage Liste Processus */
void afficherListeProc(listeProc liste);

/* Supprime un processus de la liste */
void supprimerListeProc(int pid, listeProc *liste);

/* Changer l'état d'un processus */
void NouvEtatProc(int pid, Etat etat, listeProc *liste);

/* Retourne le pid d'un processus de la liste */
int getPid(int id, listeProc liste);

/* Reprendre un processus */
void reprendreProc(int id, listeProc (*liste));

/* Arrêt d'un processus */
void arreterProc(int id, listeProc (*liste));