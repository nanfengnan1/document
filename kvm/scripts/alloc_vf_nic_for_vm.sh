#!/bin/bash

<< EOF
1. os: centos7

EOF

SUPPORT_SR_IOV_NIC=()
VIR_MACHINE_NAMES=$(virsh list --all | awk 'NR>=3 {print $2}' | sed -e '$d')

# xml format start
VF_XML_PREFIX1="<interface type='hostdev' managed='yes'>"
VF_XML_PREFIX2="<source>"
VF_XML_PREFIX3="<address "
VF_XML_PREFIX4="type='pci'"
VF_XML_SUBFIX1="</interface>"
VF_XML_SUBFIX2="</source>"


VM_RUNNING_STATUS="running"
VM_SHUTDOWN_STATUS="shutdown"
# xml format end



BIOS_ENABLE_IOV=
LOAD_KVM_MODULE=
GRUP_SUPP_IOMMU=
HOSTVI_VALIDATE=
PHY_SUPPO_SRIOV=
DISPLAY_CONFIGS=off

function check_sriov_envirment()
{
  # check BIOS support iov
  BIOS_ENABLE_IOV=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
  
  if [[ ${BIOS_ENABLE_IOV} == "0" || -z ${BIOS_ENABLE_IOV} ]]; then
    echo -e "\033[31mplease enable iov function in bios \033[0m"
    exit -1
  fi
   
  if [ ${DISPLAY_CONFIGS} == "on" ]; then
    echo -e "\033[36m[*]:BIOS has enabled sriov function \033[0m"
  fi

  # check kvm envirment
  LOAD_KVM_MODULE=$(lsmod | grep -w kvm | awk '{print $1}' | head -n 1)
  if [ -z ${LOAD_KVM_MODULE} ]; then
    echo -e "\033[31mplease insmod kvm.ko \033[0m"
    exit -1
  fi

  if [ ${DISPLAY_CONFIGS} == "on" ]; then
    echo -e "\033[36m[*]:kernal has insmod kvm.ko \033[0m"
  fi

  # check grup configuration parameter
  GRUP_SUPP_IOMMU=$(grep "iommu" /etc/grub2.cfg | sed -n 's/.*iommu=\(.*=\)\?.*/\1/p' | awk '{print $1}' | head -n 2)
  if [ ${#GRUP_SUPP_IOMMU} == 0 ]; then
    echo -e "\033[31mplease check grub support amd_iommu or intel_iommu \033[0m"
    exit -1
  fi

  for element in ${GRUP_SUPP_IOMMU}; do
    if [ $element != "on" ]; then
      echo -e "\033[31mplease enable amd_iommu or intel_iommu in grub2.cfg \033[0m"
      exit -1
    fi
  done
 
  if [ ${DISPLAY_CONFIGS} == "on" ]; then
    echo -e "\033[36m[*]:grub has add intel_iommu or amd_iommul parameter \033[0m"
  fi

  # validate host-virt
  HOSTVI_VALIDATE=$(virt-host-validate | awk '{print $NF}')
  for pass in ${HOSTVI_VALIDATE}; do
    if [ ${pass} != "PASS" ]; then
      echo -e "\033[31mvalite host virt failure! \033[0m"
      exit -1
    fi
  done

  if [ ${DISPLAY_CONFIGS} == "on" ]; then
    echo -e "\033[36m[*]:valite host support virt function \033[0m"
  fi

  # check phy NIC support sr-iov
  PCIE_ADDRESS=$(lspci | grep Ethernet | awk '{print $1}')
  iterator=0
  for pcie in ${PCIE_ADDRESS}; do
    PHY_SUPPO_SRIOV=$(lspci -vvs ${pcie} | grep "SR-IOV")
    if [ ${#PHY_SUPPO_SRIOV} -gt 0 ]; then
      SUPPORT_SR_IOV_NIC[iterator]=$pcie
      iterator=$(($iterator + 1))
      
      if [ ${DISPLAY_CONFIGS} == "on" ]; then
        echo -e "\033[35m[*]:pny nic[${pcie}] support sriov function \033[0m"
      fi
    fi
  done
 
  if [ ${#SUPPORT_SR_IOV_NIC} == 0 ]; then
    echo -e "\033[31no phy nic support sr-iov \033[0m"
    exit -1
  fi

  if [ ${DISPLAY_CONFIGS} == "on" ]; then
    echo -e "\033[36m[*]:linux envirment support sriov function \033[0m"
    reset
  fi
}

function display_support_sriov_nic()
{
  echo "support sriov physical nic lists:"
  for pcie in ${SUPPORT_SR_IOV_NIC[*]}; do
    pcie_info=$(lspci | grep Ethernet | grep ${pcie})
    echo -e "\t$pcie_info"
  done
}

function display_all_nic()
{
  echo "display all nic lists:"
  nic_pcie=$(lspci | grep Ethernet | awk '{print $1}')
  for pcie in ${nic_pcie[*]}; do
    nic_info=$(lspci | grep ${pcie})
    echo -e "\t${nic_info}"
  done
}

function display_all_virtual_nic()
{
  echo "display all virtaul nics"
  virtual_nic_pcie=$(lspci | grep "Virtual Function" | awk '{print $1}')
  for pcie in ${virtual_nic_pcie[*]}; do
    virtual_nic=$(lspci | grep ${pcie});
    echo -e "\t${virtual_nic}"
  done
}

# input: $1-> pf_pcie/nic_name
function display_all_virtual_nic_from_pf()
{
  vf_index=-1
  phy_nic_pcie=$1
  regex='^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-9a-fA-F]$'
  if [[ $pcie =~ $regex ]]; then
    phy_nic_pcie=$(lspci | grep $phy_nic_pcie | awk '{print $1}')
    pcie_address=$(echo ${phy_nic_pcie} | sed 's/:/_/g' | sed 's/\./_/g')
    pcie_address=pci_0000_${pcie_address}

    echo "display all vf nic from pf[${phy_nic_pcie}]"
    echo "pice: ${pcie_address}"
    tmp_string=$(virsh nodedev-dumpxml ${pcie_address} | grep "address" | awk '{print $3"-"$4"-"$5"-"}' | tr -d "/>")
    for str in ${tmp_string[*]}; do
      bus=$(echo $str | tr -d "'" | cut -d- -f 1 | sed "s/0\(.*\)x/\1/")
      bus=${bus#*=}
      slot=$(echo $str | tr -d "'" | cut -d- -f 2 | sed "s/0\(.*\)x/\1/")
      slot=${slot#*=}
      function=$(echo $str | tr -d "'" | cut -d- -f 3 | sed "s/0\(.*\)x/\1/")
      function=${function#*=}

      virtual_vf_pcie=$bus:$slot.$function
      if [ $virtual_vf_pcie == $phy_nic_pcie ]; then
        continue
      fi
      virtual_vf_info=$(lspci | grep $virtual_vf_pcie)
      let vf_index=vf_index+1
      echo -e "\tvf $vf_index $virtual_vf_info"
    done
  else
     echo -e "\033[31pcie address format error \033[0m"
  fi
}


function display_all_physical_nic()
{
  echo "display all physical nics"
  virtual_nic_pcie=$(lspci | grep Ethernet | awk '{print $1}')
  for pcie in ${virtual_nic_pcie[*]}; do
    nic_info=$(lspci | grep $pcie)
    virtual_nic=$(lspci | grep $pcie | grep "Virtual Function")
    if [ ${#virtual_nic} == 0 ]; then
      echo -e "\t${nic_info}"
    fi
  done
}

# $1: pf pcie address
# $2: alloc_vf
function pf_alloc_n_vf()
{
  pcie=$1
  alloc_vf=$2
  pcie_prefix="0000"
  pcie_max_vf=
  regex="^[[:xdigit:]]{2}:[[:xdigit:]]{2}\.[[:xdigit:]]$"
  
  if [ $pcie =~ $regex ]; then
    for it in ${SUPPORT_SR_IOV_NIC}; do
      if [ $pcie == $it ]; then
	pcie_max_vf=$(lspci -vvs 5e:00.0 | grep "VFs" | sed -n 's/.*VFs: \(.*,\)\?.*/\1/p')
        pcie_max_vf=${pcie_max_vf%,*}
        if [ ${alloc_vf} > ${pcie_max_vf} ]; then
	  echo -e "\033[31${pcie} max support ${pcie_max_vf} vfs. \033[0m"
  	  exit -1
        fi
        
	# reboot ok.
	# echo "echo '${alloc_vf}' > /sys/bus/pci/devices/${pcie}/sriov_numvfs" >> /etc/rc.local
        break
      fi
    done
  else
    echo -e "\033[31pcie format error! \033[0m"
    exit -1
  fi
 
  echo -e "\033[36m[*]:${pcie} NF alloc ${alloc_vf} vfs success! \033[0m"
}

# $1: vf pcie address
function generate_vf_dev_xml()
{
  pcie=$1
  regex="^[[:xdigit:]]{2}:[[:xdigit:]]{2}\.[[:xdigit:]]$"
  
  if [ $pcie =~ $regex ]; then
    for it in ${SUPPORT_SR_IOV_NIC}; do
      if [ $pcie == $it ]; then
	pcie_address=$(echo ${pcie} | sed 's/:/_/g' | sed 's/\./_/g')
        pcie_address=$(virsh nodedev-list | grep ${pcie_address})
 	VF_XML_DATA=$(virsh nodedev-dumpxml ${pcie_address} |  awk '/number/{getline a;print a}' | sed -n 's/.*<address\(.*>\)\?.*/\1/p')
	vf_xml_file="/sriov/"${pcie_address}"-dev.xml"
	touch ${vf_xml_file}
	echo ${VF_XML_PREFIX1} >> ${vf_xml_file}
	echo ${VF_XML_PREFIX2} >> ${vf_xml_file}
	echo ${VF_XML_PREFIX3}${VF_XML_PREFIX4}${VF_XML_DATA} >> ${vf_xml_file}
	echo ${VF_XML_SUBFIX2}
	echo ${VF_XML_SUBFIX1}
	echo "${vf_xml_file} create successfule"
        break
      fi
    done
  else
    echo -e "\033[31pcie format error! \033[0m"
    exit -1
  fi
}

function attach_vf_nic_vm()
{
  vf_xml_file=$1
  vm_name=$2
  vm_list=$(virsh list --all)
  for vm in $vm_list; do
    if [ $vm_name == $vm ]; then
      vm_status=$(virsh list --all | grep ${vm} | awk '{print $3}')
      if [ $vm_status == $VM_RUNNING_STATUS ]; then
	virsh attach-device ${vm_name} ${vf_xml_file} --live --config
      elif [ $vm_status == $VM_SHUTDOWN_STATUS ]; then
	virsh attach-device ${vm_name} ${vf_xml_file} --live --config
      else
	echo -e "\033[31${vm} virtual machine in other status, can't attache vf nic \033[0m"
      fi
    fi
  done
}

# modify sriov mode and phy nic mode
function spoof_trust_enable_disable()
{
  sub_command=$1
  trust_action=$(cut -d'_' -f1 <<< "$sub_command")
  spoof_action=$(cut -d'_' -f2 <<< "$sub_command")
  physical_nic=$(cut -d'_' -f3 <<< "$sub_command")

  pcie=$(ethtool -i ${physical_nic} | grep "bus-info: " | awk '{print $2}' | sed 's/[:|.]/_/g')
  pcie="pci_"$pcie

  sriov_and_phy_nics=$(virsh nodedev-dumpxml $pcie | grep "address" | wc -l)
  let sriov_vfs=sriov_and_phy_nics-1
  
  # set phy_nic start allmuticast mode
  ip link set ${physical_nic} allmulticast on

  for ((vf_index = 0; vf_index < sriov_and_phy_nics - 1; vf_index++)) do
    ip link set dev ${physical_nic} vf ${vf_index} trust ${trust_action} spoof ${spoof_action}
  done
}

function help_menu()
{
  SCRIPT_NAME=$(basename "$0")
  echo "usage: ${SCRIPT_NAME} [-avpshlg] [--pf_pcie] [--alloc_vfs] [--vf_pcie] [--virtual_machine]"
  echo "       ${SCRIPT_NAME} [--pf_pcie=pf_pcie --alloc_vfs=alloc_n_vfs] [-g]"

  echo -e "\t -a,                    display all nic"
  echo -e "\t -v,                    display all virtual nic"
  echo -e "\t -p,                    dispaly all physical nic"
  echo -e "\t -s, --sriov            display all support sriov physical nic"
  echo -e "\t -h, --help             display help menu"
  echo -e "\t -l, --list_pf_all_vfs  display all vfs from pointed pf"
  echo -e "\t --enable               enable nic attribute"
  echo -e "\t --enable_out_sysconfig enable nic attribute"
}

# lshw -C network -businfo | grep "5e:00.0", according nic pcie search nic_name

function main()
{
  check_sriov_envirment
  # 1.使用getopt获取一个解析后的字符串
  parse_options=$(getopt -o s::,h::,a::,l::,p::,v:: -l pf_pcie::,alloc_vfs::,vf_pcie::,virtual_machine::,sriov::,help::,list_pf_all_vfs::,enable::,enable_out_sysconfig::,vlan:: -- $@)

  # 2.将传递的参数设置成刚解析的字符串,--代表传递的参数,eval是为了防止有shell关键字和可选参数的的空格识别
  eval set -- $parse_options

  pf_pcie=
  alloc_n_vf=
  nf_pcie=
  vm=
  
  generate_vf_xml_file=0

  script_exec_name=$0
  while true; do
    case "$1" in
      -s)
	  display_support_sriov_nic
          shift 2
          ;;
      -a)
          display_all_nic
	  shift 2
	  ;;
      -l | --list_pf_all_vfs)
	  case $2 in
          '')
              echo "please input phy nic pcie address"
              exit -1
              ;;
           *)
              pf_pcie=$2
              display_all_virtual_nic_from_pf $2
              shift 2
              ;;
          esac
          ;;
      -p)
	  display_all_physical_nic
	  shift 2
	  ;;
      -v)
	  display_all_virtual_nic
	  shift 2
	  ;;
      -g)
          generate_vf_xml_file=1
          shift 2
          ;;
      -h | --help)
	  help_menu
          shift 2
	  ;;
      --pf_pcie)
 	  case $2 in
            '')
		echo "please input phy nic pcie address"
		exit -1
                ;;
            *)
        	pf_pcie=$2
                shift 2
                ;;
          esac
	  ;;
      --alloc_vfs)
          case $2 in
            '')
                echo "please input alloce vfs counts for phy nic"
                exit -1
                ;;
            *)
                alloc_n_vf=$2
                shift 2
                ;;
          esac
          ;;
      --vf_pcie)
          case $2 in
            '')
                echo "please input vf pcie address"
                exit -1
                ;;
            *)
                vf_pcie=$2
                shift 2
                ;;
          esac
          ;;
      --virtual_machine)
          case $2 in
            '')
                echo "please input virtual machine name"
                exit -1
                ;;
	   '?')
		echo "${script_exec_name:2} --virtual_machine=vir_m_name [domiflist]"
		break
                ;;
            *)
                vm=$2
		action=$4
		echo "$2 $4"
		
                shift 2
                ;;
          esac
          ;;
      --enable)
	  case $2 in
	    '?')
		script_name=${script_exec_name:2}
		echo "${script_name} --enable=on trust on/off spoof on/off dev phy_nic_name"
		break
		;;
	    'on')
		sub_command=$(echo "$5_$7_$9")
		spoof_trust_enable_disable $sub_command
		break
	  esac
	  ;;
      --enable_out_sysconfig)
	  case $2 in
	    '')
		echo "please input on/off enable output sys configure"
                exit -1
		;;
            'on')
		DISPLAY_CONFIGS=on
		echo $DISPLAY_CONFIGS
		exit 0
		;;
	    'off')
		DISPLAY_CONFIGS=off
		exit 0
		;;
            *)
		exit 0
		;;
          esac
	  ;;
      --)
          shift
          break
          ;;
      *)
          echo "Parse Error!"
          exit 1
          ;;
    esac
  done
: << EOF
  echo "nic: ${pf_pcie}"
  echo "alloc_n_vf: ${alloc_n_vf}"
  echo "vf: ${vf_pcie}"
  echo "vm: ${vm}"
EOF
}

main $@
