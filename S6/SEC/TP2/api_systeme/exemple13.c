#include <signal.h>
#include <unistd.h>

/*************** on_sigusr1 function **************/
void on_sigusr1 (int NumSignal) {
    printf("        s\n");
    usleep( 50000 );
    printf("         i \n");
    usleep( 50000 );
    printf("          g \n");
    usleep( 50000 );
    printf("           n \n");
    usleep( 50000 );
    printf("           a\n");
    usleep( 50000 );
    printf("          l\n");
    usleep( 50000 );
    printf("         1\n");
    usleep( 50000 );
    printf("        !\n");
    usleep( 50000 );
    //printf("Signal 1 ! \n");
}

/*************** on_sigusr2 function **************/
void on_sigusr2 (int NumSignal) {
    printf("        s\n");
    usleep( 50000 );
    printf("         i \n");
    usleep( 50000 );
    printf("          g \n");
    usleep( 50000 );
    printf("           n \n");
    usleep( 50000 );
    printf("           a\n");
    usleep( 50000 );
    printf("          l\n");
    usleep( 50000 );
    printf("         2\n");
    usleep( 50000 );
    printf("        !\n");
    usleep( 50000 );
    //printf("Signal 2 ! \n");
}

/*************** main fonc **************/
int main (int argc, char *argv[]){
  /* on_sigusr1 is the function execluted when receiving
   * SIGUSR1*/
  signal(SIGUSR1, &on_sigusr1);

  /* on_sigusr2 is the function execluted when receiving
   * SIGUSR2 */
  signal(SIGUSR2, &on_sigusr2);

  while (1)
  {
    //printf("J'attends un signal. Mon pid :  %d\n", (int)getpid());
    printf("        |\n");
    usleep( 50000 );
    printf("         \\ \n");
    usleep( 50000 );
    printf("          \\ \n");
    usleep( 50000 );
    printf("           \\ \n");
    usleep( 50000 );
    printf("           |\n");
    usleep( 50000 );
    printf("          /\n");
    usleep( 50000 );
    printf("         /\n");
    usleep( 50000 );
    printf("        /\n");
    usleep( 50000 );
  } /* Waiting for signals */
}
