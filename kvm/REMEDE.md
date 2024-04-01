// author: alexan
// date  : 16/6/2023
// update: 5/1/2024

### special statement
> this is a directory to store every VF NIC configuration.
> don not suggets to modify or change anything in this direction.


#### configuration file named format
> such as, pcie-dev.xml


#### single configuration steps
> 1. execute [ lshw -c network -businf ] command to list pcie info
> 2. write configuration xml file for vf NIC
> 3. execute [  virsh attach-device virtual_machine_name pcie_dev_xml_solution_path --live --config ] , attach vf NIC to pointed vm
>   i think you should pay attention to some qz.
>   first : how to know your vm name? you may execute [ virsh list --all ] command to show all virtual machines, including had beed shutdown machine.
>   second: how to write pcie_dev_xml file, i think you should know about pcie address format. [such as: domain:bus:slot.function],
>           of course, you can execute [ virsh nodedev-dumpxml pci_0000_5e_02_0 ] command to get information, as domain:bus:slot.function. and copy and paste.
>   third : --live parameter, only to add configuration information for lived vm. if your vm is deading, please cutting it.
>           --config parameter, no interpretaion.

#### a example for you
condition precedent:
> 1. pci_0000_5e_02_0, a vf NIC

program configuration xml for this VF NIC
> 1. execute [ virsh nodedev-list | grep "0000:5e:02.0" ] command, to validate this info.
> 2. execute [ vim pcie_domain_bus_slot_function.xml -> vim pcie_0000_5e_02_0.xml ] command to program vf NIC xml in "/sriov" path,
     hoping obey this format for samplify operation.
> 3. skip steps 3 operation, to show finnally vf NIC xml configuration information
  ```
  <interface type='hostdev' managed='yes'>
    <source>
       <address type='pci' domain='0x0000' bus='0x5e' slot='0x02' function='0x0' />
    </source>
  </interface>
  ```


#### reference documents
4. sriov redhat configuration document
> [redhat sriov configuration](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/managing-sr-iov-devices_managing-virtual-devices)

### command
#### show pcie
>  lshw -c network -businf
####

#### kvm virtual machine create

#### kvm network [very import]

#### kvm snapshot

### details
> 0000:5e:02.5 and 0000:5e:0a.5 be used by 114'vpp
