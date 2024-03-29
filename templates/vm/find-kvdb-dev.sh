#!/usr/bin/env bash
set -u
set -o pipefail
OPERATION="${1}"

PX_VG_NAME=pwx_vg
PX_LV_NAME=pwxkvdb

if [[ "${OPERATION}" == "create" ]]; then
  CHECK_EXISTING=$(lvs --select vg_name=${PX_VG_NAME} -o"lv_name" --noheadings |xargs||true)
  if [[ "${CHECK_EXISTING}" == "" ]]; then 
    DSK_SIZE="0"
    DISKS=$(lsblk -f -d -b -n  -oNAME,SIZE,FSTYPE| egrep -v "xfs|ext3|ext4|btrfs|sda|sr0")

    if [[ "${DISKS}" != "" ]]; then 
      while IFS= read -r line; do
        TMP_SIZE=$(echo $line|awk {'print $2'})
        TMP_NAME=$(echo $line|awk {'print $1'})
        if [[ "$DSK_SIZE" = "0" ]]
          then
            DSK_SIZE=$TMP_SIZE
            DSK_NAME=$TMP_NAME
        elif [[ "$DSK_SIZE" -gt "$TMP_SIZE" ]]
          then
            DSK_SIZE=$TMP_SIZE
            DSK_NAME=$TMP_NAME
        fi
      done <<< "$DISKS"

      echo -e "Creating $DSK_NAME for k8sproject KVDB LVM."
      DEV="/dev/$DSK_NAME"
      pvcreate $DEV
      vgcreate ${PX_VG_NAME} $DEV
      lvcreate -l 100%FREE -n ${PX_LV_NAME} ${PX_VG_NAME}
    else
      echo "No device found to create k8sproject KVDB LVM device!"
    fi
  else
    echo "k8sproject KVDB LVM device already exist!"
  fi
elif [[ "${OPERATION}" == "delete" ]]; then
  DEV=$(lvs --select vg_name=${PX_VG_NAME} -o devices |tail -1 | xargs | sed 's,(.*),,g'||true)
  if [[ "${DEV}" != "" ]]; then 
    echo "Deleting k8sproject KVDB LVM device: '/dev/${PX_VG_NAME}/${PX_LV_NAME}'"
    lvremove -y /dev/${PX_VG_NAME}/${PX_LV_NAME}
    vgremove ${PX_VG_NAME}
    pvremove $DEV
    wipefs -a $DEV
  else
    echo "k8sproject KVDB LVM device does not exist!"
  fi
else
  echo -e "\nUnknown or missing parameter!";  echo -e "\nUsage:\n  $0 [create|delete]\n"
  exit 1
fi