resource "null_resource" "install_k8sproject" {
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG="$PWD/kube-config-file"
      if [ -f ~/.kube/config ]; then
         mv ~/.kube/config ~/.kube/config_$(date +%F_%H-%M-%S)
      fi
      sleep 30
      gcloud container clusters get-credentials --region ${var.google_zone} ${var.cluster_name}
      cp $PWD/kube-config-file  ~/.kube/config
      sleep 5
      chmod +x "../../../../scripts/gke/installk8sproject.sh"
      "../../../../scripts/gke/installk8sproject.sh" \
         "${var.px_operator_version}" \
         "${var.px_storage_cluster_version}" \
         "${var.px_cloud_storage_type}" \
         "${var.px_cloud_storage_size}" \
         "${var.px_kvdb_device_storage_type}" \
         "${var.px_kvdb_device_storage_size}" 

     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
  }
  
  depends_on = [google_container_cluster.primary, google_container_node_pool.primary_nodes]
}

resource "null_resource" "remove_k8sproject" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
       echo "Removing k8sproject, it will take several minutes."
       ../../../../scripts/gke/removek8sproject.sh
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
  }
  depends_on = [google_container_cluster.primary, google_container_node_pool.primary_nodes]
}
