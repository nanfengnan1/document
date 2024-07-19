#!/bin/bash

release=$(grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')

if echo "$release" | grep -iq "centos"; then
    echo "centos7"
elif echo "$release" | grep -iq "ubuntu"; then
	echo "ubuntu"
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
    cat ubuntu_sources.list > /etc/apt/sources.list
	apt update
	apt upgrade
fi
