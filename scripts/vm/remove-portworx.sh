#!/usr/bin/env bash
set -u
set -o pipefail
. vars

vPXStrgClstrName="px-cluster";
"${kbCtl}"  --kubeconfig="${vKubeConfig}" patch   storagecluster "${vPXStrgClstrName}" --namespace k8sproject -p '{"spec":{"deleteStrategy":{"type":"UninstallAndWipe"}}}' --type=merge
"${kbCtl}"  --kubeconfig="${vKubeConfig}" delete  StorageCluster "${vPXStrgClstrName}" --namespace k8sproject &
sleep 10;
"${kbCtl}"  --kubeconfig="${vKubeConfig}" delete  -f "${vPX_Operator_File}" & 
sleep 120;
