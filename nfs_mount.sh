#!/bin/bash

nfs_host=192.168.2.23
nfs_path_list=(
    /volume1/docker
    /volume1/homes
    /volume1/video
)
mount_path_list=(
    /docker
    /mnt/nas
    /mnt/video
)

while true;do
    ping -c 1 -W 1 $nfs_host > /dev/null 2>&1
    if [ "$?" -eq "0" ];then
        break
    fi
    sleep 1
done
echo "$nfs_host is ready"

for ((i=0; i<${#nfs_path_list[@]}; i++));do
    if [ -z `df | awk '{print $6}' | grep "${mount_path_list[$i]}"` ];then
        mkdir ${mount_path_list[$i]} > /dev/null 2>&1
        while true;do
            mount -t nfs $nfs_host:${nfs_path_list[$i]} ${mount_path_list[$i]} > /dev/null 2>&1
            if [ "$?" -eq "0" ];then
                break
            fi
            sleep 1
        done
        echo "${mount_path_list[$i]} is ready"
    else
        echo "${mount_path_list[$i]} is already ready"
    fi
done
