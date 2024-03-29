# Step by Step Guide to install Google Cloud GKE with k8sproject

```
If you have completed the GKE admin setup, please go to step #4

```

## PreRequisite

1. Install all the required softwares/tools - please see docs/[README.md](../../README.md) for instruction on installing all the required softwares

2. Please see docs/GoogleCloud-Admin/README.md for instruction on provisioning the Google Cloud IAM service account with required permissions for creating the cluster

3. Export the JSON and provide it to the user who is creating the cluster


## Step 1. Installation of required software

This repo contains scripts/prereq.sh file that will install all the required softwares based on the OS (tested on Linux (CentOS, Ubuntu) and MacOS)

Upon running the script the following software/tools will be installed that is required to create AKS cluster

1. Terraform
2. GIT
3. Google SDK
4. Kubectl

For additional details and instructions on above installing above softwares are defined at [readme.md](../../README.md)

### Step 2. Download the IaC code

Download the latest source from [git](https://github.com/ramgad/multicloud-terraform-kubernetes-iac.git) to have latest terraform-iac library

If you already have the repo downloaded, git pull command will bring the latest code from the GIT master

```
    git clone https://github.com/ramgad/multicloud-terraform-kubernetes-iac.git
```

### 3. GKE Cloud Authorization

Note: Manual way of creating service account from console. 

```
Create a new Service Account (if you do not have one provisioned) already :
Navigate to Google cloud console for your org (https://console.cloud.google.com/) - Login with your credentials
Navigate to IAM & Admin 
Click on Service Accounts
    Create new Service Account if you dont have one
    Choose Name (for ex: svck8sprojectDemo )
        Permissions: 
          1. Compute Admin
          2. Service Account User
          3. Kubernetes Engine Admin
          4. Project IAM Admin
          5. Service Account Token Creator
        Keys:
            For the new service account created, Generate a new Key and export the JSON file using Manage Key option under Actions.(this will be used in terraform.tfvars)
    Ensure you are connecting to the service account
        1. gcloud auth revoke <Revoke all active authentications>
        2. gcloud init (choose your servive-account, project-id, region, zone etc)
        2. gcloud auth activate-service-account --key-file=/Users/t_gadar/Downloads/svck8sprojectDemo-credentials-52bc683c4a93.json
    
```
### 4. Navigate to scripts folder and Run setup_env.sh <param1> <param2> <param3>

Note: Ensure to have the IAM json in scripts/keys folder (Your admin has created the service account and should be sharing details with you)
	
```
./setup_env.sh <Provider> <UniqueIdForCluster> <ZoneName>

./setup_env.sh help

GCloud for example: ./setup_env.sh gcloud <AccountIdWithEnv> us-east4

>Provider : aws, gcloud or zure.
>UniqueIdForCluster : It can be account number or project name.
>Zone : Zone in which cluster will be deployed.


 ~/ramgad/multicloud-terraform-kubernetes-iac/scripts (master) ⚡ :pwd
/Users/t_gadar/ramgad/multicloud-terraform-kubernetes-iac/scripts

 gcloud example:
 ~/ramgad/multicloud-terraform-kubernetes-iac/scripts (master) ⚡ :./setup_env.sh gcloud PSGcloudDev us-central1
 
```

You will be be navigated to a new bash shell at the targeted location with the following files

The following entries are example, you should be seeing similar files and folder structure relative to where you have installed the terraform-iac git repo


#### GCloud Example:
```
terraform-iac/terraform-live/gcloud/PSGcloudDev/us-central1 git/master*
 ~/ramgad/multicloud-terraform-kubernetes-iac/terraform-live/gcloud/PSGcloudDev/us-central1 git:(master*) :ls -alrt
drwxr-xr-x  3 t_gadar  staff    96 Jan 12 23:18 ..
-rw-r--r--  1 t_gadar  staff   571 Jan 12 23:21 terraform.tfvars
-rw-r--r--  1 t_gadar  staff  2244 Jan 24 23:01 gke.tf
-rw-r--r--  1 t_gadar  staff   153 Jan 24 23:01 provider.tf
-rw-r--r--  1 t_gadar  staff  1244 Jan 24 23:01 variable.tf
-rw-r--r--  1 t_gadar  staff   158 Jan 24 23:01 versions.tf
-rw-r--r--  1 t_gadar  staff   444 Jan 24 23:01 vpc.tf
drwxr-xr-x  8 t_gadar  staff   256 Jan 24 23:01 .

```


### 5. Configure terraform.tfvars [parameters]
	
Google Cloud Project ID can be found from your Google console by navigating to the project where you are interested to creating the GKE cluster. See image below for example:
	
![Project ID from Console Example](https://github.com/ramgad/multicloud-terraform-kubernetes-iac/blob/main/docs/gcloudGKE/gcp2.JPG)
	
The json IAM files contains the service account that needs to be placed in terraform.tfvars. See below image for example:
	
![compute_engine_service_account](https://github.com/ramgad/multicloud-terraform-kubernetes-iac/blob/main/docs/gcloudGKE/gcp4.JPG)

Use vi or nano to edit terraform.tfvars file. To execute usng nano as a file editor you can use the command: `nano terraform.tfvars`

```	
google_cloud_project_id         = "gcp-flashblade-286121"    // This is a GCP project that your admin has created       
google_region                   = "us-central1"      // For VPC only
google_zone                     = "us-central1-a"    // If you provide region here, GKE will try create nodes in each zone - Multiplied by 3
number_of_nodes                 = "3"                // # of nodes. Minimum of 3 nodes are required
gke_machine_type                = "e2-highcpu-4"
compute_engine_service_account  = "k8sproject-gke-cloud-operations@px-final-test1.iam.gserviceaccount.com"
gcloud_iam_file_location        = "../../../../scripts/keys/px-final-test1-cluster-ops.json" //Location to your .json credentials file

cluster_name                    = "ps-final-test1"  // Define your own unique cluster name
gke_machine_image               = "UBUNTU_CONTAINERD"
k8s_version                     = "1.21.6-gke.1503" // Kubernetes Engine Version
px_operator_version             = "1.6.1"           // k8sproject Operator Version
px_kvdb_device_storage_type     = "pd-ssd"          // Px KVDB Storage Type on Google Cloud
px_kvdb_device_storage_size     = "30"              // Px KVDB Storage size
px_cloud_storage_size           = "30"              // Px Cloud Storage Size
px_cloud_storage_type           = "pd-ssd"          // Px Cloud Storage type on Google
px_storage_cluster_version      = "2.9.0"           // Px Storage Cluster Version

```

### 6. Execute

> Note: Terraform will use default VPC available in your account. If you want to create new VPC, rename the 'vpc.bkp' to 'vpc.tf' and uncomment the following lines in `gke.tf` file:

    #network                  = google_compute_network.vpc.name
    #subnetwork               = google_compute_subnetwork.subnet.name

Run the following Terraform commands to start the process:
```
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars" -out plan.out
terraform apply "plan.out"
```

This completes the creation of GKE cluster with k8sproject, and the output of cluster name is generated.

> Note: A new kube config file will be created at ~/.kube/config, and the existing kube config file will be backed up with date and time stamp.

###  Step 7. Check if everything is up and ready:

**To check nodes:**

	kubectl --kubeconfig=kube-config-file get nodes                          

**To check k8sproject pods:**

	kubectl --kubeconfig=kube-config-file get pods -n k8sproject 

**To check k8sproject cluster status:**

	PX_NS_AND_POD=$(kubectl --kubeconfig=kube-config-file get pods --no-headers -l name=k8sproject --all-namespaces -o jsonpath='{.items[*].metadata.ownerReferences[?(@.kind=="StorageCluster")]..name}' -o custom-columns="Col-1:metadata.namespace,Col-2:metadata.name" | head -1)
	kubectl --kubeconfig=kube-config-file exec -n $PX_NS_AND_POD -c k8sproject -- /opt/pwx/bin/pxctl status
	
### How to Apply k8sproject Parameter Changes (Re-creates k8sproject)

Follow the below steps to apply k8sproject changes. Modify Terraform.tfvars to accommodate the new changes.

```
For ex:
terraform destroy target null_resource.install_k8sproject -auto-approve

terraform plan -out "plan.out"
terraform apply "plan.out"
```
	
### How to SSH into GKE Node
1.) In your GCP (Google Cloud) Console go to compute engine -> VM Instances
	
2.) Select the instance you want to SSH into
	
3.) Click on SSH button to log in to the instance via SSH. Please refer to screenshot below:
![SSH into Instance](https://github.com/ramgad/multicloud-terraform-kubernetes-iac/blob/main/docs/gcloudGKE/gcp5.JPG)
	
### Terraform Helpful Command
	
To list all the resources in the terraform state:
```
	terraform state list
```	
To destroy one specific resource from state:
```
	terraform destroy -target <ResourceNameFromState> -auto-approve
```	
To remove one resource from state:
```
	terraform state rm <ResourceNameFromState>
``` 
## Cleanup steps:
Step 1: 
Configure Kubeconfig to the GKE cluster that you would like to clean up

```
        export KUBECONFIG="$PWD/kube-config-file"

        if the file does not existing run the following to create the kube config file

        gcloud container clusters get-credentials --region ${var.google_zone} ${var.cluster_name}

        Test: 
        kubectl get nodes //should return the nodes
```

Step 2: Delete any other namespaces that may have created on the cluster


Step 3: Google Cloud auth

Authenticate to Google Cloud with account provisioned the GKE cluster
```
terraform destroy -auto-approve
```
### Destroy specific resource from terraform:

```
terraform destroy target <null_resource.install_k8sproject> -auto-approve

The Terraform state resource list can be found with the following command
	terraform state list
```

Note: the terraform destroy command needs to be executed from the same location as terraform apply command. 
