#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>


// Taille du message
#define LENGTH_MSG 30
// Tableau contenant le message
char message[LENGTH_MSG] = "";

// Fonction exécutée dans le fork
void job(int * tube) {
	if (read(*tube, message, LENGTH_MSG) > 0) {
		printf("Message reçu : %s \n", message);
	}
}

int main() {
	int tube[2];
	pid_t pid = fork();
    pipe(tube);
	if (pid == -1) {
		// Il y a une erreur
		perror("Erreur de fork");
		return EXIT_FAILURE;
	} else if (pid == 0) {
		// On est dans le fils
		close(tube[1]);
		job(&tube[0]);
		close(tube[0]);
		exit(EXIT_SUCCESS);
	} else {
		// On est dans le père
        close(tube[0]);
		write(tube[1], "2", LENGTH_MSG);
		close(tube[1]);
	}
	return EXIT_SUCCESS;
}
