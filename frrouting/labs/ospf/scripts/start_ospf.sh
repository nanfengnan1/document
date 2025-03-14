#!/bin/bash

CONTAINER_FILE=".frr_containers.tmp"

# 容器命名规则校验
function validate_container_name() {
    local name="$1"
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}\$"; then
        echo >&2 "错误：容器 ${name} 已存在"
        return 1
    fi
}

# 核心启动逻辑增强
function start_frr_docker() {
    if [ -z "$1" ] || ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt 26 ]; then
        echo >&2 "错误：请输入1-26的整数"
        exit 1
    fi

    local docker_nums=$1
    echo "正在启动 ${docker_nums} 个FRR容器..."

    for i in $(seq 1 "$docker_nums"); do
        # 生成A-Z字母命名（兼容不同shell环境）
        local container_name="frr_$(printf "\x$(printf %x $((i + 64)) | tr '[:lower:]' '[:upper:]')")"
        
        # 检查容器是否已存在[4](@ref)
        validate_container_name "$container_name" || exit 1
        
        # 启动容器并记录状态[3,5](@ref)
        if ! docker run -d --privileged --net=none --name "$container_name" quay.io/frrouting/frr:10.0.0 >> /dev/null; then
            echo >&2 "错误：启动容器 ${container_name} 失败"
            exit 1
        fi

	# start ospf and bfdd
	docker exec -ti $container_name sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
	docker exec -ti $container_name /usr/lib/frr/watchfrr.sh start ospfd
	docker exec -ti $container_name sed -i 's/ospfd=no/bfdd=yes/g' /etc/frr/daemons
        docker exec -ti $container_name /usr/lib/frr/watchfrr.sh start bfdd
        echo "$container_name" >> "$CONTAINER_FILE"
    done
    echo "成功启动容器列表：$(tr '\n' ' ' < "$CONTAINER_FILE")"
}

# 停止逻辑增强（添加容器状态检查）
function stop_all_containers() {
    if [[ -f "$CONTAINER_FILE" ]]; then
        echo "正在停止容器..."
        while IFS= read -r container; do
            if docker inspect "$container" &>/dev/null; then
                echo "- 停止 ${container}"
                docker stop "$container" >/dev/null && docker rm "$container" >/dev/null
            else
                echo "- 警告：容器 ${container} 不存在"
            fi
        done < "$CONTAINER_FILE"
        rm -f "$CONTAINER_FILE"
    else
        echo "未找到容器记录文件"
    fi
}

function tcpdump_container() {
    container_name=$1
    interface_name=$2
    
    if [ docker ps | grep ${container_name} ]; then
	echo "${container_name} container not exits"
        exit
    fi

    if [ docker exec -ti ${container_name} ip a | grep ${interface_name} ]; then
        echo "${container_name} container not exist ${interface_name} interface"
    fi

    netns_id=$(docker inspect -f '{{.State.Pid}}' frr_A)
    sudo nsenter -n -t ${netns_id} tcpdump -i ${interface_name} -nn
}

# 帮助菜单优化
function help_menu() {
    echo "FRR容器集群管理脚本 (兼容Docker 20.10+)"
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -n, --number <数量>  启动的容器数量（1-26）"
    echo "  -s, --stop           停止所有已启动的容器"
    echo "  -h, --help           显示帮助信息"
}

# 主函数逻辑优化
function main() {
    local container_num=0
    local stop_flag=false

    # 增强参数解析（支持长选项）[5](@ref)
    if ! ARGS=$(getopt -o hn:s --long help,number:,stop -n "$0" -- "$@"); then
        exit 1
    fi
    eval set -- "$ARGS"

    while true; do
        case "$1" in
            -h|--help)    help_menu; exit 0 ;;
            -n|--number)  container_num="$2"; shift 2 ;;
            -s|--stop)    stop_flag=true; shift ;;
            --)           shift; break ;;
            *)            echo >&2 "无效参数：$1"; exit 1 ;;
        esac
    done

    # 参数互斥校验[4](@ref)
    if "$stop_flag" && [ "$container_num" -ne 0 ]; then
        echo >&2 "错误：-n 和 -s 参数不能同时使用"
        exit 1
    fi

    # 执行核心逻辑
    if "$stop_flag"; then
        stop_all_containers
    elif [ "$container_num" -gt 0 ]; then
        start_frr_docker "$container_num"
    else
        echo >&2 "错误：必须指定 -n 或 -s 参数"
        help_menu
        exit 1
    fi
}

main "$@"
