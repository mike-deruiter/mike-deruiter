/* Reference: https://geeksforgeeks.org/socket-programming-cc 
 *
 * Just a demonstration that I understand this code.          */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#define BUFF_SIZE   1024
#define PORT        8080
#define ADDRESS     "127.0.0.1"

int main(int argc, char *argv[])
{
    int server_fd, new_socket, valread;
    struct sockaddr_in address;
    int addrlen = sizeof(address);   // ???
    char buffer[BUFF_SIZE] = {0};
    char *hello = "Greetings from server";
    
    if ((server_fd = socket(AF_INET,        // IPv4 
                            SOCK_STREAM,    // TCP
                            0)) == 0)
    {
        perror("server: socket failed");
        exit(EXIT_FAILURE);
    }
    
    address.sin_family = AF_INET;
    address.sin_port = htons(PORT);
    
    if (inet_pton(AF_INET, ADDRESS, &address.sin_addr.s_addr) < 0)
    {
        perror("server: invalid address / not supported");
        exit(EXIT_FAILURE);
    }
    
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) 
    {
        perror("server: bind failed");
        exit(EXIT_FAILURE);
    }
    
    if (listen(server_fd, 3) < 0) 
    {
        perror("server: listen");
        exit(EXIT_FAILURE);
    }
    
    if ((new_socket = accept(server_fd, (struct sockaddr *)&address,
                             (socklen_t *)&addrlen)) < 0)
    {
        perror("server: accept");
        exit(EXIT_FAILURE);
    }
    
    valread = read(new_socket, buffer, BUFF_SIZE);
    printf("Message Received: %s\n", buffer);
    send(new_socket, hello, strlen(hello), 0);
    printf("Message Sent:     %s\n", hello);
    
    return 0;
}
