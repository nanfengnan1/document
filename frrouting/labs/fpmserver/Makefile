CC = gcc

CFLAGS = -g -Wall -I/usr/include/frr -I/opt/frr/ -I/opt/frr/zebra/

LDFLAGS = -L/usr/lib -lfrr

SRCS = fpm_listener.c

OBJS = $(SRCS:.c=.o)

EXEC = fpm_listener

all: $(EXEC)

$(EXEC): $(OBJS)
	$(CC) $(OBJS) -o $(EXEC) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(EXEC)
