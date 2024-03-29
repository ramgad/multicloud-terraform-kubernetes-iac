
resource "null_resource" "setup" {
  provisioner "local-exec" {
     command = <<-EOT
       echo "Setting up k8s cluster. It will take several minutes."
       ../../../../scripts/vm/setup-cluster.sh
       ../../../../scripts/vm/install-k8sproject.sh
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
   }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
       echo "Deleting k8s cluster. It will take several minutes."
       ../../../../scripts/vm/remove-k8sproject.sh
       ../../../../scripts/vm/delete-cluster.sh
     EOT
     interpreter = ["/bin/bash", "-c"]
     working_dir = path.module
   }
}

