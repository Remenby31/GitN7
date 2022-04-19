// Le pere effectue le greo
// "double redirection"

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


int main() {
		int tube[2];
		pipe(tube);
			// On est dans le père
			// Ecriture du message dans le tableau
			sprintf(message, "Fork [%i], je suis ton père !\n", pid);
			// Ecriture du message dans le tube
			write(tube[1], message, LENGTH_MSG);
			close(tube[0]);
			close(tube[1]);
		}
	}
	waitForAll();
	return EXIT_SUCCESS;
}
