#!/bin/bash

# ################ vrf & p2p ############ #

function start_ospf_lab() {

    sudo ovs-vsctl add-br frrlab8Br

    sudo ovs-docker add-port frrlab8Br eth1 frr_A --ipaddress=10.0.1.1/24
    sudo ovs-docker add-port frrlab8Br eth2 frr_A --ipaddress=20.0.1.1/24
    sudo ovs-docker add-port frrlab8Br eth1 frr_B --ipaddress=10.0.1.2/24
    sudo ovs-docker add-port frrlab8Br eth2 frr_C --ipaddress=20.0.1.2/24
}

start_ospf_lab
