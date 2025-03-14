

#### x. problem

1. module "ietf-*" not found

    ``` bash
    alexan@alexan-PowerEdge-R740:~/program/github/frr/yang$ pyang -f tree frr-nexthop.yang
    frr-nexthop.yang:7: error: module "ietf-inet-types" not found in search path
    frr-nexthop.yang:11: error: module "ietf-routing-types" not found in search path
    module: frr-nexthop
    +--rw frr-nexthop-group
        +--rw nexthop-groups* [name]
            +--rw name            string
            +--rw frr-nexthops
            +--rw nexthop* [nh-type vrf gateway interface]
                +--rw nh-type            nexthop-type
                +--rw vrf                frr-vrf:vrf-ref
                +--rw gateway            frr-nexthop:optional-ip-address
                +--rw interface          frr-interface:interface-ref
                +--rw bh-type?           blackhole-type
                +--rw onlink?            boolean
                +--rw srte-color?        uint32
                +--rw srv6-segs-stack
                |  +--rw entry* [id]
                |     +--rw id     uint8
                |     +--rw seg?   inet:ipv6-address
                +--rw weight?            uint8
    ```


    ```bash
    git clone git@github.com:YangModels/yang.git

    alexan@alexan-PowerEdge-R740:~/program/github/deps/frr/yang/standard$ pwd
    /home/alexan/program/github/deps/frr/yang/standard
    alexan@alexan-PowerEdge-R740:~/program/github/deps/frr/yang/standard$ cd -
    /home/alexan/program/github/deps/frr/yang/experimental/ietf-extracted-YANG-modules

    alexan@alexan-PowerEdge-R740:~/program/github/frr/yang$ env | grep YANG_MODPATH
    YANG_MODPATH=/home/alexan/program/github/deps/frr/yang/standard:/home/alexan/program/github/deps/frr/yang/experimental/ietf-extracted-YANG-modules
    ```