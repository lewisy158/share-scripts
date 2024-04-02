#!/bin/bash

set_sata_controller=1

use_sriov=1
sriov_num=60
sriov_start_mac="24:1c:04:f3:13:"
sriov_start_mac_hex_num=21

# SATA controller reset_method
if [ $set_sata_controller -eq 1 ];then
    lspci -n | grep 1022:7901 | awk '{print $1}' | while read _id; do echo "set reset_method for PCI ${_id}"; echo "bus" > /sys/bus/pci/devices/0000:$_id/reset_method; done
fi

# SR-IOV
if [ $use_sriov -eq 1 ];then
    echo $sriov_num > /sys/class/net/enp65s0/device/sriov_numvfs

    for (( num=0; num<$sriov_num; num++ ));do
        add_num=$[$num + $((16#$sriov_start_mac_hex_num))]
        mac_num=`printf '%x\n' $add_num`
        ip link set dev enp65s0 vf $num mac $sriov_start_mac$mac_num
    done

    ip link set enp65s0 up

    for (( num=0; num<$sriov_num; num++ ));do
        ip link set enp65s0v$num up
    done
fi
