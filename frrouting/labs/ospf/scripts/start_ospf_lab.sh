#!/bin/bash

function start_ospf_lab() {

    sudo ovs-vsctl add-br frrBr

    # stub area
    sudo ovs-docker add-port frrBr eth1 frr_A --ipaddress=10.10.1.1/24
    sudo ovs-docker add-port frrBr eth2 frr_A --ipaddress=10.10.2.2/24
    # as ASBR import route
    sudo ovs-docker add-port frrBr eth3 frr_A --ipaddress=30.10.1.3/24

    sudo ovs-docker add-port frrBr eth1 frr_B --ipaddress=10.10.3.1/24
    sudo ovs-docker add-port frrBr eth2 frr_B --ipaddress=10.10.1.2/24

    sudo ovs-docker add-port frrBr eth1 frr_C --ipaddress=10.10.2.1/24
    sudo ovs-docker add-port frrBr eth2 frr_C --ipaddress=10.10.3.2/24
    sudo ovs-docker add-port frrBr eth3 frr_C --ipaddress=10.10.4.3/24

    # ospf abr
    sudo ovs-docker add-port frrBr eth1 frr_D --ipaddress=20.10.3.1/24
    sudo ovs-docker add-port frrBr eth2 frr_D --ipaddress=10.10.4.2/24

    # backbone area
    sudo ovs-docker add-port frrBr eth1 frr_E --ipaddress=20.10.1.1/24
    sudo ovs-docker add-port frrBr eth2 frr_E --ipaddress=20.10.2.2/24
    sudo ovs-docker add-port frrBr eth3 frr_E --ipaddress=20.10.3.3/24

    sudo ovs-docker add-port frrBr eth1 frr_F --ipaddress=20.10.4.1/24
    sudo ovs-docker add-port frrBr eth2 frr_F --ipaddress=20.10.1.2/24

    sudo ovs-docker add-port frrBr eth1 frr_G --ipaddress=20.10.2.1/24
    sudo ovs-docker add-port frrBr eth2 frr_G --ipaddress=20.10.4.2/24
}

start_ospf_lab
