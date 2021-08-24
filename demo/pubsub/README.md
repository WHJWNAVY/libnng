## [Pub/Sub (Topics & Broadcast)](https://nanomsg.org/gettingstarted/nng/pubsub.html)

![Topics & Broadcast](https://nanomsg.org/gettingstarted/pubsub.png)

This pattern is used to allow a single broadcaster to publish messages to many subscribers, which may choose to limit which messages they receive.

## pubsub.c

```c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <nng/nng.h>
#include <nng/protocol/pubsub0/pub.h>
#include <nng/protocol/pubsub0/sub.h>

#define SERVER "server"
#define CLIENT "client"

void
fatal(const char *func, int rv)
{
        fprintf(stderr, "%s: %s\n", func, nng_strerror(rv));
}

char *
date(void)
{
        time_t now = time(&now);
        struct tm *info = localtime(&now);
        char *text = asctime(info);
        text[strlen(text)-1] = '\0'; // remove '\n'
        return (text);
}

int
server(const char *url)
{
        nng_socket sock;
        int rv;

        if ((rv = nng_pub0_open(&sock)) != 0) {
                fatal("nng_pub0_open", rv);
        }
        if ((rv = nng_listen(sock, url, NULL, 0)) < 0) {
                fatal("nng_listen", rv);
        }
        for (;;) {
                char *d = date();
                printf("SERVER: PUBLISHING DATE %s\n", d);
                if ((rv = nng_send(sock, d, strlen(d) + 1, 0)) != 0) {
                        fatal("nng_send", rv);
                }
                sleep(1);
        }
}

int
client(const char *url, const char *name)
{
        nng_socket sock;
        int rv;

        if ((rv = nng_sub0_open(&sock)) != 0) {
                fatal("nng_sub0_open", rv);
        }

        // subscribe to everything (empty means all topics)
        if ((rv = nng_setopt(sock, NNG_OPT_SUB_SUBSCRIBE, "", 0)) != 0) {
                fatal("nng_setopt", rv);
        }
        if ((rv = nng_dial(sock, url, NULL, 0)) != 0) {
                fatal("nng_dial", rv);
        }
        for (;;) {
                char *buf = NULL;
                size_t sz;
                if ((rv = nng_recv(sock, &buf, &sz, NNG_FLAG_ALLOC)) != 0) {
                        fatal("nng_recv", rv);
                }
                // Blithely assumes message is ASCIIZ string. Real code should check it.
                printf("CLIENT (%s): RECEIVED %s\n", name, buf); 
                nng_free(buf, sz);
        }
}

int
main(const int argc, const char **argv)
{
        if ((argc >= 2) && (strcmp(SERVER, argv[1]) == 0))
                return (server(argv[2]));

          if ((argc >= 3) && (strcmp(CLIENT, argv[1]) == 0))
                return (client (argv[2], argv[3]));

        fprintf(stderr, "Usage: pubsub %s|%s <URL> <ARG> ...\n",
            SERVER, CLIENT);
        return 1;
}
```

## Compilation

```
gcc pubsub.c -lnng -o pubsub
```

## Execution

```
./pubsub server ipc:///tmp/pubsub.ipc & server=$! && sleep 1
./pubsub client ipc:///tmp/pubsub.ipc client0 & client0=$!
./pubsub client ipc:///tmp/pubsub.ipc client1 & client1=$!
./pubsub client ipc:///tmp/pubsub.ipc client2 & client2=$!
sleep 5
kill $server $client0 $client1 $client2
```

## Output

```
SERVER: PUBLISHING DATE Tue Jan  9 08:21:31 2018
SERVER: PUBLISHING DATE Tue Jan  9 08:21:32 2018
CLIENT (client2): RECEIVED Tue Jan  9 08:21:32 2018
CLIENT (client1): RECEIVED Tue Jan  9 08:21:32 2018
CLIENT (client0): RECEIVED Tue Jan  9 08:21:32 2018
SERVER: PUBLISHING DATE Tue Jan  9 08:21:33 2018
CLIENT (client0): RECEIVED Tue Jan  9 08:21:33 2018
CLIENT (client2): RECEIVED Tue Jan  9 08:21:33 2018
CLIENT (client1): RECEIVED Tue Jan  9 08:21:33 2018
SERVER: PUBLISHING DATE Tue Jan  9 08:21:34 2018
CLIENT (client2): RECEIVED Tue Jan  9 08:21:34 2018
CLIENT (client0): RECEIVED Tue Jan  9 08:21:34 2018
CLIENT (client1): RECEIVED Tue Jan  9 08:21:34 2018
SERVER: PUBLISHING DATE Tue Jan  9 08:21:35 2018
CLIENT (client0): RECEIVED Tue Jan  9 08:21:35 2018
CLIENT (client1): RECEIVED Tue Jan  9 08:21:35 2018
CLIENT (client2): RECEIVED Tue Jan  9 08:21:35 2018
SERVER: PUBLISHING DATE Tue Jan  9 08:21:36 2018
CLIENT (client0): RECEIVED Tue Jan  9 08:21:36 2018
CLIENT (client1): RECEIVED Tue Jan  9 08:21:36 2018
CLIENT (client2): RECEIVED Tue Jan  9 08:21:36 2018
```