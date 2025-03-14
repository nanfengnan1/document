#!/bin/bash

container_name=$1
interface_name=$2

if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}\$"; then
    echo >&2 "错误：容器 ${container_name} 不存在"
    exit 1
fi

if ! docker exec "$container_name" ip a show dev "$interface_name" &>/dev/null; then
    echo >&2 "错误：容器 ${container_name} 不存在接口 ${interface_name}"
    exit 1
fi

netns_id=$(docker inspect -f '{{.State.Pid}}' "$container_name")
echo "sudo nsenter -n -t $netns_id tcpdump -i "$interface_name" -nn"
