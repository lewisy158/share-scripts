#!/usr/bin/bash

CTCONFDIR=/etc/pve/local/lxc
VMCONFDIR=/etc/pve/local/qemu-server
IFBRIDGE=enp65s0
LBRIDGE=vmbr0
TMP_FILE=/tmp/vf_add_maddr.tmp

C_RED='\e[0;31m'
C_GREEN='\e[0;32m'
C_NC='\e[0m'

if [ ! -d $CTCONFDIR ] || [ ! -d $VMCONFDIR ]; then
    echo -e "${C_RED}ERROR: Not mounted, self restart in 5s!${C_NC}"
    exit 1
else
    MAC_LIST_VMS=" $(cat ${VMCONFDIR}/*.conf | grep bridge | grep -Eo '([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}' | tr '[:upper:]' '[:lower:]') $(cat ${CTCONFDIR}/*.conf | grep hwaddr | grep -Eo '([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}' | tr '[:upper:]' '[:lower:]')"
    MAC_ADD2LIST="$(cat /sys/class/net/$LBRIDGE/address)"
    MAC_LIST="$MAC_LIST_VMS $MAC_ADD2LIST"
    /usr/sbin/bridge fdb show | grep "${IFBRIDGE} self permanent" > $TMP_FILE

    for mactoregister in ${MAC_LIST}; do
        if ( grep -Fq $mactoregister $TMP_FILE ); then
            echo -e "${C_GREEN}$mactoregister${C_NC} - Exists!"
        else
            /usr/sbin/bridge fdb add $mactoregister dev ${IFBRIDGE}
            echo -e "${C_RED}$mactoregister${C_NC} - Added!"
        fi
    done
    exit 0
fi
