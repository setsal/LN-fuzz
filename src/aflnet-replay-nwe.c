#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <fcntl.h>
#include "alloc-inl.h"
#include "aflnet.h"

#define server_wait_usecs 10000

char *get_test_case(char* packet_file, int *fsize)
{
  /* open packet file */
  s32 fd = open(packet_file, O_RDONLY);

  *fsize = lseek(fd, 0, SEEK_END);
  lseek(fd, 0, SEEK_SET);

  /* allocate buffer to read the file */
  char *buf = ck_alloc(*fsize);
  ck_read(fd, buf, *fsize, "packet file");

  return buf;
}

int main(int argc, char* argv[])
{
  int portno, n;
  struct sockaddr_in serv_addr;
  char* buf = NULL, *response_buf = NULL;
  int response_buf_size = 0;
  unsigned int i;
  unsigned int socket_timeout = 1000;
  unsigned int poll_timeout = 1;
  int buf_size = 0;

  if (argc < 3) {
    PFATAL("Usage: ./aflnet-replay-nwe packet_file port [first_resp_timeout(us) [follow-up_resp_timeout(ms)]]");
  }

  portno = atoi(argv[2]);

  if (argc > 3) {
    poll_timeout = atoi(argv[3]);
    if (argc > 4) {
      socket_timeout = atoi(argv[4]);
    }
  }

  //Wait for the server to initialize
  usleep(server_wait_usecs);

  if (response_buf) {
    ck_free(response_buf);
    response_buf = NULL;
    response_buf_size = 0;
  }

  int sockfd;
  if (!strcmp(argv[2], "DTLS12")) {
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  } else {
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
  }  

  if (sockfd < 0) {
    PFATAL("Cannot create a socket");
  }

  //Set timeout for socket data sending/receiving -- otherwise it causes a big delay
  //if the server is still alive after processing all the requests
  struct timeval timeout;

  timeout.tv_sec = 0;
  timeout.tv_usec = socket_timeout;

  setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO, (char *)&timeout, sizeof(timeout));

  memset(&serv_addr, '0', sizeof(serv_addr));

  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(portno);
  serv_addr.sin_addr.s_addr = inet_addr("127.0.0.1");

  if(connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
    //If it cannot connect to the server under test
    //try it again as the server initial startup time is varied
    for (n=0; n < 1000; n++) {
      if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == 0) break;
      usleep(1000);
    }
    if (n== 1000) {
      close(sockfd);
      return 1;
    }
  }

  //Send requests one by one
  //And save all the server responses
  buf = get_test_case(argv[1], &buf_size);
  
  //write the requests stored in the generated seed input
  n = net_send(sockfd, timeout, buf, buf_size);

  //receive server responses
  net_recv(sockfd, timeout, poll_timeout, &response_buf, &response_buf_size);


  close(sockfd);

  fprintf(stderr,"\n++++++++++++++++++++++++++++++++\nResponses in details:\n");
  for (i=0; i < response_buf_size; i++) {
    fprintf(stderr,"%c",response_buf[i]);
  }
  fprintf(stderr,"\n--------------------------------");

  //Free memory
  if (buf) ck_free(buf);
  ck_free(response_buf);

  return 0;
}

