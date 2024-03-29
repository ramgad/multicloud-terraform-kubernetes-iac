#!/usr/bin/env bash
set -e +u
set -o pipefail

export KUBECONFIG="$PWD/kube-config-file"
echo "Creating Manifest files with terraform.tfvars entries for Azure AKS k8sproject installation"
px_operator_version=$1
px_storage_cluster_version=$2
px_cloud_storage_type=$3
px_cloud_storage_size=$4
px_kvdb_device_storage_type=$5
px_kvdb_device_storage_size=$6

#Installs Storage Operator on EKS cluster
vTmpPXOperator=./10.k8sproject-operator.yml;
vTmpPXStorage=./20.storage-cluster.yml;
cp -f ../../../../manifests/k8sproject-aks/10.k8sproject-operator.yml ${vTmpPXOperator};
cp -f ../../../../manifests/k8sproject-aks/20.storage-cluster.yml ${vTmpPXStorage};

sed -i_sedtmp "s,<k8sproject_operator_version_replaceme>,${px_operator_version},g" ${vTmpPXOperator};
sed -i_sedtmp "s,<storage_cluster_version_replaceme>,${px_storage_cluster_version},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<k8sproject_cloud_storage_type_replaceme>,${px_cloud_storage_type},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<k8sproject_cloud_storage_size_replaceme>,${px_cloud_storage_size},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<kvdb_device_storage_type_replaceme>,${px_kvdb_device_storage_type},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<kvdb_device_storage_size_replaceme>,${px_kvdb_device_storage_size},g" ${vTmpPXStorage};

rm *_sedtmp

echo "Installing Storage Operator"
kubectl apply -f ${vTmpPXOperator}; 2>&1 >/dev/null

sleep 30

echo "Installing k8sproject storage cluster"
kubectl apply -f ${vTmpPXStorage}; 2>&1 >/dev/null

echo "Creating storage classes"
kubectl apply -f "../../../../manifests/common/storage-classes.yml" ; sleep 30;
