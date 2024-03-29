#!/usr/bin/env bash
set -e -u
set -o pipefail
. vars

cat ../../../../manifests/k8sproject-vm/1-px-operator.yml | \
sed "s,XX_PX_OPERATOR_VERSION_XX,${PX_OPERATOR_VERSION},g" > "${vPX_Operator_File}";

cat ../../../../manifests/k8sproject-vm/2-storage-cluster.yml | \
sed "s,XX_PX_STORAGE_CLUSTER_VERSION_XX,${PX_STORAGE_CLUSTER_VERSION},g" > "${vPX_Storage_Cluster_File}";

PX_KVDB_DEVICE="$(echo "${PX_KVDB_DEVICE}" | tr '[:upper:]' '[:lower:]'|xargs)";

if [[ "${PX_KVDB_DEVICE}" == "" ]]; then 
  sed -i_sedtmp "/    kvdbDevice: XX_PX_KVDB_DEVICE_XX/d" "${vPX_Storage_Cluster_File}";
elif [[ "${PX_KVDB_DEVICE}" == "auto" ]]; then 
  sed -i_sedtmp "s,XX_PX_KVDB_DEVICE_XX,/dev/pwx_vg/pwxkvdb,g" "${vPX_Storage_Cluster_File}";
else 
  sed -i_sedtmp "s,XX_PX_KVDB_DEVICE_XX,${PX_KVDB_DEVICE},g" "${vPX_Storage_Cluster_File}";
fi
rm *_sedtmp

vMasters="$("${kbCtl}" --kubeconfig="${vKubeConfig}" get node --selector='node-role.kubernetes.io/master' --no-headers=true -o custom-columns=":metadata.name")";
"${kbCtl}" --kubeconfig="${vKubeConfig}" cordon ${vMasters};

echo "Installing Storage Operator"
"${kbCtl}" --kubeconfig="${vKubeConfig}" apply -f "${vPX_Operator_File}"        ; sleep 30;

echo "Installing k8sproject storage cluster"
"${kbCtl}" --kubeconfig="${vKubeConfig}" apply -f "${vPX_Storage_Cluster_File}" ; sleep 30;

echo "Creating storage classes"
"${kbCtl}" --kubeconfig="${vKubeConfig}" apply -f "../../../../manifests/common/storage-classes.yml" ; sleep 30;

${kbCtl} --kubeconfig="${vKubeConfig}" get nodes
