#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <pthread.h>
#include <time.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <uthash.h>

#define MULTICAST_GROUP "239.255.255.250"
#define PORT 1900
#define BUFFER_SIZE 1024
#define MEMBER_TIMEOUT 60

typedef struct {
    char type;      // 'J'=加入，'L'=离开
    char ip[16];    // 成员IP
} MemberMsg;

typedef struct {
    char ip[16];
    time_t last_active;
    UT_hash_handle hh;
} Member;

int sockfd;
struct sockaddr_in multicast_addr;
struct ip_mreq mreq;
int is_member = 0;
Member *members = NULL;

void get_local_ip(char *buffer) {
    int fd;
    struct ifreq ifr;

    fd = socket(AF_INET, SOCK_DGRAM, 0);
    ifr.ifr_addr.sa_family = AF_INET;
    strncpy(ifr.ifr_name, "eth0", IFNAMSIZ-1);
    ioctl(fd, SIOCGIFADDR, &ifr);
    close(fd);
    strcpy(buffer, inet_ntoa(((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr));
}

void update_member(const char *ip, char action) {
    Member *s;
    HASH_FIND_STR(members, ip, s);
    
    if(action == 'J') {
        if(!s) {
            s = malloc(sizeof(Member));
            strcpy(s->ip, ip);
            HASH_ADD_STR(members, ip, s);
            printf("[+] 新成员加入: %s\n", ip);
        }
        s->last_active = time(NULL);
    } else {
        if(s) {
            HASH_DEL(members, s);
            free(s);
            printf("[-] 成员离开: %s\n", ip);
        }
    }
}

void check_timeout() {
    Member *curr, *tmp;
    time_t now = time(NULL);
    HASH_ITER(hh, members, curr, tmp) {
        if(now - curr->last_active > MEMBER_TIMEOUT) {
            HASH_DEL(members, curr);
            free(curr);
            printf("[!] 成员超时: %s\n", curr->ip);
        }
    }
}

void print_members() {
    Member *s;
    printf("\n=== 当前组成员 ===\n");
    for(s = members; s != NULL; s = s->hh.next) {
        printf("IP: %-15s 最后活跃: %ld秒前\n", 
            s->ip, time(NULL) - s->last_active);
    }
    printf("==================\n");
}

void join_multicast() {
    mreq.imr_multiaddr.s_addr = inet_addr(MULTICAST_GROUP);
    mreq.imr_interface.s_addr = htonl(INADDR_ANY);
    
    if(setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, 
                 &mreq, sizeof(mreq)) < 0) {
        perror("加入失败");
        return;
    }
    is_member = 1;
    
    MemberMsg msg = {'J', ""};
    get_local_ip(msg.ip);
    sendto(sockfd, &msg, sizeof(msg), 0,
          (struct sockaddr*)&multicast_addr, sizeof(multicast_addr));
}

void leave_multicast() {
    if(setsockopt(sockfd, IPPROTO_IP, IP_DROP_MEMBERSHIP,
                 &mreq, sizeof(mreq)) < 0) {
        perror("离开失败");
        return;
    }
    is_member = 0;
    
    MemberMsg msg = {'L', ""};
    get_local_ip(msg.ip);
    sendto(sockfd, &msg, sizeof(msg), 0,
          (struct sockaddr*)&multicast_addr, sizeof(multicast_addr));
}

void *recv_thread(void *arg) {
    struct sockaddr_in src_addr;
    socklen_t addr_len = sizeof(src_addr);
    
    while(1) {
        MemberMsg msg;
        ssize_t len = recvfrom(sockfd, &msg, sizeof(msg), 0,
                             (struct sockaddr*)&src_addr, &addr_len);
        if(len == sizeof(msg)) {
            update_member(msg.ip, msg.type);
            check_timeout();
        }
    }
    return NULL;
}

int main() {
    // 套接字初始化
    if((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("socket创建失败");
        exit(EXIT_FAILURE);
    }

    // 设置套接字选项[2,6](@ref)
    int reuse = 1;
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
    
    unsigned char ttl = 32;
    setsockopt(sockfd, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, sizeof(ttl));

    // 绑定地址
    struct sockaddr_in local_addr = {
        .sin_family = AF_INET,
        .sin_port = htons(PORT),
        .sin_addr.s_addr = INADDR_ANY
    };
    bind(sockfd, (struct sockaddr*)&local_addr, sizeof(local_addr));

    // 配置多播地址
    memset(&multicast_addr, 0, sizeof(multicast_addr));
    multicast_addr.sin_family = AF_INET;
    multicast_addr.sin_port = htons(PORT);
    multicast_addr.sin_addr.s_addr = inet_addr(MULTICAST_GROUP);

    // 启动接收线程[7](@ref)
    pthread_t tid;
    pthread_create(&tid, NULL, recv_thread, NULL);

    // 命令行交互
    printf("命令指南:\n");
    printf("  A - 加入多播组\n");
    printf("  L - 离开多播组\n");
    printf("  L - 列出成员\n");
    printf("  Q - 退出程序\n");

    char cmd;
    while((cmd = getchar()) != 'Q') {
        switch(cmd) {
            case 'A': 
                if(!is_member) {
                    join_multicast();
                    printf("已加入多播组\n");
                }
                break;
            case 'L':
                if(is_member) {
                    leave_multicast();
                    printf("已离开多播组\n");
                } else {
                    print_members();
                }
                break;
        }
        while(getchar() != '\n'); // 清空输入缓冲区
    }

    // 清理资源
    if(is_member) leave_multicast();
    close(sockfd);
    return 0;
}
