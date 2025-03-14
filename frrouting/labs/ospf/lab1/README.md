
### ospf configure

```bash

# ospf frr_A config
router ospf
ospf router-id 10.10.1.1
network 10.10.1.1/24 area 0
network 10.10.2.2/24 area 0

# ospf frr_B config
router ospf
ospf router-id 10.10.1.2
network 10.10.1.2/24 area 0
network 10.10.3.1/24 area 0

# ospf frr_C config
router ospf
ospf router-id 10.10.2.1
network 10.10.2.1/24 area 0
network 10.10.4.3/24 area 0
network 10.10.3.2/24 area 0

# ospf frr_D config
router ospf
ospf router-id 10.10.4.2
network 10.10.4.2/24 area 0
network 20.10.3.1/24 area 1
area 1 stub 

# ospf frr_E config
router ospf
ospf router-id 20.10.1.1
# set interface to ospf area
network 20.10.3.3/24 area 1
network 20.10.1.1/24 area 1
network 20.10.2.2/24 area 1
# config ospf stub area and all internal router must execute this command 
area 1 stub
# config ospf totally area and this configure must execute in stub abr router
# area area-id stub no-summary

# ospf default cost is 10

# ospf frr_F config
router ospf
ospf router-id 20.10.1.2
network 20.10.4.1/24 area 1
network 20.10.1.2/24 area 1
area 1 stub

# ospf frr_G config
router ospf
ospf router-id 20.10.2.1
network 20.10.2.1/24 area 1
network 20.10.4.2/24 area 1
area 1 stub

```