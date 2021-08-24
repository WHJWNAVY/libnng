## [Pair (Two Way Radio)](https://nanomsg.org/gettingstarted/nng/pair.html)

![Two Way Radio](https://nanomsg.org/gettingstarted/pair.png)

The pair pattern is used when there a one-to-one peer relationship. Only one peer may be connected to another peer at a time, but both may speak freely.

## pair.c

```C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <nng/nng.h>
#include <nng/protocol/pair0/pair.h>

#define NODE0 "node0"
#define NODE1 "node1"

void
fatal(const char *func, int rv)
{
        fprintf(stderr, "%s: %s\n", func, nng_strerror(rv));
        exit(1);
}

int
send_name(nng_socket sock, char *name)
{
        int rv;
        printf("%s: SENDING \"%s\"\n", name, name);
        if ((rv = nng_send(sock, name, strlen(name) + 1, 0)) != 0) {
                fatal("nng_send", rv);
        }
        return (rv);
}

int
recv_name(nng_socket sock, char *name)
{
        char *buf = NULL;
        int rv;
        size_t sz;
        if ((rv = nng_recv(sock, &buf, &sz, NNG_FLAG_ALLOC)) == 0) {
                // Blithely assumes message is ASCIIZ string. Real code should check it.
                printf("%s: RECEIVED \"%s\"\n", name, buf); 
                nng_free(buf, sz);
        }
        return (rv);
}

int
send_recv(nng_socket sock, char *name)
{
        int rv;
        if ((rv = nng_setopt_ms(sock, NNG_OPT_RECVTIMEO, 100)) != 0) {
                fatal("nng_setopt_ms", rv);
        }
        for (;;) {
                recv_name(sock, name);
                sleep(1);
                send_name(sock, name);
        }
}

int
node0(const char *url)
{
        nng_socket sock;
        int rv;
        if ((rv = nng_pair0_open(&sock)) != 0) {
                fatal("nng_pair0_open", rv);
        }
         if ((rv = nng_listen(sock, url, NULL, 0)) !=0) {
                fatal("nng_listen", rv);
        }
        return (send_recv(sock, NODE0));
}

int
node1(const char *url)
{
        nng_socket sock;
        int rv;
        sleep(1);
        if ((rv = nng_pair0_open(&sock)) != 0) {
                fatal("nng_pair0_open", rv);
        }
        if ((rv = nng_dial(sock, url, NULL, 0)) != 0) {
                fatal("nng_dial", rv);
        }
        return (send_recv(sock, NODE1));
}

int
main(int argc, char **argv)
{
        if ((argc > 1) && (strcmp(NODE0, argv[1]) == 0))
                return (node0(argv[2]));

        if ((argc > 1) && (strcmp(NODE1, argv[1]) == 0))
                return (node1(argv[2]));

        fprintf(stderr, "Usage: pair %s|%s <URL> <ARG> ...\n", NODE0, NODE1);
        return 1;
}
```

## Compilation

```bash
gcc pair.c -lnng -o pair
```

## Execution

```bash
./pair node0 ipc:///tmp/pair.ipc & node0=$!
./pair node1 ipc:///tmp/pair.ipc & node1=$!
sleep 3
kill $node0 $node1
```

## Output

```bash
node0: SENDING "node0"
node1: RECEIVED "node0"
node1: SENDING "node1"
node0: SENDING "node0"
node0: RECEIVED "node1"
node1: RECEIVED "node0"
```
